//
//  RXCapture.m
//  Regexer
//
//  Created by Michaël Fortin on 2014-05-03.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "RXCapture.h"

@implementation RXCapture

+ (instancetype)notFoundCapture
{
	return [[self alloc] initWithRange:NSMakeRange(NSNotFound, 0) text:nil];
}

- (id)initWithRange:(NSRange)range text:(NSString *)text
{
	self = [super init];
	if (self)
	{
		_range = range;
		_text = text;
	}
	return self;
}

#pragma mark NSObject Overrides

- (NSString *)description
{
	unsigned long start = self.range.location;
	unsigned long end = self.range.location + self.range.length - 1;
	return [NSString stringWithFormat:@"Capture (%lu..%lu '%@')", start, end, self.text];
}

#pragma mark Debugging

- (id)debugQuickLookObject
{
	return [self description];
}

@end