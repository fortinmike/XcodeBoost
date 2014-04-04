//
//  MFHighlighter.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-03.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFHighlighter.h"
#import "NSColor+XcodeBoost.h"

@implementation MFHighlighter
{
	NSMutableArray *_highlightColors;
	NSUInteger _highlightCount;
}

#pragma mark Lifetime

- (id)init
{
    self = [super init];
    if (self)
    {
		[self setupHighlightColors];
    }
    return self;
}

- (void)setupHighlightColors
{
	NSColor *yellowColor = [NSColor colorWithCalibratedRed:0.91 green:0.74 blue:0.14 alpha:1];
	NSColor *blueColor = [NSColor colorWithCalibratedRed:0.05 green:0.24 blue:1 alpha:1];
	NSColor *redColor = [NSColor colorWithCalibratedRed:0.69 green:0.07 blue:0.14 alpha:1];
	NSColor *purpleColor = [NSColor colorWithCalibratedRed:0.58 green:0.09 blue:0.93 alpha:1];
	
	_highlightColors = [@[purpleColor, redColor, blueColor, yellowColor] mutableCopy];
}

#pragma mark Highlighting

- (NSColor *)pushHighlightColor
{
	NSColor *color;
	
	if (_highlightCount < [_highlightColors count])
	{
		color = _highlightColors[_highlightCount];
	}
	else
	{
		color = [NSColor xb_randomColor];
		
		// Add the color to the array of colors so that we can undo highlighting
		// step-by-step afterwards (by enumerating over ranges with those background colors).
		[_highlightColors addObject:color];
	}
	
	_highlightCount++;
	
	return color;
}

- (NSColor *)popHighlightColor
{
	if (_highlightCount == 0) return nil;
	_highlightCount--;
	
	return _highlightColors[_highlightCount];
}

- (void)popAllHighlightColors
{
	_highlightCount = 0;
}

@end