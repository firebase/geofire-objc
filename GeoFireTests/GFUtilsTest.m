//
//  GFUtilsTest.m
//  GeoFireTests
//
//  Created by Peter Friese on 10/11/2020.
//  Copyright © 2020 Firebase. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GFUtils.h"

@interface GFUtilsTest : XCTestCase

@end

@implementation GFUtilsTest

#define L(a,b) CLLocationCoordinate2DMake(a, b)

- (void)testGeoHashForLocation {
  XCTAssertEqualObjects(@"7zzzzzzzzz", [GFUtils geoHashForLocation:L(0, 0)]);
  XCTAssertEqualObjects(@"rzzzzzzzzz", [GFUtils geoHashForLocation:L(0, 180)]);
  XCTAssertEqualObjects(@"5bpbpbpbpb", [GFUtils geoHashForLocation:L(-90, 0)]);
  XCTAssertEqualObjects(@"0000000000", [GFUtils geoHashForLocation:L(-90, -180)]);
  XCTAssertEqualObjects(@"pbpbpbpbpb", [GFUtils geoHashForLocation:L(-90, 180)]);
  XCTAssertEqualObjects(@"gzzzzzzzzz", [GFUtils geoHashForLocation:L(90, 0)]);
  XCTAssertEqualObjects(@"bpbpbpbpbp", [GFUtils geoHashForLocation:L(90, -180)]);
  XCTAssertEqualObjects(@"zzzzzzzzzz", [GFUtils geoHashForLocation:L(90, 180)]);
}

@end
