/*
 * Firebase GeoFire iOS Library
 *
 * Copyright © 2020 Firebase - All Rights Reserved
 * https://firebase.google.com
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
