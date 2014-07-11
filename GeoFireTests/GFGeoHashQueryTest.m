//
//  GFGeoHashQueryTest.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/7/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GFGeoHashQuery.h"

@interface GFGeoHashQuery (Tests)

+ (CLLocationDegrees)wrapLongitude:(CLLocationDegrees)degrees;
+ (CLLocationDegrees)meters:(double)distance toLongitudeDegreesAtLatitude:(CLLocationDegrees)latitude;
+ (NSUInteger)bitsForBoundingBoxAtLocation:(CLLocationCoordinate2D)location withSize:(double)size;
+ (GFGeoHashQuery *)newWithStartValue:(NSString *)startValue endValue:(NSString *)endValue;
+ (GFGeoHashQuery *)geoHashQueryWithGeoHash:(GFGeoHash *)geohash bits:(NSUInteger)bits;

@end

#define ACCURACY 1e-6
#define DBL_RAND() (arc4random()/(2.0*(double)RAND_MAX+1))

@interface GFGeoHashQueryTest : XCTestCase

@end

@implementation GFGeoHashQueryTest

- (void)testWrapLongitude
{
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:1], 1, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:0], 0, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:180], 180, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:-180], -180, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:182], -178, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:270], -90, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:360], 0, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:540], -180, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:630], -90, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:720], 0, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:810], 90, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:-360], 0, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:-182], 178, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:-270], 90, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:-360], 0, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:-450], -90, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:-540], 180, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:-630], 90, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:1080], 0, 1e-6);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery wrapLongitude:-1080], 0, 1e-6);
}

- (void)testMetersToLongitudeDegrees
{
    XCTAssertEqualWithAccuracy([GFGeoHashQuery meters:1000 toLongitudeDegreesAtLatitude:0], 0.008983, 1e-5);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery meters:111320 toLongitudeDegreesAtLatitude:0], 1, 1e-5);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery meters:107550 toLongitudeDegreesAtLatitude:15], 1, 1e-5);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery meters:96486 toLongitudeDegreesAtLatitude:30], 1, 1e-5);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery meters:78847 toLongitudeDegreesAtLatitude:45], 1, 1e-5);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery meters:55800 toLongitudeDegreesAtLatitude:60], 1, 1e-5);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery meters:28902 toLongitudeDegreesAtLatitude:75], 1, 1e-5);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery meters:0 toLongitudeDegreesAtLatitude:90], 0, 1e-5);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery meters:1000 toLongitudeDegreesAtLatitude:90], 360, 1e-5);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery meters:1000 toLongitudeDegreesAtLatitude:89.9999], 360, 1e-5);
    XCTAssertEqualWithAccuracy([GFGeoHashQuery meters:1000 toLongitudeDegreesAtLatitude:89.995], 102.594208, 1e-5);
}

- (void)testBoundingBoxBts
{
    XCTAssertEqual([GFGeoHashQuery bitsForBoundingBoxAtLocation:CLLocationCoordinate2DMake(35,0) withSize:1000], 28);
    XCTAssertEqual([GFGeoHashQuery bitsForBoundingBoxAtLocation:CLLocationCoordinate2DMake(35.645,0) withSize:1000], 27);
    XCTAssertEqual([GFGeoHashQuery bitsForBoundingBoxAtLocation:CLLocationCoordinate2DMake(36,0) withSize:1000], 27);
    XCTAssertEqual([GFGeoHashQuery bitsForBoundingBoxAtLocation:CLLocationCoordinate2DMake(0,0) withSize:1000], 28);
    XCTAssertEqual([GFGeoHashQuery bitsForBoundingBoxAtLocation:CLLocationCoordinate2DMake(0,-180) withSize:1000], 28);
    XCTAssertEqual([GFGeoHashQuery bitsForBoundingBoxAtLocation:CLLocationCoordinate2DMake(0,180) withSize:1000], 28);
    XCTAssertEqual([GFGeoHashQuery bitsForBoundingBoxAtLocation:CLLocationCoordinate2DMake(0,0) withSize:8000], 22);
    XCTAssertEqual([GFGeoHashQuery bitsForBoundingBoxAtLocation:CLLocationCoordinate2DMake(45,0) withSize:1000], 27);
    XCTAssertEqual([GFGeoHashQuery bitsForBoundingBoxAtLocation:CLLocationCoordinate2DMake(75,0) withSize:1000], 25);
    XCTAssertEqual([GFGeoHashQuery bitsForBoundingBoxAtLocation:CLLocationCoordinate2DMake(75,0) withSize:2000], 23);
    XCTAssertEqual([GFGeoHashQuery bitsForBoundingBoxAtLocation:CLLocationCoordinate2DMake(90,0) withSize:1000], 1);
    XCTAssertEqual([GFGeoHashQuery bitsForBoundingBoxAtLocation:CLLocationCoordinate2DMake(90,0) withSize:2000], 1);
}

