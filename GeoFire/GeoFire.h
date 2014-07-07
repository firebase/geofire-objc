//
//  GeoFire.h
//  GeoFire
//
//  Created by Jonny Dimond on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <CoreLocation/CoreLocation.h>

#import "GFQuery.h"

typedef void (^GFCompletionBlock) (NSError *error);
typedef void (^GFLocationBlock) (CLLocation *location);

@interface GeoFire : NSObject

@property (nonatomic, strong, readonly) Firebase *firebase;

- (id)initWithFirebase:(Firebase *)firebase;

+ (GeoFire *)newWithFirebase:(Firebase *)firebase;

/*
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
               forKey:(NSString *)key;

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
               forKey:(NSString *)key
  withCompletionBlock:(GFCompletionBlock)block;

- (void)removeKey:(NSString *)key;

- (void)observeCoordinateForKey:(NSString *)key
                      withBlock:(GFLocationBlock)block;

- (void)observeCoordinateOnceForKey:(NSString *)key
                          withBlock:(GFLocationBlock)block;

- (GFQuery *)queryAtCoordinate:(CLLocationCoordinate2D)coordinate
                    withRadius:(double)radius;
 */

@end
