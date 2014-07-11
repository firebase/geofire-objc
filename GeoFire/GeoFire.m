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

- (void)setLocation:(CLLocationCoordinate2D)location
             forKey:(NSString *)key
withCompletionBlock:(GFCompletionBlock)block
{

    NSNumber *lat = [NSNumber numberWithDouble:location.latitude];
    NSNumber *lng = [NSNumber numberWithDouble:location.longitude];
    NSString *geoHash = [GFGeoHash newWithLocation:location].geoHashValue;
    NSDictionary *value = @{ @"0": lat, @"1": lng };
    [self setLocationValue:value withGeoHash:geoHash forKey:key withBlock:block];
}

- (Firebase *)firebaseForLocationKey:(NSString *)key
{
    return [self.firebase childByAppendingPath:[NSString stringWithFormat:@"l/%@", key]];
}

- (void)setLocationValue:(id)value
             withGeoHash:(NSString *)geoHash
                  forKey:(NSString *)key
               withBlock:(GFCompletionBlock)block
{
    [[self firebaseForLocationKey:key] setValue:value
        andPriority:geoHash
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
    [self setLocationValue:nil withGeoHash:nil forKey:key withBlock:block];
}

+ (CLLocation *)locationFromValue:(id)value
{
    CLLocation *location = nil;
    if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
        id latNum, lngNum;
        if ([value isKindOfClass:[NSDictionary class]]) {
            latNum = [value objectForKey:@"0"];
            lngNum = [value objectForKey:@"1"];
        } else if ([value isKindOfClass:[NSArray class]] && [value count] == 2) {
            latNum = [value objectAtIndex:0];
            lngNum = [value objectAtIndex:1];
        } else {
            return nil;
        }
        if ([latNum isKindOfClass:[NSNumber class]] &&
            [lngNum isKindOfClass:[NSNumber class]]) {
            CLLocationDegrees lat = [latNum doubleValue];
            CLLocationDegrees lng = [lngNum doubleValue];
            if (CLLocationCoordinate2DIsValid(CLLocationCoordinate2DMake(lat, lng))) {
                location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
            }
        }
    }
    return location;
}

+ (NSDictionary *)dictFromLocation:(CLLocation *)location
{
    return @{ @"0" : [NSNumber numberWithDouble:location.coordinate.latitude],
              @"1" : [NSNumber numberWithDouble:location.coordinate.longitude] };
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
