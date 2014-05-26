//
//  MFSymbol.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-05-26.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFSymbol.h"

@implementation MFSymbol

- (id)initWithType:(MFSymbolType)type
{
    self = [super init];
    if (self)
    {
        _type = type;
    }
    return self;
}

#pragma mark NSObject Overrides

- (NSString *)description
{
	NSUInteger start = self.range.location;
	NSUInteger end = self.range.location + self.range.length;
	return [[super description] stringByAppendingFormat:@" %@ (type %d), %ld..%ld", self.string, (int)self.type, start, end];
}

@end