/*
 * Firebase GeoFire iOS Library
 *
 * Copyright © 2014 Firebase - All Rights Reserved
 * https://www.firebase.com
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
#import <Firebase/Firebase.h>

@class GeoFire;

typedef enum {
    GFEventTypeKeyEntered,
    GFEventTypeKeyExited,
    GFEventTypeKeyMoved
} GFEventType;

typedef void (^GFQueryResultBlock) (NSString *key, CLLocation *location);

/**
 * A GFQuery object handles geo queries at a Firebase location.
 */
@interface GFQuery : NSObject

/**
 * The center of the search area. Update this value to update the query. Events are triggered for any keys that move
 * in or out of the search area
 */
@property (nonatomic, readwrite) CLLocationCoordinate2D center;

/**
 * The radius of the geo query. Update this value to update the query. Events are triggered for any keys that move
 * in or out of the search area
 */
@property (nonatomic, readwrite) double radius;

/**
 * The GeoFire this GFQuery object uses
 */
@property (nonatomic, strong, readonly) GeoFire *geoFire;

/**
 * Add an observer for an event type.
 * The following event types are supported
 *
 *     typedef enum {
 *       GFEventTypeKeyEntered, // A key entered the search area
 *       GFEventTypeKeyExited,  // A key exited the search area
 *       GFEventTypeKeyMoved    // A key moved within the search area
 *     } GFEventType;
 *
 * The block is called for each event and key.
 *
 * Use removeObserverWithFirebaseHandle: to stop receiving callbacks.
 * 
 * @param eventType The event type to receive updates for
 * @param block The block that is called for updates
 * @return A handle to remove the observer with
 */
- (FirebaseHandle)observeEventType:(GFEventType)eventType withBlock:(GFQueryResultBlock)block;

/**
 * Removes a callback with a given FirebaseHandle. After this no further updates are received for this handle
 * @param handle The handle that was returned by observeEventType:withBlock:
 */
- (void)removeObserverWithFirebaseHandle:(FirebaseHandle)handle;

/**
 * Removes all observers for this GFQuery object. Note that with multiple GFQuery objects only this object stops
 * it's callbacks
 */
- (void)removeAllObservers;

@end
