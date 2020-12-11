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

#import <Foundation/Foundation.h>
#import "GFGeoQueryBounds.h"

@interface GFGeoQueryBounds ()

@property (nonatomic, strong, readwrite) NSString *startValue;
@property (nonatomic, strong, readwrite) NSString *endValue;

@end

@implementation GFGeoQueryBounds

- (instancetype)initWithStartValue:(NSString *)startValue endValue:(NSString *)endValue
{
    self = [super init];
    if (self != nil) {
        _startValue = startValue;
        _endValue = endValue;
    }
    return self;
}

+ (GFGeoQueryBounds *)boundsWithStartValue:(NSString *)startValue endValue:(NSString *)endValue
{
    return [[GFGeoQueryBounds alloc] initWithStartValue:startValue endValue:endValue];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (![other isKindOfClass:[GFGeoQueryBounds class]])
        return NO;
    if (![self.startValue isEqualToString:[other startValue]])
        return NO;
    return [self.endValue isEqualToString:[other endValue]];
}

- (NSUInteger)hash
{
    return [self.startValue hash]*31 + [self.endValue hash];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"GFGeoQueryBounds: %@-%@", self.startValue, self.endValue];
}

@end
