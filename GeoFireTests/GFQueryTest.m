//
//  GFQueryTest.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/9/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GFRealDataTest.h"

@interface GFQueryTest : GFRealDataTest

@end

@implementation GFQueryTest

#define SETLOC(k,x,y) [self.geoFire setLocation:L(x,y) forKey:k]
#define SETLOC_WAIT_COMPLETE(k,x,y) \
do { \
  dispatch_semaphore_t __lock = dispatch_semaphore_create(0); \
  [self.geoFire setLocation:L(x,y) forKey:k withCompletionBlock:^(NSError *error) { \
    if (error != nil) { \
      XCTFail("Error occured saving: %@", error); \
    } \
    dispatch_semaphore_signal(__lock); \
  }]; \
  dispatch_semaphore_wait(__lock, dispatch_time(DISPATCH_TIME_NOW, TEST_TIMEOUT_SECONDS*NSEC_PER_SEC)); \
} while(0)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
- (void)testKeyEntered
{
    SETLOC(@"0", 0, 0);
    SETLOC(@"1", 37.0000, -122.0000);
    SETLOC(@"2", 37.0001, -122.0001);
    SETLOC(@"3", 37.1000, -122.0000);
    SETLOC(@"4", 37.0002, -121.9998);
    GFQuery *query = [self.geoFire queryAtLocation:L(37,-122) withRadius:0.5];
    NSMutableDictionary *actual = [NSMutableDictionary dictionary];
    WAIT_SIGNALS(3, ^(dispatch_semaphore_t barrier) {
        [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
            if ([actual objectForKey:key] == nil) {
                actual[key] = L2S(location);
            } else {
                XCTFail(@"Key entered twice!");
            }
            dispatch_semaphore_signal(barrier);
        }];
    });
    NSDictionary *expected = @{ @"1": L2S(L(37,-122)), @"2": L2S(L(37.0001, -122.0001)), @"4": L2S(L(37.0002, -121.9998)) };
    XCTAssertEqualObjects(actual, expected);
    [query removeAllObservers];
}

- (void)testKeyExited
{
    SETLOC(@"0", 0, 0);
    SETLOC(@"1", 37.0000, -122.0000);
    SETLOC(@"2", 37.0001, -122.0001);
    SETLOC(@"3", 37.1000, -122.0000);
    SETLOC(@"4", 37.0002, -121.9998);
    GFQuery *query = [self.geoFire queryAtLocation:L(37,-122) withRadius:0.5];
    NSMutableSet *actual = [NSMutableSet set];
    [query observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        if (![actual containsObject:key]) {
            [actual addObject:key];
            if (location != nil) {
                [actual addObject:L2S(location)];
            } else {
                [actual addObject:@"null"];
            }
        } else {
            XCTFail(@"Key exited twice!");
        }
    }];
    SETLOC(@"0", 0, 0);
    [self.geoFire removeKey:@"2"]; // exited
    SETLOC_WAIT_COMPLETE(@"1", 0, 0);
    SETLOC(@"3", 2, 0); // not in query
    SETLOC(@"0", 3, 0); // not in query
    SETLOC(@"1", 4, 0); // not in query
    SETLOC_WAIT_COMPLETE(@"2", 5, 0); // not in query

    NSSet *expected = [NSSet setWithArray:@[@"1", L2S(L(0,0)), @"2", @"null"]];
    XCTAssertEqualObjects(actual, expected);
    [query removeAllObservers];
}

- (void)testKeyMoved
{
    SETLOC(@"0", 0, 0);
    SETLOC(@"1", 37.0000, -122.0000);
    SETLOC(@"2", 37.0001, -122.0001);
    SETLOC(@"3", 37.1000, -122.0000);
    SETLOC(@"4", 37.0002, -121.9998);
    GFQuery *query = [self.geoFire queryAtLocation:L(37,-122) withRadius:0.5];
    NSMutableArray *actual = [NSMutableArray array];
    WAIT_SIGNALS(4, ^(dispatch_semaphore_t barrier) {
        [query observeEventType:GFEventTypeKeyMoved withBlock:^(NSString *key, CLLocation *location) {
            [actual addObject:key];
            [actual addObject:L2S(location)];
            dispatch_semaphore_signal(barrier);
        }];
        SETLOC(@"0", 1, 1); // outside of query
        SETLOC(@"1", 37.0001, -122.0000); // moved
        SETLOC(@"2", 37.0001, -122.0001); // location stayed the same
        SETLOC(@"4", 37.0002, -122.0000); // moved
        SETLOC(@"3", 37.0000, -122.0000); // entered
        SETLOC(@"3", 37.0003, -122.0003); // moved
        SETLOC_WAIT_COMPLETE(@"2", 0, 0); // exited, wait for exited event
        SETLOC(@"2", 37.0000, -122.0000); // entered
        SETLOC(@"2", 37.0001, -122.0001); // moved
    });
    NSArray *expected = @[ @"1", L2S(L(37.0001, -122.0000)),
                           @"4", L2S(L(37.0002, -122.0000)),
                           @"3", L2S(L(37.0003, -122.0003)),
                           @"2", L2S(L(37.0001, -122.0001))];



    XCTAssertEqualObjects(actual, expected);
    [query removeAllObservers];
}

