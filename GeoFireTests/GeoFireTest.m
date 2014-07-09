//
//  GeoFireTest.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/9/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GeoFire.h"
#import "TestHelpers.h"

@interface GeoFireTest : XCTestCase

@property (nonatomic, strong) GeoFire *geoFire;
@property (nonatomic, strong) Firebase *firebase;

@end

#define TEST_TIMEOUT_SECONDS 10

#define WAIT_SIGNALS(__count, __block)\
do { \
  dispatch_semaphore_t __barrier = dispatch_semaphore_create(0); \
  __block(__barrier); \
  CFAbsoluteTime start = CFAbsoluteTimeGetCurrent(); \
  for (NSUInteger __i = 0; __i < __count; __i++) { \
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent(); \
    NSUInteger remainingMsecs = (int)(fmax(0, (TEST_TIMEOUT_SECONDS - (now-start))*1000)); \
    if (remainingMsecs == 0) { \
      XCTFail(@"Timeout occured!"); \
    } else { \
      XCTAssertEqual(dispatch_semaphore_wait(__barrier, \
                                             dispatch_time(DISPATCH_TIME_NOW, remainingMsecs * NSEC_PER_MSEC)), \
                     0, \
                     @"Timeout occured!"); \
    } \
  } \
} while(0)

@implementation GeoFireTest

- (void)setUp
{
    [super setUp];
    NSString *randomFirebaseURL = [NSString stringWithFormat:@"https://%@.firebaseio-demo.com",
                                   [TestHelpers randomAlphaNumericStringWithLength:16]];
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.firebase.test", NULL);
    [Firebase setDispatchQueue:backgroundQueue];
    self.firebase = [[Firebase alloc] initWithUrl:randomFirebaseURL];
    self.geoFire = [GeoFire newWithFirebase:self.firebase];
    self.geoFire.callbackQueue = backgroundQueue;
}

- (void)tearDown
{
    [super tearDown];
    dispatch_semaphore_t wait = dispatch_semaphore_create(0);
    [self.firebase setValue:nil withCompletionBlock:^(NSError *error, Firebase *ref) {
        dispatch_semaphore_signal(wait);
    }];
    dispatch_semaphore_wait(wait, dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC));
}

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
