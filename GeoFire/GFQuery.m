//
//  GFQuery.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "GFQuery.h"
#import "GFQuery+Private.h"
#import "GeoFire.h"
#import "GeoFire+Private.h"
#import "GFGeoHashQuery.h"

@interface GFQueryLocationInfo : NSObject

@property (nonatomic) BOOL isInQuery;
@property (nonatomic) CLLocation *location;
@property (nonatomic, strong) GFGeoHash *geoHash;

@end

@implementation GFQueryLocationInfo
@end

@interface GFGeoHashQueryHandle : NSObject

@property (nonatomic) FirebaseHandle childAddedHandle;
@property (nonatomic) FirebaseHandle childRemovedHandle;
@property (nonatomic) FirebaseHandle childChangedHandle;

@end

@implementation GFGeoHashQueryHandle

@end


@interface GFQuery ()

@property (nonatomic, strong) CLLocation *centerLocation;
@property (nonatomic, strong) NSMutableDictionary *locationInfos;
@property (nonatomic, strong) GeoFire *geoFire;
@property (nonatomic, strong) NSSet *queries;
@property (nonatomic, strong) NSMutableDictionary *firebaseHandles;

@property (nonatomic, strong) NSMutableDictionary *keyEnteredObservers;
@property (nonatomic, strong) NSMutableDictionary *keyExitedObservers;
@property (nonatomic, strong) NSMutableDictionary *keyMovedObservers;
@property (nonatomic) NSUInteger currentHandle;

@end

@implementation GFQuery

- (id)initWithGeoFire:(GeoFire *)geoFire
             location:(CLLocationCoordinate2D)location
               radius:(double)radius
{
    self = [super init];
    if (self != nil) {
        self->_geoFire = geoFire;
        self->_centerLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
        self->_radius = radius;
        self.currentHandle = 1;
        [self reset];
    }
    return self;
}

- (FQuery *)firebaseForGeoHashQuery:(GFGeoHashQuery *)query
{
    return [[[self.geoFire.firebase childByAppendingPath:@"l"] queryStartingAtPriority:query.startValue]
            queryEndingAtPriority:query.endValue];
}

- (BOOL)locationIsInQuery:(CLLocation *)location
{
    return [location distanceFromLocation:self.centerLocation] <= self.radius;
}

- (void)updateLocationInfo:(CLLocation *)location forKey:(NSString *)key
{
    GFQueryLocationInfo *info = self.locationInfos[key];
    BOOL isNew = NO;
    if (info == nil) {
        isNew = YES;
        info = [[GFQueryLocationInfo alloc] init];
        self.locationInfos[key] = info;
    }
    BOOL changedLocation = !(info.location.coordinate.latitude == location.coordinate.latitude &&
                             info.location.coordinate.longitude == location.coordinate.longitude);
    BOOL wasInQuery = info.isInQuery;

    info.location = location;
    info.isInQuery = [self locationIsInQuery:location];
    info.geoHash = [GFGeoHash newWithLocation:location.coordinate];

    if ((isNew || !wasInQuery) && info.isInQuery) {
        [self.keyEnteredObservers enumerateKeysAndObjectsUsingBlock:^(id observerKey,
                                                                      GFQueryResultBlock block,
                                                                      BOOL *stop) {
            dispatch_async(self.geoFire.callbackQueue, ^{
                block(key, info.location);
            });
        }];
    } else if (!isNew && changedLocation && info.isInQuery) {
        [self.keyMovedObservers enumerateKeysAndObjectsUsingBlock:^(id observerKey,
                                                                    GFQueryResultBlock block,
                                                                    BOOL *stop) {
            dispatch_async(self.geoFire.callbackQueue, ^{
                block(key, info.location);
            });
        }];
    } else if (wasInQuery && !info.isInQuery) {
        [self.keyExitedObservers enumerateKeysAndObjectsUsingBlock:^(id observerKey,
                                                                     GFQueryResultBlock block,
                                                                     BOOL *stop) {
            dispatch_async(self.geoFire.callbackQueue, ^{
                block(key, info.location);
            });
        }];
    }
}