- (void)testEventuallyConsistent
{
    SETLOC(@"1", 0.0001, 0.0001);
    SETLOC(@"2", -0.0001, 0.0001);
    SETLOC(@"3", 0.0001, -0.0001);
    SETLOC(@"4", -0.0001, -0.0001);
    GFQuery *query = [self.geoFire queryAtLocation:L(0,0) withRadius:0.5];
    NSMutableDictionary *actual = [NSMutableDictionary dictionary];
    [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        actual[key] = L2S(location);
    }];
    [query observeEventType:GFEventTypeKeyMoved withBlock:^(NSString *key, CLLocation *location) {
        actual[key] = L2S(location);
    }];
    [query observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        if (location == nil) {
            actual[key] = @"null";
        } else {
            actual[key] = L2S(location);
        }
    }];
    SETLOC(@"1", 0.0002, 0.0001); // moved
    SETLOC(@"1", 10, 11); // exited
    SETLOC(@"1", 0.0002, 0.0001);

    SETLOC(@"4", 0.0001, -0.0001); // moved
    SETLOC(@"4", -0.0001, 0.0001); // moved
    SETLOC(@"4", 10, 10); // exited
    SETLOC(@"4", 0, 0); // entered
    SETLOC(@"4", 0.0001, 0.0001); // moved

    [self.geoFire removeKey:@"3"]; // exited
    SETLOC(@"3", 0.0001, 0.0001); // entered

    SETLOC(@"2", 0.0001, 0.0001); // moved
    __block BOOL done = NO;
    [self.geoFire removeKey:@"2" withCompletionBlock:^(NSError *error) {
        done = YES;
    }];

    WAIT_FOR(done);

    NSDictionary *expected = @{ @"1": L2S(L(0.0002, 0.0001)),
                                @"2": @"null",
                                @"3": L2S(L(0.0001, 0.0001)),
                                @"4": L2S(L(0.0001, 0.0001)) };

    XCTAssertEqualObjects(actual, expected);
    [query removeAllObservers];
}

- (void)testUpdateTriggersKeyEntered
{
    SETLOC(@"0", 0, 0);
    SETLOC(@"1", 37.0000, -122.0000);
    SETLOC(@"2", 37.0001, -122.0001);
    SETLOC(@"3", 37.1000, -122.0000);
    SETLOC(@"4", 37.0002, -121.9998);
    GFCircleQuery *query = [self.geoFire queryAtLocation:L(37,-122) withRadius:0.5];
    __block NSMutableDictionary *actual = [NSMutableDictionary dictionary];
    [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        if ([actual objectForKey:key] == nil) {
            actual[key] = L2S(location);
        } else {
            XCTFail(@"Key entered twice!");
        }
    }];
    WAIT_FOR(actual.count == 3);
    actual = [NSMutableDictionary dictionary];
    query.center = L(37.1000, -122.0000);
    WAIT_FOR(actual.count == 1);

    NSDictionary *expected = @{ @"3": L2S(L(37.1000,-122.0000)) };
    XCTAssertEqualObjects(actual, expected);
    [query removeAllObservers];
}

- (void)testUpdateTriggersKeyExited
{
    SETLOC(@"0", 0, 0);
    SETLOC(@"1", 37.0000, -122.0000);
    SETLOC(@"2", 37.0001, -122.0001);
    SETLOC(@"3", 37.1000, -122.0000);
    SETLOC(@"4", 37.0002, -121.9998);
    GFCircleQuery *query = [self.geoFire queryAtLocation:L(37,-122) withRadius:0.5];
    NSMutableSet *actual = [NSMutableSet set];
    __block NSUInteger count = 0;
    [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        count++;
    }];
    WAIT_FOR(count == 3);
    [query observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        if (![actual containsObject:key]) {
            [actual addObject:key];
        } else {
            XCTFail(@"Key exited twice!");
        }
    }];
    query.center = L(37.1000, -122.0000);
    WAIT_FOR(actual.count == 3);

    NSSet *expected = [NSSet setWithArray:@[@"1", @"2", @"4"]];
    XCTAssertEqualObjects(actual, expected);
    [query removeAllObservers];
}

