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
#import <Firebase/Firebase.h>
#import <CoreLocation/CoreLocation.h>

#import "GFQuery.h"

typedef void (^GFCompletionBlock) (NSError *error);
typedef void (^GFLocationBlock) (CLLocation *location);

/**
 * A GeoFire instance is used to store geo data at a Firebase location
 */
@interface GeoFire : NSObject

/**
 * The Firebase location this GeoFire instance uses
 */
@property (nonatomic, strong, readonly) Firebase *firebase;

/**
 * The dispatch queue this GeoFire object and all it's GFQueries use for callbacks
 */
@property (nonatomic, strong) dispatch_queue_t callbackQueue;

/** @name Creating new GeoFire's */

/**
 * Initializes a new GeoFire instance at the given Firebase location
 * @param firebase The Firebase location to attach this GeoFire instance to
 * @return The new GeoFire instance
 */
- (id)initWithFirebase:(Firebase *)firebase;

/**
 * Creates a new GeoFire instance at the given Firebase location
 * @param firebase The Firebase location to attach this GeoFire instance to
 * @return The new GeoFire instance
 */
+ (GeoFire *)newWithFirebase:(Firebase *)firebase;

/** @name Setting and Updating Locations */

/**
 * Updates the location for a key
 * @param location The location as a geographic coordinate
 * @param key The key for which this location is saved
 */
- (void)setLocation:(CLLocationCoordinate2D)location
             forKey:(NSString *)key;

/**
 * Updates the location for a key and calls the completion callback once the location was successfully updated on the
 * server.
 * @param location The location as a geographic coordinate
 * @param key The key for which this location is saved
 * @param block The completion block that is called once the location was successfully updated on the server
 */
- (void)setLocation:(CLLocationCoordinate2D)location
             forKey:(NSString *)key
withCompletionBlock:(GFCompletionBlock)block;

/**
 * Removes the location for a given key.
 * @param key The key for which the location is removed
 */
- (void)removeKey:(NSString *)key;

/**
 * Removes the location for a given key and calls the completion callback once the location was successfully updated on
 * the server.
 * @param key The key for which the location is removed
 * @param block The completion block that is called once the location was successfully updated on the server
 */
- (void)removeKey:(NSString *)key withCompletionBlock:(GFCompletionBlock)block;

/**
 * Observes the location for a given key and calls the callback once for the initial location and subsequentially for
 * every update of the location.
 * Calls the callback with nil if no location is specified.
 * @param key The key to observe the location for
 * @param block The block that is called for every update of the location
 */
- (void)observeLocationForKey:(NSString *)key
                    withBlock:(GFLocationBlock)block;

/**
 * Gets the location for a given key exactly once. No updates are called for updates on the location.
 * @param key The key to observe the location for
 * @param block The block that is called for once for the location
 */
 - (void)observeLocationOnceForKey:(NSString *)key
                         withBlock:(GFLocationBlock)block;

/**
 * Creates a new GeoFire query at a given location with a radius. The GFQuery object can be used to query
 * keys that enter, move, and exit the search radius.
 * @param location The location at which the query is centered
 * @param radius The radius of the geo query
 * @return The GFQuery object that can be used to for geo queries.
 */
- (GFQuery *)queryAtLocation:(CLLocationCoordinate2D)location
                  withRadius:(double)radius;

@end
