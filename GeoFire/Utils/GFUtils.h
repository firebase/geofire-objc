/*
 * Firebase GeoFire iOS Library
 *
 * Copyright © 2020 Firebase - All Rights Reserved
 * https://firebase.google.com
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binaryform must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY FIREBASE AS IS AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL FIREBASE BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@class GFGeoQueryBounds;

/**
 * Utility methods for storing locations.
 */
@interface GFUtils : NSObject

/**
 * Returns a geohash for a given location with a default precision of 10.
 */
+ (NSString *)geoHashForLocation:(CLLocationCoordinate2D)location;

/**
 * Returns a geohash for a given location
 */
+ (NSString *)geoHashForLocation:(CLLocationCoordinate2D)location
                   withPrecision:(NSInteger)precision;

/**
 * Returns the distance between two locations in meters.
 */
+ (CLLocationDistance)distanceFromLocation:(CLLocation *)locationA
                                toLocation:(CLLocation *)locationB;

/**
 * Returns an array of bounds for a given coordinate and radius.
 * @param location The geographical center of the query-bounded area.
 * @param radius The radius in meters.
 */
+ (NSArray<GFGeoQueryBounds *> *)queryBoundsForLocation:(CLLocationCoordinate2D)location withRadius:(CLLocationDistance)radius;

@end

NS_ASSUME_NONNULL_END
