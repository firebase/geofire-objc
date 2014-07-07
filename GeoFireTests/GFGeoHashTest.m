//
//  GFGeoHashTest.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GFGeoHash.h"

@interface GFGeoHashTest : XCTestCase

@end

@implementation GFGeoHashTest

#define TEST_HASH_PREC(__lat, __long, __prec, __hash) \
do { \
    XCTAssertEqualObjects(__hash, [GFGeoHash newWithLocation:CLLocationCoordinate2DMake(__lat,__long) \
                                                   precision:__prec].geoHashValue, @"Hashes don't match!"); \
} while(0)

#define TEST_HASH(__lat, __long, __hash) TEST_HASH_PREC(__lat, __long, 10, __hash)


- (void)testHashValues
{
    TEST_HASH(0, 0, @"7zzzzzzzzz");
    TEST_HASH(0, -180, @"2pbpbpbpbp");
    TEST_HASH(0, 180, @"rzzzzzzzzz");
    TEST_HASH(-90, 0, @"5bpbpbpbpb");
    TEST_HASH(-90, -180, @"0000000000");
    TEST_HASH(-90, 180, @"pbpbpbpbpb");
    TEST_HASH(90, 0, @"gzzzzzzzzz");
    TEST_HASH(90, -180, @"bpbpbpbpbp");
    TEST_HASH(90, 180, @"zzzzzzzzzz");

    TEST_HASH(37.7853074, -122.4054274, @"9q8yywe56g");
    TEST_HASH(38.98719, -77.250783, @"dqcjf17sy6");
    TEST_HASH(29.3760648, 47.9818853, @"tj4p5gerfz");
    TEST_HASH(78.216667, 15.55, @"umghcygjj7");
    TEST_HASH(-54.933333, -67.616667, @"4qpzmren1k");
    TEST_HASH(-54, -67, @"4w2kg3s54y");
}

- (void)testCustomPrecision
{
    TEST_HASH_PREC(-90, -180, 6, @"000000");
    TEST_HASH_PREC(90, 180, 20, @"zzzzzzzzzzzzzzzzzzzz");
    TEST_HASH_PREC(-90, 180, 1, @"p");
    TEST_HASH_PREC(90, -180, 5, @"bpbpb");
    TEST_HASH_PREC(37.7853074, -122.4054274, 8, @"9q8yywe5");
    TEST_HASH_PREC(38.98719, -77.250783, 18, @"dqcjf17sy6cppp8vfn");
    TEST_HASH_PREC(29.3760648, 47.9818853, 12, @"tj4p5gerfzqu");
    TEST_HASH_PREC(78.216667, 15.55, 1, @"u");
    TEST_HASH_PREC(-54.933333, -67.616667, 7, @"4qpzmre");
    TEST_HASH_PREC(-54, -67, 9, @"4w2kg3s54");
}

- (void)testHashInvalidArguments
{
    XCTAssertThrows([GFGeoHash newWithLocation:CLLocationCoordinate2DMake(0, 0) precision:0],
                    @"Precision 0 throws NSInvalidArgumentException");
    XCTAssertThrows([GFGeoHash newWithLocation:CLLocationCoordinate2DMake(0, 0) precision:23],
                    @"Precision 23 throws NSInvalidArgumentException");
    XCTAssertNoThrow([GFGeoHash newWithLocation:CLLocationCoordinate2DMake(0, 0) precision:22],
                    @"Precision 22 does not throw NSInvalidArgumentException");
}

@end