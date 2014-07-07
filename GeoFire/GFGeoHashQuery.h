//
//  GFGeoHashQuery.h
//  GeoFire
//
//  Created by Jonny Dimond on 7/7/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "GFGeoHash.h"

@interface GFGeoHashQuery : NSObject<NSCopying>

@property (nonatomic, strong, readonly) NSString *startValue;
@property (nonatomic, strong, readonly) NSString *endValue;

+ (NSSet *)queriesForLocation:(CLLocationCoordinate2D)location radius:(double)radius;

- (BOOL)containsGeoHash:(GFGeoHash *)hash;

@end
