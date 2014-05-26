//
//  MFSymbol.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-05-26.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFSymbol.h"

@implementation MFSymbol

- (id)initWithType:(MFSymbolType)type matchRange:(NSRange)matchRange matchText:(NSString *)matchText
{
    self = [super init];
    if (self)
    {
        _type = type;
		
		_matchRange = matchRange;
		_matchText = matchText;
		
		// Unless manually specified, default to match range and text
		_range = matchRange;
		_text = matchText;
    }
    return self;
}

#pragma mark NSObject Overrides

- (NSString *)description
{
	NSUInteger start = self.range.location;
	NSUInteger end = self.range.location + self.range.length;
	return [[super description] stringByAppendingFormat:@" %@ (type %d), %ld..%ld", self.text, (int)self.type, start, end];
}

@end