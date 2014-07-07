//
//  GFQuery.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "GFQuery.h"
#import "GFQuery+Private.h"

@interface GFQuery ()

@property (nonatomic, readwrite) CLLocationCoordinate2D location;
@property (nonatomic, readwrite) double radius;
@property (nonatomic, strong) Firebase *firebase;

@end

@implementation GFQuery

- (id)initWithFirebase:(Firebase *)firebase
              location:(CLLocationCoordinate2D)location
                radius:(double)radius
{
    self = [super init];
    if (self != nil) {
        self->_firebase = firebase;
        self->_location = location;
        self->_radius = radius;
    }
    return self;
}

- (void)cancel
{

}

- (void)observeEventType:(GFEventType)eventType withBlock:(GFQueryResultBlock)block
{
    
}

@end
