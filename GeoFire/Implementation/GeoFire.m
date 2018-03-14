//
//  GeoFire.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <FirebaseDatabase/FirebaseDatabase.h>

#import "GeoFire.h"
#import "GeoFire+Private.h"
#import "GFGeoHash.h"
#import "GFQuery+Private.h"

NSString * const kGeoFireErrorDomain = @"com.firebase.geofire";

enum {
    GFParseError = 1000
};

@interface GeoFire ()

@property (nonatomic, strong, readwrite) FIRDatabaseReference *firebaseRef;

@end

@implementation GeoFire

- (id)init
{
    [NSException raise:NSGenericException
                format:@"init is not supported. Please use %@ instead",
     NSStringFromSelector(@selector(initWithFirebaseRef:))];
    return nil;
}

- (id)initWithFirebaseRef:(FIRDatabaseReference *)firebaseRef locationProperties:(CLLocationProperties)locationProperties
{
    self = [super init];
    if (self != nil) {
        if (firebaseRef == nil) {
            [NSException raise:NSInvalidArgumentException format:@"Firebase was nil!"];
        }
        self->_firebaseRef = firebaseRef;
        self->_callbackQueue = dispatch_get_main_queue();

		self->_locationProperties = locationProperties;
    }
    return self;
}

- (id)initWithFirebaseRef:(FIRDatabaseReference *)firebase {
	return [self initWithFirebaseRef:firebase locationProperties:0];
}

- (void)setLocation:(CLLocation *)location forKey:(NSString *)key
{
    [self setLocation:location forKey:key withCompletionBlock:nil];
}

- (void)setLocation:(CLLocation *)location
             forKey:(NSString *)key
withCompletionBlock:(GFCompletionBlock)block
{
    if (!CLLocationCoordinate2DIsValid(location.coordinate)) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Not a valid coordinate: [%f, %f]",
         location.coordinate.latitude, location.coordinate.longitude];
    }
    [self setLocationValue:location
                    forKey:key
                 withBlock:block];
}

- (FIRDatabaseReference *)firebaseRefForLocationKey:(NSString *)key
{
    static NSCharacterSet *illegalCharacters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        illegalCharacters = [NSCharacterSet characterSetWithCharactersInString:@".#$][/"];
    });
    if ([key rangeOfCharacterFromSet:illegalCharacters].location != NSNotFound) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Not a valid GeoFire key: \"%@\". Characters .#$][/ not allowed in key!", key];
    }
    return [self.firebaseRef child:key];
}

- (void)setLocationValue:(CLLocation *)location
                  forKey:(NSString *)key
               withBlock:(GFCompletionBlock)block
{
    NSMutableDictionary *value;
    NSString *priority;
    if (location != nil) {
        NSNumber *lat = [NSNumber numberWithDouble:location.coordinate.latitude];
        NSNumber *lng = [NSNumber numberWithDouble:location.coordinate.longitude];
        NSString *geoHash = [GFGeoHash newWithLocation:location.coordinate].geoHashValue;

		value = [NSMutableDictionary dictionaryWithCapacity:8];
		value[@"l"] = @[ lat, lng ];
		value[@"g"] = geoHash;
		if (self.locationProperties & CLLocationPropertyAltitude)
			value[@"a"] = [NSNumber numberWithDouble:location.altitude];
		if (self.locationProperties & CLLocationPropertyHorizontalAccuracy)
			value[@"h"] = [NSNumber numberWithDouble:location.horizontalAccuracy];
		if (self.locationProperties & CLLocationPropertyVerticalAccuracy)
			value[@"v"] = [NSNumber numberWithDouble:location.verticalAccuracy];
		if (self.locationProperties & CLLocationPropertyCourse)
			value[@"c"] = [NSNumber numberWithDouble:location.course];
		if (self.locationProperties & CLLocationPropertySpeed)
			value[@"s"] = [NSNumber numberWithDouble:location.speed];
		if (self.locationProperties & CLLocationPropertyTimestamp)
			value[@"t"] = [NSNumber numberWithDouble:[location.timestamp timeIntervalSinceReferenceDate]];

        priority = geoHash;
    } else {
        value = nil;
        priority = nil;
    }
    [[self firebaseRefForLocationKey:key] setValue:value
                                       andPriority:priority
                               withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        if (block != nil) {
            dispatch_async(self.callbackQueue, ^{
                block(error);
            });
        }
    }];
}

