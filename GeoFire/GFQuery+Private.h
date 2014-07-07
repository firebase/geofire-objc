//
//  GFQuery+Private.h
//  GeoFire
//
//  Created by Jonny Dimond on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "GFQuery.h"
#import <CoreLocation/CoreLocation.h>
#import <Firebase/Firebase.h>

@interface GFQuery (Private)

- (id)initWithFirebase:(Firebase *)firebase
              location:(CLLocationCoordinate2D)location
                radius:(double)radius;

@end
