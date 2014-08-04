//
//  GeoFireTest.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/9/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GeoFire.h"
#import "GFRealDataTest.h"

@interface GeoFireTest : GFRealDataTest

@end

@implementation GeoFireTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
- (void)testGeoFireSetsLocations
{
    WAIT_SIGNALS(3, ^(dispatch_semaphore_t barrier) {
        [self.geoFire setLocation:L(0, 0)
                           forKey:@"loc1"
              withCompletionBlock:^(NSError *error) {
                  XCTAssertNil(error);
                  dispatch_semaphore_signal(barrier);
              }];
        [self.geoFire setLocation:L(50, 50)
                           forKey:@"loc2"
              withCompletionBlock:^(NSError *error) {
                  XCTAssertNil(error);
                  dispatch_semaphore_signal(barrier);
              }];
        [self.geoFire setLocation:L(-90, -90)
                           forKey:@"loc3"
              withCompletionBlock:^(NSError *error) {
                  XCTAssertNil(error);
                  dispatch_semaphore_signal(barrier);
              }];
    });

    WAIT_SIGNALS(1, (^(dispatch_semaphore_t barrier) {
        [self.firebaseRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            id expected =
            @{ @"loc1": @{ @"l": @[@0, @0], @"g": @"7zzzzzzzzz" },
               @"loc2": @{ @"l": @[@50, @50], @"g": @"v0gs3y0zh7" },
               @"loc3": @{ @"l": @[@-90, @-90], @"g": @"1bpbpbpbpb" }
               };
            XCTAssertEqualObjects(snapshot.value, expected);
            XCTAssertEqualObjects([snapshot childSnapshotForPath:@"loc1"].priority, @"7zzzzzzzzz");
            XCTAssertEqualObjects([snapshot childSnapshotForPath:@"loc2"].priority, @"v0gs3y0zh7");
            XCTAssertEqualObjects([snapshot childSnapshotForPath:@"loc3"].priority, @"1bpbpbpbpb");
            dispatch_semaphore_signal(barrier);
        }];
    }));
}
#pragma clang diagnostic pop

- (void)testGeoFireUpdates
{
    NSMutableArray *actual = [NSMutableArray array];
    WAIT_SIGNALS(5, (^(dispatch_semaphore_t barrier) {
        [self.geoFire observeLocationForKey:@"loc1" withBlock:^(CLLocation *location) {
            if (location != nil) {
                [actual addObject:[NSString stringWithFormat:@"[%f, %f]",
                                   location.coordinate.latitude, location.coordinate.longitude]];
            } else {
                [actual addObject:@"null"];
            }
            dispatch_semaphore_signal(barrier);
        }];
        [self.geoFire setLocation:L(0,0) forKey:@"loc1"]; // should fire
        [self.geoFire setLocation:L(0,0) forKey:@"loc1"]; // should not fire
        [self.geoFire setLocation:L(1,1) forKey:@"loc2"]; // should not fire
        [self.geoFire setLocation:L(2,1) forKey:@"loc1"]; // should fire
        [self.geoFire setLocation:L(0,0) forKey:@"loc1"]; // should fire
        [self.geoFire removeKey:@"loc1"]; // should fire
        [self.geoFire setLocation:L(0, 0) forKey:@"loc1"]; // should not fire
    }));

    NSArray *expected = @[@"[0.000000, 0.000000]",
                          @"[2.000000, 1.000000]",
                          @"[0.000000, 0.000000]",
                          @"null",
                          @"[0.000000, 0.000000]"];
    XCTAssertEqualObjects(actual, expected);
}

- (void)testInvalidCoordinates
{
    XCTAssertThrows([self.geoFire setLocation:L(-91, 90) forKey:@"key"]);
    XCTAssertThrows([self.geoFire setLocation:L(0, -180.1) forKey:@"key"]);
    XCTAssertThrows([self.geoFire setLocation:L(0, 181.1) forKey:@"key"]);
}

- (void)testRemoveObserver
{
    __block NSString *observedLocation = nil;
    WAIT_SIGNALS(1, (^(dispatch_semaphore_t barrier) {
        FirebaseHandle handle = [self.geoFire observeLocationForKey:@"loc1" withBlock:^(CLLocation *location) {
            XCTAssertNil(location);
        }];
        [self.geoFire observeLocationForKey:@"loc1" withBlock:^(CLLocation *location) {
            if (location != nil) {
                observedLocation = [NSString stringWithFormat:@"[%f,%f]", location.coordinate.latitude, location.coordinate.longitude];
                dispatch_semaphore_signal(barrier);
            }
        }];
        [self.geoFire removeObserverWithHandle:handle];
        [self.geoFire setLocation:L(1,1) forKey:@"loc1"];
    }));
    XCTAssertEqualObjects(observedLocation, @"[1.000000,1.000000]");
}

- (void)testRemoveAllObservers
{
    WAIT_SIGNALS(1, (^(dispatch_semaphore_t barrier) {
        [self.geoFire observeLocationForKey:@"loc1" withBlock:^(CLLocation *location) {
            XCTAssertNil(location);
        }];
        [self.geoFire observeLocationForKey:@"loc1" withBlock:^(CLLocation *location) {
            XCTAssertNil(location);
        }];
        [self.geoFire observeLocationForKey:@"loc2" withBlock:^(CLLocation *location) {
            XCTAssertNil(location);
        }];
        [self.geoFire removeAllObservers];
        [self.geoFire setLocation:L(1, 1) forKey:@"loc1" withCompletionBlock:^(NSError *error) {
            dispatch_semaphore_signal(barrier);
        }];
        [self.geoFire setLocation:L(1, 1) forKey:@"loc2" withCompletionBlock:^(NSError *error) {
            dispatch_semaphore_signal(barrier);
        }];
    }));
}

@end
