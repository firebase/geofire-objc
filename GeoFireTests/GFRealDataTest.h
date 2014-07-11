//
//  GFRealDataTest.h
//  GeoFire
//
//  Created by Jonny Dimond on 7/9/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GeoFire.h"
#import <Firebase/Firebase.h>

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

#define WAIT_FOR(__condition)\
do { \
  CFAbsoluteTime start = CFAbsoluteTimeGetCurrent(); \
  while (!(__condition) && (CFAbsoluteTimeGetCurrent() - start) < TEST_TIMEOUT_SECONDS) { \
    [NSThread sleepForTimeInterval:0.01]; \
  }; \
  if ((CFAbsoluteTimeGetCurrent() - start) > TEST_TIMEOUT_SECONDS) { \
    XCTFail(@"Timeout occured!"); \
  } \
} while(0);

@interface GFRealDataTest : XCTestCase

@property (nonatomic, strong) GeoFire *geoFire;
@property (nonatomic, strong) Firebase *firebase;

@end