- (void)childAdded:(FDataSnapshot *)snapshot
{
    @synchronized(self) {
        CLLocation *location = [GeoFire locationFromValue:snapshot.value];
        if (location != nil) {
            [self updateLocationInfo:location forKey:snapshot.name];
        } else {
            // TODO: error?
        }
    }
}

- (void)childChanged:(FDataSnapshot *)snapshot
{
    @synchronized(self) {
        CLLocation *location = [GeoFire locationFromValue:snapshot.value];
        if (location != nil) {
            [self updateLocationInfo:location forKey:snapshot.name];
        } else {
            // TODO: error?
        }
    }
}

- (void)childRemoved:(FDataSnapshot *)snapshot
{
    @synchronized(self) {
        GFQueryLocationInfo *info = self.locationInfos[snapshot.name];
        if (info) {
            [self.locationInfos removeObjectForKey:snapshot.name];
            [self.keyExitedObservers enumerateKeysAndObjectsUsingBlock:^(id observerKey,
                                                                         GFQueryResultBlock block,
                                                                         BOOL *stop) {
                dispatch_async(self.geoFire.callbackQueue, ^{
                    block(snapshot.name, info.location);
                });
            }];
        }
    }
}

- (void)updateQueries
{
    NSSet *oldQueries = self.queries;
    NSSet *newQueries = [GFGeoHashQuery queriesForLocation:self.centerLocation.coordinate radius:self.radius];
    NSMutableSet *toDelete = [NSMutableSet setWithSet:oldQueries];
    [toDelete minusSet:newQueries];
    NSMutableSet *toAdd = [NSMutableSet setWithSet:newQueries];
    [toAdd minusSet:oldQueries];
    [toDelete enumerateObjectsUsingBlock:^(GFGeoHashQuery *query, BOOL *stop) {
        GFGeoHashQueryHandle *handle = self.firebaseHandles[query];
        if (handle == nil) {
            [NSException raise:NSInternalInconsistencyException
                        format:@"Wanted to remove a geohash query that was not registered!"];
        }
        FQuery *queryFirebase = [self firebaseForGeoHashQuery:query];
        [queryFirebase removeObserverWithHandle:handle.childAddedHandle];
        [queryFirebase removeObserverWithHandle:handle.childChangedHandle];
        [queryFirebase removeObserverWithHandle:handle.childRemovedHandle];
        [self.firebaseHandles removeObjectForKey:handle];
    }];
    [toAdd enumerateObjectsUsingBlock:^(GFGeoHashQuery *query, BOOL *stop) {
        GFGeoHashQueryHandle *handle = [[GFGeoHashQueryHandle alloc] init];
        FQuery *queryFirebase = [self firebaseForGeoHashQuery:query];
        handle.childAddedHandle = [queryFirebase observeEventType:FEventTypeChildAdded
                                                        withBlock:^(FDataSnapshot *snapshot) {
                                                            [self childAdded:snapshot];
                                                        }];
        handle.childChangedHandle = [queryFirebase observeEventType:FEventTypeChildChanged
                                                          withBlock:^(FDataSnapshot *snapshot) {
                                                              [self childChanged:snapshot];
                                                          }];
        handle.childRemovedHandle = [queryFirebase observeEventType:FEventTypeChildRemoved
                                                          withBlock:^(FDataSnapshot *snapshot) {
                                                              [self childRemoved:snapshot];
                                                          }];
        self.firebaseHandles[query] = handle;
    }];
    self.queries = newQueries;
    [self.locationInfos enumerateKeysAndObjectsUsingBlock:^(id key, GFQueryLocationInfo *info, BOOL *stop) {
        [self updateLocationInfo:info.location forKey:key];
    }];
    NSMutableArray *oldLocations = [NSMutableArray array];
    [self.locationInfos enumerateKeysAndObjectsUsingBlock:^(id key, GFQueryLocationInfo *info, BOOL *stop) {
        BOOL inQuery = NO;
        for (GFGeoHashQuery *query in self.queries) {
            if ([query containsGeoHash:info.geoHash]) {
                inQuery = YES;
            }
        }
        if (!inQuery) {
            [oldLocations addObject:key];
        }
    }];
    [self.locationInfos removeObjectsForKeys:oldLocations];
}

