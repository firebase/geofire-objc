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
        [self.geoFire setLocation:CLLocationCoordinate2DMake(0, 0)
                           forKey:@"loc1"
              withCompletionBlock:^(NSError *error) {
                  XCTAssertNil(error);
                  dispatch_semaphore_signal(barrier);
              }];
        [self.geoFire setLocation:CLLocationCoordinate2DMake(50, 50)
                           forKey:@"loc2"
              withCompletionBlock:^(NSError *error) {
                  XCTAssertNil(error);
                  dispatch_semaphore_signal(barrier);
              }];
        [self.geoFire setLocation:CLLocationCoordinate2DMake(-90, -90)
                           forKey:@"loc3"
              withCompletionBlock:^(NSError *error) {
                  XCTAssertNil(error);
                  dispatch_semaphore_signal(barrier);
              }];
    });

    WAIT_SIGNALS(1, (^(dispatch_semaphore_t barrier) {
        [self.firebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            id expected =
            @{ @"l":
                   @{ @"loc1": @[@0, @0],
                      @"loc2": @[@50,@50],
                      @"loc3": @[@-90, @-90] }
               };
            XCTAssertEqualObjects(snapshot.value, expected);
            XCTAssertEqualObjects([snapshot childSnapshotForPath:@"l/loc1"].priority, @"7zzzzzzzzz");
            XCTAssertEqualObjects([snapshot childSnapshotForPath:@"l/loc2"].priority, @"v0gs3y0zh7");
            XCTAssertEqualObjects([snapshot childSnapshotForPath:@"l/loc3"].priority, @"1bpbpbpbpb");
            dispatch_semaphore_signal(barrier);
        }];
    }));
}
#pragma clang diagnostic pop

@end
