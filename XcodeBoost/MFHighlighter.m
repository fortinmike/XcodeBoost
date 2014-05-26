//
//  MFHighlighter.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-03.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSUserDefaults+XcodeBoost.h"
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
	NSColor *color1 = [[NSUserDefaults standardUserDefaults] xb_colorForKey:@"XcodeBoostHighlightColor1"];
	NSColor *color2 = [[NSUserDefaults standardUserDefaults] xb_colorForKey:@"XcodeBoostHighlightColor2"];
	NSColor *color3 = [[NSUserDefaults standardUserDefaults] xb_colorForKey:@"XcodeBoostHighlightColor3"];
	NSColor *color4 = [[NSUserDefaults standardUserDefaults] xb_colorForKey:@"XcodeBoostHighlightColor4"];
	
	if (!color1) color1 = [NSColor colorWithCalibratedRed:0.000 green:0.145 blue:0.806 alpha:1.000];
	if (!color2) color2 = [NSColor colorWithCalibratedRed:0.266 green:0.798 blue:0.049 alpha:1.000];
	if (!color3) color3 = [NSColor colorWithCalibratedRed:0.386 green:0.000 blue:0.831 alpha:1.000];
	if (!color4) color4 = [NSColor colorWithCalibratedRed:0.930 green:0.090 blue:0.750 alpha:1.000];
	
	_highlightColors = [@[color1, color2, color3, color4] mutableCopy];
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