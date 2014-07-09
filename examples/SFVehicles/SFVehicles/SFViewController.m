//
//  SFViewController.m
//  SFVehicles
//
//  Created by Jonny Dimond on 7/7/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "SFViewController.h"
#import <MapKit/MapKit.h>
#import <GeoFire/GeoFire.h>

#import "SFVehicleAnnotation.h"

#define CENTER_LATIDUDE 37.7789
#define CENTER_LONGITUDE -122.4017
#define SEARCH_RADIUS 750
#define VIEW_SIZE 3000

#define CIRCLE_FRACTION (3.0/4.0)

#define GEO_FIRE_URL @"https://geofire-ios.firebaseio.com/geofire"

@interface SFViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) GeoFire *geoFire;
@property (nonatomic, strong) GFQuery *query;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) SFVehicleAnnotation *centerAnnotation;
@property (nonatomic) BOOL isRotating;

@property (nonatomic, strong) NSMutableDictionary *vehicleAnnotations;

@end

@implementation SFViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self != nil) {
        self.geoFire = [GeoFire newWithFirebase:[[Firebase alloc] initWithUrl:GEO_FIRE_URL]];
        self.vehicleAnnotations = [NSMutableDictionary dictionary];
        self.centerAnnotation = [[SFVehicleAnnotation alloc] init];
    }
    return self;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
    if (!pinView) {
        // If an existing pin view was not available, create one.
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                  reuseIdentifier:@"CustomPinAnnotationView"];
        pinView.animatesDrop = YES;
        pinView.canShowCallout = NO;
        // If appropriate, customize the callout by adding accessory views (code not shown).
    }
    if (annotation != self.centerAnnotation) {
        pinView.pinColor = MKPinAnnotationColorGreen;
    } else {
        pinView.pinColor = MKPinAnnotationColorRed;
    }
    pinView.annotation = annotation;
    
    return pinView;
}

- (void)loadView
{
    [super loadView];
    self.circleView = [[UIView alloc] init];
    self.circleView.backgroundColor = [UIColor colorWithRed:0.7 green:0.2 blue:0.7 alpha:0.3];
    self.circleView.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:0.3].CGColor;
    self.circleView.layer.borderWidth = 5;
    self.circleView.userInteractionEnabled = NO;
    [self.view addSubview:self.circleView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGSize mySize = self.view.bounds.size;
    CGFloat minSize = fminf(mySize.height, mySize.width)*CIRCLE_FRACTION;
    self.circleView.frame = CGRectMake(mySize.width/2-minSize/2, mySize.height/2-minSize/2, minSize, minSize);
    self.circleView.layer.cornerRadius = minSize/2;
}

- (void)viewWillAppear:(BOOL)animated
{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(CENTER_LATIDUDE, CENTER_LONGITUDE);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, VIEW_SIZE, VIEW_SIZE);

    self.mapView.delegate = self;
    self.centerAnnotation.coordinate = center;
    [self.mapView addAnnotation:self.centerAnnotation];

    [self.mapView setRegion:viewRegion animated:NO];

    self.query = [self.geoFire queryAtLocation:center withRadius:SEARCH_RADIUS];
    [self.query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        SFVehicleAnnotation *annotation = [[SFVehicleAnnotation alloc] init];
        annotation.coordinate = location.coordinate;
        [self.mapView addAnnotation:annotation];
        self.vehicleAnnotations[key] = annotation;
    }];
    [self.query observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        SFVehicleAnnotation *annotation = self.vehicleAnnotations[key];
        [self.mapView removeAnnotation:annotation];
    }];
    [self.query observeEventType:GFEventTypeKeyMoved withBlock:^(NSString *key, CLLocation *location) {
        SFVehicleAnnotation *annotation = self.vehicleAnnotations[key];
        [UIView animateWithDuration:3.0 animations:^{
            annotation.coordinate = location.coordinate;
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self updateQuery];
}

- (void)updateQuery
{
    CLLocationCoordinate2D centerCoordinate = [self.mapView convertPoint:self.circleView.center
                                                    toCoordinateFromView:self.view];
    //CGRect circleFrame = self.circleView.frame;
    CGSize mySize = self.view.bounds.size;
    CGFloat minSize = fminf(mySize.height, mySize.width)*CIRCLE_FRACTION;
    /*
     CGPoint pointOnBorder = CGPointMake(circleFrame.origin.x + circleFrame.size.width/2,
     circleFrame.origin.y);*/
    CGPoint pointOnBorder = CGPointMake(mySize.width/2-minSize/2, mySize.height/2);
    CLLocationCoordinate2D coordinateOnBorder = [self.mapView convertPoint:pointOnBorder
                                                      toCoordinateFromView:self.view];
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:centerCoordinate.latitude
                                                            longitude:centerCoordinate.longitude];
    CLLocation *locationOnBorder = [[CLLocation alloc] initWithLatitude:coordinateOnBorder.latitude
                                                              longitude:coordinateOnBorder.longitude];
    CLLocationDistance distance = [centerLocation distanceFromLocation:locationOnBorder]; // in meters
    self.query.center = centerLocation.coordinate;
    self.query.radius = distance;
    self.centerAnnotation.coordinate = centerLocation.coordinate;

    NSLog(@"Updated query to radius %f at [%f, %f]", distance, centerLocation.coordinate.latitude, centerLocation.coordinate.longitude);
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.isRotating) {
        return;
    }
    [self updateQuery];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.isRotating = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.isRotating = NO;
    [self updateQuery];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.query removeAllObservers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