- (void)testUpdateDoesNotTriggerKeyMoved
{
    SETLOC(@"0", 0, 0);
    SETLOC(@"1", 37.0000, -122.0000);
    SETLOC(@"2", 37.0001, -122.0001);
    SETLOC(@"3", 37.1000, -122.0000);
    SETLOC(@"4", 37.0002, -121.9998);
    GFCircleQuery *query = [self.geoFire queryAtLocation:L(37,-122) withRadius:0.5];
    __block NSUInteger count = 0;
    [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        count++;
    }];
    [query observeEventType:GFEventTypeKeyMoved withBlock:^(NSString *key, CLLocation *location) {
        XCTFail(@"Key moved!");
    }];
    WAIT_FOR(count == 3);
    query.center = L(37.0010, -122.0000);
    query.radius = 0.4;
    [NSThread sleepForTimeInterval:0.1];
    query.center = L(37.1000, -122.0000);
    query.radius = 10;
    [NSThread sleepForTimeInterval:0.1];
    query.center = L(0,0);
    [NSThread sleepForTimeInterval:0.1];

    [query removeAllObservers];
}

- (void)testNoExitedEventForLocationsOutsideOfQuery
{
    SETLOC(@"0", 37.0010001, -122.0010001);
    GFRegionQuery *query = [self.geoFire queryWithRegion:MKCoordinateRegionMake(C(37,-122), S(0.002, 0.002))];
    [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        XCTFail(@"Key outside of query entered");
    }];
    [query observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        XCTFail(@"Key outside of query exited");
    }];
    __block BOOL done = NO;
    [self.geoFire removeKey:@"0" withCompletionBlock:^(NSError *error) {
        done = YES;
    }];
    WAIT_FOR(done);
}

- (void)testSubQueryMove
{
    SETLOC(@"0", 0.000001, 0.000001);
    SETLOC(@"1", -0.000001, -0.000001);
    GFQuery *query = [self.geoFire queryAtLocation:L(0, 0) withRadius:0.5];
    NSMutableArray *actual = [NSMutableArray array];
    WAIT_SIGNALS(2, (^(dispatch_semaphore_t barrier) {
        [query observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
            XCTFail(@"Key should not exit!");
        }];
        [query observeEventType:GFEventTypeKeyMoved withBlock:^(NSString *key, CLLocation *location) {
            [actual addObject:[NSString stringWithFormat:@"MOVED(%@,%@)", key, L2S(location)]];
            dispatch_semaphore_signal(barrier);
        }];
        SETLOC(@"0", -0.000001, -0.000001);
        SETLOC(@"1", 0.000001, 0.000001);
    }));

    NSArray *expected = @[@"MOVED(0,[-0.000001, -0.000001])", @"MOVED(1,[0.000001, 0.000001])"];
    XCTAssertEqualObjects(actual, expected);
    [query removeAllObservers];
}

- (void)testRemoveSingleObserver
{
    SETLOC(@"0", 0, 0);
    SETLOC(@"1", 37.0000, -122.0000);
    SETLOC(@"2", 37.0001, -122.0001);
    SETLOC(@"3", 37.1000, -122.0000);
    SETLOC(@"4", 37.0002, -121.9998);
    GFCircleQuery *query = [self.geoFire queryAtLocation:L(37,-122) withRadius:0.5];
    __block NSUInteger keyEnteredEvents = 0;
    __block NSUInteger keyExitedEvents = 0;
    __block NSUInteger keyMovedEvents = 0;
    __block BOOL shouldIgnore = YES;
    [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        keyEnteredEvents++;
    }];
    FirebaseHandle handleEntered = [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        if (!shouldIgnore) {
            XCTFail(@"Event triggered for removed observer!");
        }
    }];
    [query observeEventType:GFEventTypeKeyMoved withBlock:^(NSString *key, CLLocation *location) {
        keyMovedEvents++;
    }];
    FirebaseHandle handleMoved = [query observeEventType:GFEventTypeKeyMoved withBlock:^(NSString *key, CLLocation *location) {
        if (!shouldIgnore) {
            XCTFail(@"Event triggered for removed observer!");
        }
    }];
    [query observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        keyExitedEvents++;
    }];
    FirebaseHandle handleExited = [query observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        if (!shouldIgnore) {
            XCTFail(@"Event triggered for removed observer!");
        }
    }];
    WAIT_FOR(keyEnteredEvents == 3);
    [query removeObserverWithFirebaseHandle:handleEntered];
    [query removeObserverWithFirebaseHandle:handleMoved];
    [query removeObserverWithFirebaseHandle:handleExited];
    shouldIgnore = NO;
    keyEnteredEvents = 0;
    keyExitedEvents = 0;
    keyMovedEvents = 0;

    SETLOC(@"0", 37.0000, -122.0000);
    SETLOC(@"1", 0, 0);
    SETLOC(@"2", 37.0000, -122.0001);
    WAIT_FOR(keyExitedEvents == 1);
    WAIT_FOR(keyEnteredEvents == 1);
    WAIT_FOR(keyMovedEvents == 1);
    [query removeAllObservers];
}

