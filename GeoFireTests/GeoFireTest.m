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
        [self.firebaseRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
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

- (void)testGeoFireGetLocation
{
    NSMutableArray *actual = [NSMutableArray array];
    WAIT_SIGNALS(5, (^(dispatch_semaphore_t barrier) {
        [self.geoFire getLocationForKey:@"loc1" withCallback:^(CLLocation *location, NSError *error) {
            [actual addObject:@"null"];
            XCTAssertNil(error);
            dispatch_semaphore_signal(barrier);
        }];

        [self.geoFire setLocation:L(0,0) forKey:@"loc1"];
        [self.geoFire getLocationForKey:@"loc1" withCallback:^(CLLocation *location, NSError *error) {
            [actual addObject:L2S(location)];
            XCTAssertNil(error);
            dispatch_semaphore_signal(barrier);
        }];

        [self.geoFire setLocation:L(1,1) forKey:@"loc2"];
        [self.geoFire getLocationForKey:@"loc2" withCallback:^(CLLocation *location, NSError *error) {
            [actual addObject:L2S(location)];
            XCTAssertNil(error);
            dispatch_semaphore_signal(barrier);
        }];

        [self.geoFire setLocation:L(5,5) forKey:@"loc1"];
        [self.geoFire getLocationForKey:@"loc1" withCallback:^(CLLocation *location, NSError *error) {
            [actual addObject:L2S(location)];
            XCTAssertNil(error);
            dispatch_semaphore_signal(barrier);
        }];

        [self.geoFire removeKey:@"loc1"];
        [self.geoFire getLocationForKey:@"loc1" withCallback:^(CLLocation *location, NSError *error) {
            [actual addObject:@"null"];
            XCTAssertNil(error);
            dispatch_semaphore_signal(barrier);
        }];
    }));

    NSArray *expected = @[@"null",
                          @"[0.000000, 0.000000]",
                          @"[1.000000, 1.000000]",
                          @"[5.000000, 5.000000]",
                          @"null"];
    XCTAssertEqualObjects(actual, expected);
}

- (void)testErrorOnInvalidData
{
    NSMutableArray *actual = [NSMutableArray array];
    FIRDatabaseReference *firebase1 = [self.geoFire.firebaseRef child:@"loc1"];
    FIRDatabaseReference *firebase2 = [self.geoFire.firebaseRef child:@"loc2"];
    WAIT_SIGNALS(2, (^(dispatch_semaphore_t barrier) {
        [firebase1 setValue:@"NaN" withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            XCTAssertNil(error);
            dispatch_semaphore_signal(barrier);
        }];
        [firebase2 setValue:@{ @"l": @10, @"g": @"abc" } withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            XCTAssertNil(error);
            dispatch_semaphore_signal(barrier);
        }];
    }));
    WAIT_SIGNALS(2, (^(dispatch_semaphore_t barrier) {
        [self.geoFire getLocationForKey:@"loc1" withCallback:^(CLLocation *location, NSError *error) {
            if (error) {
                [actual addObject:error.domain];
            } else {
                XCTFail("Didn't receive an error!");
            }
            dispatch_semaphore_signal(barrier);
        }];
        [self.geoFire getLocationForKey:@"loc2" withCallback:^(CLLocation *location, NSError *error) {
            if (error) {
                [actual addObject:error.domain];
            } else {
                XCTFail("Didn't receive an error!");
            }
            dispatch_semaphore_signal(barrier);
        }];
   }));
    NSArray *expected = @[@"com.firebase.geofire", @"com.firebase.geofire"];
    XCTAssertEqualObjects(actual, expected);
}


- (void)testInvalidCoordinates
{
    XCTAssertThrows([self.geoFire setLocation:L(-91, 90) forKey:@"key"]);
    XCTAssertThrows([self.geoFire setLocation:L(0, -180.1) forKey:@"key"]);
    XCTAssertThrows([self.geoFire setLocation:L(0, 181.1) forKey:@"key"]);
}

#pragma clang diagnostic pop

@end