- (void)reset
{
    for (GFGeoHashQuery *query in self.queries) {
        GFGeoHashQueryHandle *handle = self.firebaseHandles[query];
        if (handle == nil) {
            [NSException raise:NSInternalInconsistencyException
                        format:@"Wanted to remove a geohash query that was not registered!"];
        }
        FQuery *queryFirebase = [self firebaseForGeoHashQuery:query];
        [queryFirebase removeObserverWithHandle:handle.childAddedHandle];
        [queryFirebase removeObserverWithHandle:handle.childChangedHandle];
        [queryFirebase removeObserverWithHandle:handle.childRemovedHandle];
    }
    self.firebaseHandles = [NSMutableDictionary dictionary];
    self.queries = nil;
    self.keyEnteredObservers = [NSMutableDictionary dictionary];
    self.keyExitedObservers = [NSMutableDictionary dictionary];
    self.keyMovedObservers = [NSMutableDictionary dictionary];
    self.locationInfos = [NSMutableDictionary dictionary];
}

- (void)removeAllObservers
{
    @synchronized(self) {
        [self reset];
    }
}

- (void)removeObserverWithFirebaseHandle:(FirebaseHandle)firebaseHandle
{
    @synchronized(self) {
        NSNumber *handle = [NSNumber numberWithUnsignedInteger:firebaseHandle];
        [self.keyEnteredObservers removeObjectForKey:handle];
        [self.keyExitedObservers removeObjectForKey:handle];
        [self.keyMovedObservers removeObjectForKey:handle];
        if ([self totalObserverCount] == 0) {
            [self reset];
        }
    }
}

- (NSUInteger)totalObserverCount
{
    return self.keyEnteredObservers.count + self.keyExitedObservers.count + self.keyMovedObservers.count;
}

- (FirebaseHandle)observeEventType:(GFEventType)eventType withBlock:(GFQueryResultBlock)block
{
    @synchronized(self) {
        if (block == nil) {
            [NSException raise:NSInvalidArgumentException format:@"Block is not allowed to be nil!"];
        }
        FirebaseHandle firebaseHandle = self.currentHandle;
        NSNumber *numberHandle = [NSNumber numberWithUnsignedInteger:firebaseHandle];
        self.currentHandle++;
        switch (eventType) {
            case GFEventTypeKeyEntered: {
                [self.keyEnteredObservers setObject:[block copy]
                                             forKey:numberHandle];
                self.currentHandle++;
                dispatch_async(self.geoFire.callbackQueue, ^{
                    @synchronized(self) {
                        [self.locationInfos enumerateKeysAndObjectsUsingBlock:^(NSString *key,
                                                                                GFQueryLocationInfo *info,
                                                                                BOOL *stop) {
                            if (info.isInQuery) {
                                block(key, info.location);
                            }
                        }];
                    };
                });
                break;
            }
            case GFEventTypeKeyExited: {
                [self.keyExitedObservers setObject:[block copy]
                                            forKey:numberHandle];
                self.currentHandle++;
                break;
            }
            case GFEventTypeKeyMoved: {
                [self.keyMovedObservers setObject:[block copy]
                                           forKey:numberHandle];
                self.currentHandle++;
                break;
            }
            default: {
                [NSException raise:NSInvalidArgumentException format:@"Event type was not a GFEventType!"];
                break;
            }
        }
        if (self.queries == nil) {
            [self updateQueries];
        }
        return firebaseHandle;
    }
}

- (void)setCenter:(CLLocationCoordinate2D)center
{
    @synchronized(self) {
        self.centerLocation = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
        if (self.queries != nil) {
            [self updateQueries];
        }
    }
}

- (CLLocationCoordinate2D)center
{
    @synchronized(self) {
        return self.centerLocation.coordinate;
    }
}

- (void)setRadius:(double)radius
{
    @synchronized(self) {
        self->_radius = radius;
        if (self.queries != nil) {
            [self updateQueries];
        }
    }
}

@end
