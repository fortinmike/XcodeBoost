//
//  MFHighlighter.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-03.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFHighlighter.h"
#import "NSUserDefaults+XcodeBoost.h"
#import "XcodeBoostConstants.h"
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
		[self updateHighlightColors];
    }
    return self;
}

- (void)updateHighlightColors
{
	NSColor *color1 = [[NSUserDefaults standardUserDefaults] xb_colorForKey:XBHighlightColor1Key];
	NSColor *color2 = [[NSUserDefaults standardUserDefaults] xb_colorForKey:XBHighlightColor2Key];
	NSColor *color3 = [[NSUserDefaults standardUserDefaults] xb_colorForKey:XBHighlightColor3Key];
	NSColor *color4 = [[NSUserDefaults standardUserDefaults] xb_colorForKey:XBHighlightColor4Key];
	
	_highlightColors = [@[color1, color2, color3, color4] mutableCopy];
}

#pragma mark Highlighting

- (NSColor *)pushHighlightColor
{
	NSColor *color;
	
	if (_highlightCount < [_highlightColors count])
	{
		[self updateHighlightColors];
		
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