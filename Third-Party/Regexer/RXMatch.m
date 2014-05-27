//
//  RXMatch.m
//  Regexer
//
//  Created by Michaël Fortin on 2014-05-03.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "RXMatch.h"

@implementation RXMatch

#pragma mark Lifetime

- (id)initWithCaptures:(NSArray *)captures
{
	self = [super init];
	if (self)
	{
		_captures = captures ?: [NSArray array];
	}
	return self;
}

#pragma mark Accessor Overrides

- (NSString *)text
{
	return [[_captures firstObject] text];
}

- (NSRange)range
{
	return [[_captures firstObject] range];
}

#pragma mark Subscripting Support

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
	if (index >= [_captures count])
	{
		NSString *reason = [NSString stringWithFormat:@"There is no capture group with index %lu", (unsigned long)index];
		@throw [NSException exceptionWithName:@"Invalid Operation" reason:reason userInfo:nil];
	}
	
	return _captures[index];
}

#pragma mark NSObject Overrides

- (NSString *)description
{
	return [_captures description];
}

#pragma mark Debugging

- (id)debugQuickLookObject
{
	return [self description];
}

@end