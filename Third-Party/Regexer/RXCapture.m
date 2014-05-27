//
//  RXCapture.m
//  Regexer
//
//  Created by Michaël Fortin on 2014-05-03.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "RXCapture.h"

@interface RXCapture ()

@property (assign) BOOL found;

@end

@implementation RXCapture

+ (instancetype)notFoundCapture
{
	RXCapture *capture = [[self alloc] initWithRange:NSMakeRange(NSNotFound, 0) text:nil];
	[capture setFound:NO];
	return capture;
}

- (id)initWithRange:(NSRange)range text:(NSString *)text
{
	self = [super init];
	if (self)
	{
		_found = YES;
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