- (void)testGeoHashQuery
{
    XCTAssertEqualObjects([GFGeoHashQuery geoHashQueryWithGeoHash:[GFGeoHash newWithString:@"64m9yn96mx"] bits:6],
                          [GFGeoHashQuery newWithStartValue:@"60" endValue:@"6h"]);
    XCTAssertEqualObjects([GFGeoHashQuery geoHashQueryWithGeoHash:[GFGeoHash newWithString:@"64m9yn96mx"] bits:1],
                          [GFGeoHashQuery newWithStartValue:@"0" endValue:@"h"]);
    XCTAssertEqualObjects([GFGeoHashQuery geoHashQueryWithGeoHash:[GFGeoHash newWithString:@"64m9yn96mx"] bits:10],
                          [GFGeoHashQuery newWithStartValue:@"64" endValue:@"65"]);
    XCTAssertEqualObjects([GFGeoHashQuery geoHashQueryWithGeoHash:[GFGeoHash newWithString:@"6409yn96mx"] bits:11],
                          [GFGeoHashQuery newWithStartValue:@"640" endValue:@"64h"]);
    XCTAssertEqualObjects([GFGeoHashQuery geoHashQueryWithGeoHash:[GFGeoHash newWithString:@"64m9yn96mx"] bits:11],
                          [GFGeoHashQuery newWithStartValue:@"64h" endValue:@"64~"]);
    XCTAssertEqualObjects([GFGeoHashQuery geoHashQueryWithGeoHash:[GFGeoHash newWithString:@"6"] bits:10],
                          [GFGeoHashQuery newWithStartValue:@"6" endValue:@"6~"]);
    XCTAssertEqualObjects([GFGeoHashQuery geoHashQueryWithGeoHash:[GFGeoHash newWithString:@"64z178"] bits:12],
                          [GFGeoHashQuery newWithStartValue:@"64s" endValue:@"64~"]);
    XCTAssertEqualObjects([GFGeoHashQuery geoHashQueryWithGeoHash:[GFGeoHash newWithString:@"64z178"] bits:15],
                          [GFGeoHashQuery newWithStartValue:@"64z" endValue:@"64~"]);
}

- (void)testPointsInCircleGeoQuery
{
    for (NSUInteger i = 0; i < 1000; i++) {
        CLLocationDegrees centerLat = DBL_RAND()*160-80;
        CLLocationDegrees centerLong = DBL_RAND()*360 - 180;
        CLLocation *center = [[CLLocation alloc] initWithLatitude:centerLat longitude:centerLong];
        double radius = fmax(5, pow(DBL_RAND(),5)*100000);
        CLLocationDegrees degreeRadius = [GFGeoHashQuery meters:radius toLongitudeDegreesAtLatitude:centerLat]*2;
        NSSet *queries = [GFGeoHashQuery queriesForLocation:CLLocationCoordinate2DMake(centerLat, centerLong)
                                                     radius:radius];
        BOOL (^inQuery)(CLLocationDegrees, CLLocationDegrees) = ^(CLLocationDegrees lat, CLLocationDegrees lng) {
            __block BOOL inQueryFlag = NO;
            [queries enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                if ([obj containsGeoHash:[GFGeoHash newWithLocation:CLLocationCoordinate2DMake(lat, lng)]]) {
                    inQueryFlag = YES;
                    *stop = YES;
                };
            }];
            return inQueryFlag;
        };
        for (NSUInteger j = 0; j < 1000; j++) {
            CLLocationDegrees pointLat = fmax(-89.9, fmin(89.9, centerLat + DBL_RAND()*degreeRadius));
            CLLocationDegrees pointLong = [GFGeoHashQuery wrapLongitude:(centerLong + DBL_RAND()*degreeRadius)];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:pointLat longitude:pointLong];
            if ([location distanceFromLocation:center] < radius) {
                XCTAssertTrue(inQuery(pointLat, pointLong),
                              @"Point (%f, %f) not contained in GeoHash query around (%f,%f) with radius %fm",
                              pointLat, pointLong, centerLat, centerLong, radius);
            }
        }
    }
}

