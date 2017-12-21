//
//  GFGeoHash.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "GFGeoHash.h"

#import "GFBase32Utils.h"

@interface GFGeoHash ()

@property (nonatomic, strong, readwrite) NSString *geoHashValue;

@end

@implementation GFGeoHash

- (id)initWithLocation:(CLLocationCoordinate2D)location
{
    return [self initWithLocation:location precision:GF_DEFAULT_PRECISION];
}

- (id)initWithLocation:(CLLocationCoordinate2D)location precision:(NSUInteger)precision
{
    self = [super init];
    if (self != nil) {
        if (precision < 1) {
            [NSException raise:NSInvalidArgumentException format:@"Precision must be larger than 0!"];
        }
        if (precision > GF_MAX_PRECISION) {
            [NSException raise:NSInvalidArgumentException format:@"Precision must be less than %d!",
             (GF_MAX_PRECISION+1)];
        }
        if (!CLLocationCoordinate2DIsValid(location)) {
            [NSException raise:NSInvalidArgumentException
                        format:@"Not a valid geo location: [%f,%f]", location.latitude, location.longitude];
        }

        double longitudeRange[] = { -180 , 180 };
        double latitudeRange[] = { -90 , 90 };

        char buffer[precision+1];
        buffer[precision] = 0;

        for (NSUInteger i = 0; i < precision; i++) {
            NSUInteger hashVal = 0;
            for (NSUInteger j = 0; j < BITS_PER_BASE32_CHAR; j++) {
                BOOL even = ((i*BITS_PER_BASE32_CHAR)+j) % 2 == 0;
                double val = (even) ? location.longitude : location.latitude;
                double* range = (even) ? longitudeRange : latitudeRange;
                double mid = (range[0] + range[1])/2;
                if (val > mid) {
                    hashVal = (hashVal << 1) + 1;
                    range[0] = mid;
                } else {
                    hashVal = (hashVal << 1) + 0;
                    range[1] = mid;
                }
            }
            buffer[i] = [GFBase32Utils valueToBase32Character:hashVal];
        }
        self->_geoHashValue = [NSString stringWithUTF8String:buffer];
    }
    return self;
}

+ (GFGeoHash *)newWithLocation:(CLLocationCoordinate2D)location
{
    return [GFGeoHash newWithLocation:location precision:GF_DEFAULT_PRECISION];
}

+ (GFGeoHash *)newWithLocation:(CLLocationCoordinate2D)location precision:(NSUInteger)precision
{
    return [[GFGeoHash alloc] initWithLocation:location precision:precision];
}

+ (GFGeoHash *)newWithString:(NSString *)string
{
    return [[GFGeoHash alloc] initWithString:string];
}

+ (NSUInteger)interleaveBitsOf:(NSUInteger)x withNumber:(NSUInteger)y
{
    return ((x * 0x0101010101010101ULL & 0x8040201008040201ULL) * 0x0102040810204081ULL >> 49) & 0x5555 |
           ((y * 0x0101010101010101ULL & 0x8040201008040201ULL) * 0x0102040810204081ULL >> 48) & 0xAAAA;
}

+ (GFGeoHash *)newWithOrigin:(CLLocationCoordinate2D)origin destination:(CLLocationCoordinate2D)destination precision:(NSUInteger)precision
{
    char buffer[2 * precision + 1];
    buffer[2 * precision] = 0;

    GFGeoHash *originHash = [GFGeoHash newWithLocation:origin precision:precision];
    GFGeoHash *destinationHash = [GFGeoHash newWithLocation:destination precision:precision];
    const char * const originHashBuffer = originHash.geoHashValue.UTF8String;
    const char * const destinationHashBuffer = destinationHash.geoHashValue.UTF8String;

    for (NSUInteger i = 0; i < precision; i++) {
        const NSUInteger x = [GFBase32Utils base32CharacterToValue:originHashBuffer[i]];
        const NSUInteger y = [GFBase32Utils base32CharacterToValue:destinationHashBuffer[i]];
        const NSUInteger z = [GFGeoHash interleaveBitsOf:x withNumber:y];
        buffer[2 * i] = [GFBase32Utils valueToBase32Character:(z & (BIT_MASK_FOR_BASE32_CHAR << BITS_PER_BASE32_CHAR)) >> BITS_PER_BASE32_CHAR];
        buffer[2 * i + 1] = [GFBase32Utils valueToBase32Character:z & BIT_MASK_FOR_BASE32_CHAR];
    }

    return [GFGeoHash newWithString:[NSString stringWithUTF8String:buffer]];
}

- (id)initWithString:(NSString *)hashValue
{
    if ([GFGeoHash isValidGeoHash:hashValue]) {
        return [self initWithCheckedHash:hashValue];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Not a valid geo hash: %@", hashValue];
        return nil;
    }
}

- (id)initWithCheckedHash:(NSString *)hashValue
{
    self = [super init];
    if (self != nil) {
        self->_geoHashValue = hashValue;
    }
    return self;
}

+ (BOOL)isValidGeoHash:(NSString *)hash
{
    static NSCharacterSet *base32Set;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        base32Set = [NSCharacterSet characterSetWithCharactersInString:[GFBase32Utils base32Characters]];
    });
    if (hash.length == 0) {
        return NO;
    }
    NSCharacterSet *hashCharSet = [NSCharacterSet characterSetWithCharactersInString:hash];
    if (![base32Set isSupersetOfSet:hashCharSet]) {
        return NO;
    }

    return YES;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self.geoHashValue isEqualToString:[other geoHashValue]];
}

- (NSUInteger)hash
{
    return [self.geoHashValue hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"GFGeoHash: %@", self.geoHashValue];
}

@end