- (void)testRemoveAllObservers
{
    SETLOC(@"0", 0, 0);
    SETLOC(@"1", 37.0000, -122.0000);
    SETLOC(@"2", 37.0001, -122.0001);
    SETLOC(@"3", 37.1000, -122.0000);
    SETLOC(@"4", 37.0002, -121.9998);
    GFCircleQuery *query = [self.geoFire queryAtLocation:L(37,-122) withRadius:0.5];
    __block BOOL shouldIgnore = YES;
    __block NSUInteger countEntered = 0;
    [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        if (!shouldIgnore) {
            XCTFail(@"Callback triggered!");
        } else {
            countEntered++;
        }
    }];
    [query observeEventType:GFEventTypeKeyMoved withBlock:^(NSString *key, CLLocation *location) {
        if (!shouldIgnore) {
            XCTFail(@"Callback triggered!");
        }
    }];
    [query observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        if (!shouldIgnore) {
            XCTFail(@"Callback triggered!");
        }
    }];
    WAIT_FOR(countEntered == 3);
    [query removeAllObservers];
    shouldIgnore = NO;

    SETLOC(@"1", 37.0001, -122.0001);
    SETLOC(@"0", 37.0000, -122.0000);
    query.center = L(37.0010, -122.0000);
    query.radius = 0.4;
    [NSThread sleepForTimeInterval:0.1];
    query.center = L(37.1000, -122.0000);
    query.radius = 10;
    [NSThread sleepForTimeInterval:0.1];
    query.center = L(0,0);
    [NSThread sleepForTimeInterval:0.1];
}

- (void)testReadyListener
{
    SETLOC(@"0", 0, 0);
    SETLOC(@"1", 37.0000, -122.0000);
    SETLOC(@"2", 37.0001, -122.0001);
    SETLOC(@"3", 37.1000, -122.0000);
    SETLOC(@"4", 37.0002, -121.9998);
    GFCircleQuery *query = [self.geoFire queryAtLocation:L(37,-122) withRadius:500];
    __block BOOL readyEventFired = NO;
    [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        if (readyEventFired) {
            XCTFail("Entered event after ready");
        }
    }];
    [query observeReadyWithBlock:^{
        readyEventFired = YES;
    }];
    WAIT_FOR(readyEventFired);
    // wait for any further events to fire
    [NSThread sleepForTimeInterval:0.25];
}

- (void)testReadyListenerFiresAfterReady
{
    SETLOC(@"0", 0, 0);
    SETLOC(@"1", 37.0000, -122.0000);
    SETLOC(@"2", 37.0001, -122.0001);
    SETLOC(@"3", 37.1000, -122.0000);
    SETLOC(@"4", 37.0002, -121.9998);
    GFCircleQuery *query = [self.geoFire queryAtLocation:L(37,-122) withRadius:500];

    __block BOOL readyEventFired = NO;
    [query observeReadyWithBlock:^{
        readyEventFired = YES;
    }];
    WAIT_FOR(readyEventFired);

    __block BOOL secondReadyEventFired = NO;
    [query observeReadyWithBlock:^{
        secondReadyEventFired = YES;
    }];
    // wait for 10 milliseconds, should be enough for an instant fire
    [NSThread sleepForTimeInterval:0.01];
    XCTAssertTrue(secondReadyEventFired);
}

- (void)testReadyAfterUpdateCriteria
{
    SETLOC(@"0", 0, 0);
    SETLOC(@"1", 37.0000, -122.0000);
    SETLOC(@"2", 37.0001, -122.0001);
    SETLOC(@"3", 37.1000, -122.0000);
    SETLOC(@"4", 37.0002, -121.9998);
    GFCircleQuery *query = [self.geoFire queryAtLocation:L(37,-122) withRadius:500];

    __block BOOL keyZeroEntered = NO;
    [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        if ([key isEqualToString:@"0"]) {
            keyZeroEntered = YES;
        }
    }];
    __block int numReadyEventsFired = 0;
    [query observeReadyWithBlock:^{
        numReadyEventsFired++;
    }];
    WAIT_FOR(numReadyEventsFired == 1);
    query.center = L(0,0);
    WAIT_FOR(numReadyEventsFired == 2);
    XCTAssertTrue(keyZeroEntered);
}

- (void)testReadyAfterUpdateCriteriaButNoChangedHashes
{
    GFCircleQuery *query = [self.geoFire queryAtLocation:L(37,-122) withRadius:500.00001];
    __block int numReadyEventsFired = 0;
    [query observeReadyWithBlock:^{
        numReadyEventsFired++;
    }];
    WAIT_FOR(numReadyEventsFired == 1);
    query.radius = 500.00002; // Should not update the actual hashes
    WAIT_FOR(numReadyEventsFired == 2);
}

#pragma clang diagnostic pop

@end
