//
//  TestHelpers.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/9/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "TestHelpers.h"

#import <XCTest/XCTest.h>

@implementation TestHelpers

static NSString *letters = @"abcdefghijklmnopqrstuvwxyz0123456789";

+ (NSString *)randomAlphaNumericStringWithLength:(NSUInteger)length
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        unichar randomChar = [letters characterAtIndex:arc4random() % letters.length];
        [randomString appendFormat: @"%C", randomChar];
    }
    return randomString;
}

@end
