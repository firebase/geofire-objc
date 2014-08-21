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
#define SEARCH_RADIUS 0.750
#define VIEW_SIZE 1500

#define CIRCLE_FRACTION (3.0/4.0)

#define GEO_FIRE_URL @"https://publicdata-transit.firebaseio.com/_geofire"

@interface SFViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) GeoFire *geoFire;
@property (nonatomic, strong) GFRegionQuery *regionQuery;
@property (nonatomic, strong) GFCircleQuery *circleQuery;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) SFVehicleAnnotation *centerAnnotation;
@property (nonatomic, strong) UITapGestureRecognizer *singleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapRecognizer;
@property (nonatomic) BOOL isRotating;

@property (nonatomic, strong) NSMutableDictionary *vehicleAnnotations;

@end

@implementation SFViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self != nil) {
        self.geoFire = [[GeoFire alloc] initWithFirebaseRef:[[Firebase alloc] initWithUrl:GEO_FIRE_URL]];
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
    if (annotation != self.centerAnnotation && !self.circleView.hidden) {
        pinView.pinColor = MKPinAnnotationColorGreen;
    } else {
        pinView.pinColor = MKPinAnnotationColorRed;
    }
    pinView.annotation = annotation;
    
    return pinView;
}

- (void)setupListeners:(GFQuery *)query
{
    [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        SFVehicleAnnotation *annotation = [[SFVehicleAnnotation alloc] init];
        annotation.coordinate = location.coordinate;
        [self.mapView addAnnotation:annotation];
        self.vehicleAnnotations[key] = annotation;
    }];
    [query observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        SFVehicleAnnotation *annotation = self.vehicleAnnotations[key];
        [self.mapView removeAnnotation:annotation];
    }];
    [query observeEventType:GFEventTypeKeyMoved withBlock:^(NSString *key, CLLocation *location) {
        SFVehicleAnnotation *annotation = self.vehicleAnnotations[key];
        [UIView animateWithDuration:3.0 animations:^{
            annotation.coordinate = location.coordinate;
        }];
    }];
}

- (void)updateOrSetupCircleQuery
{
    CLLocationCoordinate2D centerCoordinate = [self.mapView convertPoint:self.circleView.center
                                                    toCoordinateFromView:self.view];
    CGSize mySize = self.view.bounds.size;
    CGFloat minSize = fminf(mySize.height, mySize.width)*CIRCLE_FRACTION;
    CGPoint pointOnBorder = CGPointMake(mySize.width/2-minSize/2, mySize.height/2);
    CLLocationCoordinate2D coordinateOnBorder = [self.mapView convertPoint:pointOnBorder
                                                      toCoordinateFromView:self.view];
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:centerCoordinate.latitude
                                                            longitude:centerCoordinate.longitude];
    CLLocation *locationOnBorder = [[CLLocation alloc] initWithLatitude:coordinateOnBorder.latitude
                                                              longitude:coordinateOnBorder.longitude];
    CLLocationDistance distance = [centerLocation distanceFromLocation:locationOnBorder]/1000; // in kilometers
    if (self.circleQuery != nil) {
        self.circleQuery.center = centerLocation;
        self.circleQuery.radius = distance;
    } else {
        self.circleQuery = [self.geoFire queryAtLocation:centerLocation withRadius:distance];
        [self setupListeners:self.circleQuery];
    }
    self.centerAnnotation.coordinate = centerLocation.coordinate;

    NSLog(@"Updated query to radius %f at [%f, %f]",
          distance,
          centerLocation.coordinate.latitude,
          centerLocation.coordinate.longitude);
}

- (void)updateOrSetupRegionQuery
{
    MKCoordinateRegion region = self.mapView.region;
    if (self.regionQuery != nil) {
        self.regionQuery.region = region;
    } else {
        self.regionQuery = [self.geoFire queryWithRegion:region];
        [self setupListeners:self.regionQuery];
    }
    NSLog(@"Updated query to region [%f +/- %f, %f, +/- %f]",
          region.center.latitude, region.span.latitudeDelta/2,
          region.center.longitude, region.span.longitudeDelta/2);
}

- (void)toggleCircle
{
    for (NSString *vehicleId in self.vehicleAnnotations) {
        [self.mapView removeAnnotation:self.vehicleAnnotations[vehicleId]];
    }
    if (self.circleView.hidden) {
        [self.regionQuery removeAllObservers];
        self.regionQuery = nil;
        self.circleView.hidden = NO;
        [self.mapView addAnnotation:self.centerAnnotation];
        [self updateOrSetupCircleQuery];
    } else {
        [self.circleQuery removeAllObservers];
        self.circleQuery = nil;
        self.circleView.hidden = YES;
        [self.mapView removeAnnotation:self.centerAnnotation];
        [self updateOrSetupRegionQuery];
    }
}

- (void)loadView
{
    [super loadView];
    self.circleView = [[UIView alloc] init];
    self.circleView.backgroundColor = [UIColor colorWithRed:0.7 green:0.2 blue:0.7 alpha:0.3];
    self.circleView.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:0.3].CGColor;
    self.circleView.layer.borderWidth = 5;
    self.circleView.userInteractionEnabled = NO;
    self.circleView.hidden = self.circleView == nil;
    self.singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleCircle)];
    // Add a double tap gesture recognizer to prevent a double tap to count as single tap
    self.doubleTapRecognizer = [[UITapGestureRecognizer alloc] init];
    self.doubleTapRecognizer.numberOfTapsRequired = 2;
    [self.singleTapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
    [self.view addGestureRecognizer:self.singleTapRecognizer];
    [self.view addGestureRecognizer:self.doubleTapRecognizer];
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [self toggleCircle];
}

- (void)updateQuery
{
    if (self.regionQuery != nil) {
        [self updateOrSetupRegionQuery];
    } else {
        [self updateOrSetupCircleQuery];
    }
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
    [self.regionQuery removeAllObservers];
    [self.circleQuery removeAllObservers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
