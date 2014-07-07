//
//  GFQuery.h
//  GeoFire
//
//  Created by Jonny Dimond on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Firebase/Firebase.h>

typedef enum {
    GFEventTypeKeyEntered,
    GFEventTypeKeyExited,
    GFEventTypeKeyMoved
} GFEventType;

typedef void (^GFQueryResultBlock) (NSString *key, CLLocation *location);

@interface GFQuery : NSObject

@property (nonatomic, readonly) double radius;
@property (nonatomic, readonly) CLLocationCoordinate2D location;
@property (nonatomic, strong, readonly) Firebase *firebase;

/* TODO: cancel queries */

- (FirebaseHandle)observeEventType:(GFEventType)eventType withBlock:(GFQueryResultBlock)block;
- (void)removeObserverWithFirebaseHandle:(FirebaseHandle)handle;
- (void)removeAllObservers;

@end
