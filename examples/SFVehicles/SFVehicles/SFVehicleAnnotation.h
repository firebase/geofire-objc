//
//  SFVehicleAnnotation.h
//  SFVehicles
//
//  Created by Jonny Dimond on 7/7/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SFVehicleAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
