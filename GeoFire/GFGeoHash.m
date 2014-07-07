//
//  GFGeoHash.m
//  GeoFire
//
//  Created by Jonny Dimond on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "GFGeoHash.h"

static const char BASE_32_CHARS[] = "0123456789bcdefghjkmnpqrstuvwxyz";
#define BITS_PER_CHAR 5

typedef enum : NSUInteger {
    GFDirectionNorth,
    GFDirectionSouth,
    GFDirectionWest,
    GFDirectionEast
} GFDirection;

static const NSString *GEO_HASH_NEIGHBORS[4][2] = {
    // NORTH
    {
        @"p0r21436x8zb9dcf5h7kjnmqesgutwvy", // even
        @"bc01fg45238967deuvhjyznpkmstqrwx"  // odd
    },
    // SOUTH
    {
        @"14365h7k9dcfesgujnmqp0r2twvyx8zb", // even
        @"238967debc01fg45kmstqrwxuvhjyznp"  // odd
    },
    // WEST
    {
        @"238967debc01fg45kmstqrwxuvhjyznp", // even
        @"14365h7k9dcfesgujnmqp0r2twvyx8zb"  // odd
    },
    // EAST
    {
        @"bc01fg45238967deuvhjyznpkmstqrwx", // even
        @"p0r21436x8zb9dcf5h7kjnmqesgutwvy"  // odd
    }
};

static const NSString *GEO_BORDERS[4][2] = {
    // NORTH
    {
        @"prxz", // even
        @"bcfguvyz"  // odd
    },
    // SOUTH
    {
        @"028b", // even
        @"0145hjnp"  // odd
    },
    // WEST
    {
        @"0145hjnp", // even
        @"028b"  // odd
    },
    // EAST
    {
        @"bcfguvyz", // even
        @"prxz"  // odd
    }
};

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
        if (precision > 22) {
            [NSException raise:NSInvalidArgumentException format:@"Precision must be less than 23!"];
        }

        double longitudeRange[] = { -180 , 180 };
        double latitudeRange[] = { -90 , 90 };

        char buffer[precision+1];
        buffer[precision] = 0;

        for (NSUInteger i = 0; i < precision; i++) {
            NSUInteger hashVal = 0;
            for (NSUInteger j = 0; j < BITS_PER_CHAR; j++) {
                BOOL even = ((i*BITS_PER_CHAR)+j) % 2 == 0;
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
            buffer[i] = BASE_32_CHARS[hashVal];
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

+ (NSString *)neighborHashValueForHash:(NSString *)hash inDirection:(GFDirection)direction
{
    NSString *lastChar = [hash substringWithRange:NSMakeRange(hash.length-1, 1)];
    NSUInteger type = hash.length % 2;
    NSString *base = [hash substringToIndex:hash.length-1];
    if ([GEO_BORDERS[direction][type] rangeOfString:lastChar].location != NSNotFound) {
        if (base.length == 0) {
            return @"";
        }
        base = [GFGeoHash neighborHashValueForHash:base inDirection:direction];
    }
    NSUInteger index = [GEO_HASH_NEIGHBORS[direction][type] rangeOfString:lastChar].location;
    return [NSString stringWithFormat:@"%@%c", base, BASE_32_CHARS[index]];
}

+ (BOOL)isValidGeoHash:(NSString *)hash
{
    static NSCharacterSet *base32Set;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        base32Set = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithUTF8String:BASE_32_CHARS]];
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

- (GFGeoHash *)neighborEast
{
    NSString *hash = [GFGeoHash neighborHashValueForHash:self.geoHashValue inDirection:GFDirectionEast];
    if (hash.length > 0) {
        return [[GFGeoHash alloc] initWithCheckedHash:hash];
    } else {
        return nil;
    }
}

- (GFGeoHash *)neighborWest
{
    NSString *hash = [GFGeoHash neighborHashValueForHash:self.geoHashValue inDirection:GFDirectionWest];
    if (hash.length > 0) {
        return [[GFGeoHash alloc] initWithCheckedHash:hash];
    } else {
        return nil;
    }
}

- (GFGeoHash *)neighborNorth
{
    NSString *hash = [GFGeoHash neighborHashValueForHash:self.geoHashValue inDirection:GFDirectionNorth];
    if (hash.length > 0) {
        return [[GFGeoHash alloc] initWithCheckedHash:hash];
    } else {
        return nil;
    }
}

- (GFGeoHash *)neighborSouth
{
    NSString *hash = [GFGeoHash neighborHashValueForHash:self.geoHashValue inDirection:GFDirectionSouth];
    if (hash.length > 0) {
        return [[GFGeoHash alloc] initWithCheckedHash:hash];
    } else {
        return nil;
    }
}

- (NSSet *)neighbors
{
    NSMutableSet *set = [NSMutableSet set];
    GFGeoHash *north = self.neighborNorth;
    if (north != nil) {
        [set addObject:north];
        GFGeoHash *northEast = north.neighborEast;
        if (northEast != nil) {
            [set addObject:northEast];
        }
        GFGeoHash *northWest = north.neighborWest;
        if (northWest != nil) {
            [set addObject:northWest];
        }
    }
    GFGeoHash *south = self.neighborSouth;
    if (south != nil) {
        [set addObject:south];
        GFGeoHash *southEast = south.neighborEast;
        if (southEast != nil) {
            [set addObject:southEast];
        }
        GFGeoHash *southWest = south.neighborWest;
        if (southWest != nil) {
            [set addObject:southWest];
        }
    }
    GFGeoHash *east = self.neighborEast;
    if (east != nil) {
        [set addObject:east];
    }
    GFGeoHash *west = self.neighborWest;
    if (west != nil) {
        [set addObject:west];
    }
    return set;
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

@end
