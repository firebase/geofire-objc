//
//  GFBase32Utils.h
//  GeoFire
//
//  Created by Jonny Dimond on 7/7/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BITS_PER_BASE32_CHAR 5
#define BIT_MASK_FOR_BASE32_CHAR 0x1f

@interface GFBase32Utils : NSObject

+ (char)valueToBase32Character:(NSUInteger)value;
+ (NSUInteger)base32CharacterToValue:(char)character;

+ (NSString *)base32Characters;

@end
