//
//  GeoFire.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "GeoFire.h"
#import "GFGeoHash.h"

@interface GeoFire ()

@property (nonatomic, strong, readwrite) Firebase *firebase;

@end

@implementation GeoFire

- (id)init
{
    [NSException raise:NSGenericException
                format:@"init is not supported. Please us %@ instead",
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

- (void)setLocationValue:(id)value
             withGeoHash:(NSString *)geoHash
                  forKey:(NSString *)key withBlock:(GFCompletionBlock)block
{
    Firebase *child = [self.firebase childByAppendingPath:[NSString stringWithFormat:@"l/%@", key]];
    [child setValue:value
        andPriority:geoHash
withCompletionBlock:^(NSError *error, Firebase *ref) {
    if (block != nil) {
        block(error);
    }
}];
}

- (void)setLocation:(CLLocationCoordinate2D)location
             forKey:(NSString *)key
withCompletionBlock:(GFCompletionBlock)block
{

    NSNumber *lat = [NSNumber numberWithDouble:location.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:location.longitude];
    NSString *geoHash = [GFGeoHash newWithLocation:location].geoHashValue;
    NSDictionary *value = @{ @"0": lat, @"1": lon };
    [self setLocationValue:value withGeoHash:geoHash forKey:key withBlock:block];

}

- (void)deleteLocationForKey:(NSString *)key
{
    [self setLocationValue:nil withGeoHash:nil forKey:key withBlock:nil];
}

- (GFQuery *)queryAtCoordinate:(CLLocationCoordinate2D)coordinate
                    withRadius:(double)radius
{
    return [[GFQuery alloc] init];
}

@end