- (void)removeKey:(NSString *)key
{
    [self removeKey:key withCompletionBlock:nil];
}

- (void)removeKey:(NSString *)key withCompletionBlock:(GFCompletionBlock)block
{
    [self setLocationValue:nil forKey:key withBlock:block];
}

+ (CLLocation *)locationFromValue:(id)value
{
    if ([value isKindOfClass:[NSDictionary class]] && [value objectForKey:@"l"] != nil) {
        id locObj = [value objectForKey:@"l"];
        if ([locObj isKindOfClass:[NSArray class]] && [locObj count] == 2) {
            id latNum = [locObj objectAtIndex:0];
            id lngNum = [locObj objectAtIndex:1];
            if ([latNum isKindOfClass:[NSNumber class]] &&
                [lngNum isKindOfClass:[NSNumber class]]) {
                CLLocationDegrees lat = [latNum doubleValue];
                CLLocationDegrees lng = [lngNum doubleValue];
				if (CLLocationCoordinate2DIsValid(CLLocationCoordinate2DMake(lat, lng))) {
					id a = [value objectForKey:@"a"];
					id h = [value objectForKey:@"h"];
					id v = [value objectForKey:@"v"];
					id c = [value objectForKey:@"c"];
					id s = [value objectForKey:@"s"];
					id t = [value objectForKey:@"t"];

					CLLocationDistance altitude = [a isKindOfClass:[NSNumber class]] ? [a doubleValue] : 0.0;
					CLLocationAccuracy horizontalAccuracy = [h isKindOfClass:[NSNumber class]] ? [h doubleValue] : 0.0;
					CLLocationAccuracy verticalAccuracy = [v isKindOfClass:[NSNumber class]] ? [v doubleValue] : -1.0;
					CLLocationDirection course = [c isKindOfClass:[NSNumber class]] ? [c doubleValue] : -1.0;
					CLLocationSpeed speed = [s isKindOfClass:[NSNumber class]] ? [s doubleValue] : -1.0;
					NSDate *timestamp = [t isKindOfClass:[NSNumber class]] ? [NSDate dateWithTimeIntervalSinceReferenceDate:[t doubleValue]] : [NSDate date];

                    return [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lng) altitude:altitude horizontalAccuracy:horizontalAccuracy verticalAccuracy:verticalAccuracy course:course speed:speed timestamp:timestamp];
                }
            }
        }
    }
    return nil;
}

- (void)getLocationForKey:(NSString *)key withCallback:(GFCallbackBlock)callback
{
    [[self firebaseRefForLocationKey:key]
     observeSingleEventOfType:FIRDataEventTypeValue
     withBlock:^(FIRDataSnapshot *snapshot) {
         dispatch_async(self.callbackQueue, ^{
             if (snapshot.value == nil || [snapshot.value isMemberOfClass:[NSNull class]]) {
                 callback(nil, nil);
             } else {
                 CLLocation *location = [GeoFire locationFromValue:snapshot.value];
                 if (location != nil) {
                     callback(location, nil);
                 } else {
                     NSMutableDictionary* details = [NSMutableDictionary dictionary];
                     [details setValue:[NSString stringWithFormat:@"Unable to parse location value: %@", snapshot.value]
                                forKey:NSLocalizedDescriptionKey];
                     NSError *error = [NSError errorWithDomain:kGeoFireErrorDomain code:GFParseError userInfo:details];
                     callback(nil, error);
                 }
             }
         });
     } withCancelBlock:^(NSError *error) {
         dispatch_async(self.callbackQueue, ^{
             callback(nil, error);
         });
     }];
}

- (GFCircleQuery *)queryAtLocation:(CLLocation *)location withRadius:(double)radius
{
    return [[GFCircleQuery alloc] initWithGeoFire:self location:location radius:radius];
}

- (GFRegionQuery *)queryWithRegion:(MKCoordinateRegion)region
{
    return [[GFRegionQuery alloc] initWithGeoFire:self region:region];
}

@end
