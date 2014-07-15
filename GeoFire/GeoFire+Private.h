//
//  GeoFire+Private.h
//  GeoFire
//
//  Created by Jonny Dimond on 7/7/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <GeoFire/GeoFire.h>
#import <CoreLocation/CoreLocation.h>

@interface GeoFire (Private)

- (Firebase *)firebaseRefForLocationKey:(NSString *)key;

+ (CLLocation *)locationFromValue:(id)dict;
+ (NSDictionary *)dictFromLocation:(CLLocation *)location;

@end
