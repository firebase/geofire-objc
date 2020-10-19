//
//  GeoFireUtils.m
//  GeoFire
//
//  Copyright (c) 2020 Firebase. All rights reserved.
//

#import "GeoFireUtils.h"

@implementation GeoFireUtils

+ (NSString *)getGeoHashForLocation:(CLLocation *)location
{
    // TODO: What about precision?
    return NSString *geoHash = [GFGeoHash newWithLocation:location.coordinate].geoHashValue;;
}

+ (NSString *)getGeoHashForLocation:(CLLocation *)location
                      withPrecision:(int)precision
{
    // TODO: Implement
    return "";
}

// TODO: Probably delete this method
+ (double)getDistanceBetween:(CLLocation *)locationA
                 andLocation:(CLLocation *)locationB
{
    return [locationA distanceFromLocation:locationB];
}

- (NSArray<GFGeoHashQuery *>)getQueryBounds:(CLLocation *)location
                                  forRadius:(double)radius {
    // TODO: Implement
    return nil;
}

@end