- (void)testPointsInRegionGeoQueries
{
    for (NSUInteger i = 0; i < 1000; i++) {
        CLLocationDegrees centerLat = DBL_RAND()*160-80;
        CLLocationDegrees centerLong = DBL_RAND()*360 - 180;
        CLLocation *center = [[CLLocation alloc] initWithLatitude:centerLat longitude:centerLong];
        double latitudeDelta = fmax(0.00001, pow(DBL_RAND(),5)*(90-fabs(centerLat)));
        double longitudeDelta = fmax(0.00001, pow(DBL_RAND(),5)*360);
        MKCoordinateRegion region = MKCoordinateRegionMake(center.coordinate,
                                                           MKCoordinateSpanMake(latitudeDelta, longitudeDelta));
        NSSet *queries = [GFGeoHashQuery queriesForRegion:region];
        BOOL (^inQuery)(CLLocationDegrees, CLLocationDegrees) = ^(CLLocationDegrees lat, CLLocationDegrees lng) {
            __block BOOL inQueryFlag = NO;
            [queries enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                if ([obj containsGeoHash:[GFGeoHash newWithLocation:CLLocationCoordinate2DMake(lat, lng)]]) {
                    inQueryFlag = YES;
                    *stop = YES;
                };
            }];
            return inQueryFlag;
        };
        for (NSUInteger j = 0; j < 1000; j++) {
            CLLocationDegrees pointLat = fmax(-89.9, fmin(89.9, centerLat + (DBL_RAND()*latitudeDelta - latitudeDelta/2)));
            CLLocationDegrees pointLong = [GFGeoHashQuery wrapLongitude:(centerLong + (DBL_RAND()*longitudeDelta - longitudeDelta/2))];
            XCTAssertTrue(inQuery(pointLat, pointLong),
                          @"Point (%f, %f) not contained in GeoHash for region [%f +/ %f, %f +/ %f]",
                          pointLat, pointLong, centerLat, latitudeDelta/2, centerLong, longitudeDelta/2);
        }
    }
}

#define Q(a,b) [GFGeoHashQuery newWithStartValue:a endValue:b]

- (void)testCanJoin
{
    XCTAssertTrue([Q(@"abcd", @"abce") canJoinWith:Q(@"abce", @"abcf")]);
    XCTAssertTrue([Q(@"abce", @"abcf") canJoinWith:Q(@"abcd", @"abce")]);
    XCTAssertTrue([Q(@"abcd", @"abcf") canJoinWith:Q(@"abcd", @"abce")]);
    XCTAssertTrue([Q(@"abcd", @"abcf") canJoinWith:Q(@"abce", @"abcf")]);
    XCTAssertTrue([Q(@"abc", @"abd") canJoinWith:Q(@"abce", @"abcf")]);
    XCTAssertTrue([Q(@"abce", @"abcf") canJoinWith:Q(@"abc", @"abd")]);
    XCTAssertTrue([Q(@"abcd", @"abce~") canJoinWith:Q(@"abc", @"abd")]);
    XCTAssertTrue([Q(@"abcd", @"abce~") canJoinWith:Q(@"abce", @"abcf")]);
    XCTAssertTrue([Q(@"abcd", @"abcf") canJoinWith:Q(@"abce", @"abcg")]);

    XCTAssertFalse([Q(@"abcd", @"abce") canJoinWith:Q(@"abcg", @"abch")]);
    XCTAssertFalse([Q(@"abcd", @"abce") canJoinWith:Q(@"dce", @"dcf")]);
    XCTAssertFalse([Q(@"abc", @"abd") canJoinWith:Q(@"dce", @"dcf")]);
}

- (void)testJoinQueries
{
    XCTAssertEqualObjects([Q(@"abcd", @"abce") joinWith:Q(@"abce", @"abcf")], Q(@"abcd",@"abcf"));
    XCTAssertEqualObjects([Q(@"abce", @"abcf") joinWith:Q(@"abcd", @"abce")], Q(@"abcd",@"abcf"));
    XCTAssertEqualObjects([Q(@"abcd", @"abcf") joinWith:Q(@"abcd", @"abce")], Q(@"abcd",@"abcf"));
    XCTAssertEqualObjects([Q(@"abcd", @"abcf") joinWith:Q(@"abce", @"abcf")], Q(@"abcd",@"abcf"));
    XCTAssertEqualObjects([Q(@"abc", @"abd") joinWith:Q(@"abce", @"abcf")], Q(@"abc",@"abd"));
    XCTAssertEqualObjects([Q(@"abce", @"abcf") joinWith:Q(@"abc", @"abd")], Q(@"abc",@"abd"));
    XCTAssertEqualObjects([Q(@"abcd", @"abce~") joinWith:Q(@"abc", @"abd")], Q(@"abc",@"abd"));
    XCTAssertEqualObjects([Q(@"abcd", @"abce~") joinWith:Q(@"abce", @"abcf")], Q(@"abcd",@"abcf"));
    XCTAssertEqualObjects([Q(@"abcd", @"abcf") joinWith:Q(@"abce", @"abcg")], Q(@"abcd",@"abcg"));

    XCTAssertNil([Q(@"abcd", @"abce") joinWith:Q(@"abcg", @"abch")]);
    XCTAssertNil([Q(@"abcd", @"abce") joinWith:Q(@"dce", @"dcf")]);
    XCTAssertNil([Q(@"abc", @"abd") joinWith:Q(@"dce", @"dcf")]);
}

@end
