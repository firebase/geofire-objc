//
//  GeoFire.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "GeoFire.h"
#import "GeoFire+Private.h"
#import "GFGeoHash.h"
#import "GFQuery+Private.h"

@interface GeoFire ()

@property (nonatomic, strong, readwrite) Firebase *firebase;

@end

@implementation GeoFire

- (id)init
{
    [NSException raise:NSGenericException
                format:@"init is not supported. Please use %@ instead",
     NSStringFromSelector(@selector(initWithFirebase:))];
    return nil;
}

- (id)initWithFirebase:(Firebase *)firebase
{
    self = [super init];
    if (self != nil) {
        if (firebase == nil) {
            [NSException raise:NSInvalidArgumentException format:@"Firebase was nil!"];
        }
        self->_firebase = firebase;
        self->_callbackQueue = dispatch_get_main_queue();
    }
    return self;
}

+ (GeoFire *)newWithFirebase:(Firebase *)firebase
{
    return [[GeoFire alloc] initWithFirebase:firebase];
}

- (void)setLocation:(CLLocationCoordinate2D)location forKey:(NSString *)key
{
    [self setLocation:location forKey:key withCompletionBlock:nil];
}

- (void)setLocation:(CLLocationCoordinate2D)coordinate
             forKey:(NSString *)key
withCompletionBlock:(GFCompletionBlock)block
{
    if (!CLLocationCoordinate2DIsValid(coordinate)) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Not a valid coordinate: [%f, %f]", coordinate.latitude, coordinate.longitude];
    }
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self setLocationValue:location
                    forKey:key
                 withBlock:block];
}

- (Firebase *)firebaseForLocationKey:(NSString *)key
{
    static NSCharacterSet *illegalCharacters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        illegalCharacters = [NSCharacterSet characterSetWithCharactersInString:@".#$][/"];
    });
    if ([key rangeOfCharacterFromSet:illegalCharacters].location != NSNotFound) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Not a valid GeoFire key: \"%@\". Characters .#$][/ not allowed in key!", key];
    }
    return [self.firebase childByAppendingPath:key];
}

- (void)setLocationValue:(CLLocation *)location
                  forKey:(NSString *)key
               withBlock:(GFCompletionBlock)block
{
    NSDictionary *value;
    NSString *priority;
    if (location != nil) {
        NSNumber *lat = [NSNumber numberWithDouble:location.coordinate.latitude];
        NSNumber *lng = [NSNumber numberWithDouble:location.coordinate.longitude];
        NSString *geoHash = [GFGeoHash newWithLocation:location.coordinate].geoHashValue;
        value = @{ @"l": @[ lat, lng ], @"g": geoHash };
        priority = geoHash;
    } else {
        value = nil;
        priority = nil;
    }
    [[self firebaseForLocationKey:key] setValue:value
                                    andPriority:priority
                            withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (block != nil) {
            dispatch_async(self.callbackQueue, ^{
                block(error);
            });
        }
    }];
}

- (void)removeKey:(NSString *)key
{
    [self removeKey:key withCompletionBlock:nil];
}

- (void)removeKey:(NSString *)key withCompletionBlock:(GFCompletionBlock)block
{
    [self setLocationValue:nil forKey:key withBlock:block];
}

+ (CLLocation *)locationFromValue:(id)value
{
    if ([value isKindOfClass:[NSDictionary class]] && [value objectForKey:@"l"] != nil) {
        id locObj = [value objectForKey:@"l"];
        if ([locObj isKindOfClass:[NSArray class]] && [locObj count] == 2) {
            id latNum = [locObj objectAtIndex:0];
            id lngNum = [locObj objectAtIndex:1];
            if ([latNum isKindOfClass:[NSNumber class]] &&
                [lngNum isKindOfClass:[NSNumber class]]) {
                CLLocationDegrees lat = [latNum doubleValue];
                CLLocationDegrees lng = [lngNum doubleValue];
                if (CLLocationCoordinate2DIsValid(CLLocationCoordinate2DMake(lat, lng))) {
                    return [[CLLocation alloc] initWithLatitude:lat longitude:lng];
                }
            }
        }
    }
    return nil;
}

- (void)observeLocationForKey:(NSString *)key withBlock:(GFLocationBlock)block
{
    [[self firebaseForLocationKey:key] observeEventType:FEventTypeValue
                                              withBlock:^(FDataSnapshot *snapshot) {
                                                  dispatch_async(self.callbackQueue, ^{
                                                      block([GeoFire locationFromValue:snapshot.value]);
                                                  });
                                              }];
}

- (void)observeLocationOnceForKey:(NSString *)key withBlock:(GFLocationBlock)block
{
    [[self firebaseForLocationKey:key] observeSingleEventOfType:FEventTypeValue
                                                      withBlock:^(FDataSnapshot *snapshot) {
                                                          dispatch_async(self.callbackQueue, ^{
                                                              block([GeoFire locationFromValue:snapshot.value]);
                                                          });
                                                      }];
}

- (GFCircleQuery *)queryAtLocation:(CLLocationCoordinate2D)location withRadius:(double)radius
{
    return [[GFCircleQuery alloc] initWithGeoFire:self location:location radius:radius];
}

- (GFRegionQuery *)queryWithRegion:(MKCoordinateRegion)region
{
    return [[GFRegionQuery alloc] initWithGeoFire:self region:region];
}

@end
