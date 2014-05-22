//
//  DVTLayoutManager+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-05-21.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "DVTLayoutManager+XcodeBoost.h"
#import "XcodeBoostConstants.h"
#import "JRSwizzle.h"

@implementation DVTLayoutManager (XcodeBoost)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
	{
		[self jr_swizzleMethod:@selector(drawBackgroundForGlyphRange:atPoint:) withMethod:@selector(xb_drawBackgroundForGlyphRange:atPoint:) error:nil];
		[self jr_swizzleMethod:@selector(drawGlyphsForGlyphRange:atPoint:) withMethod:@selector(xb_drawGlyphsForGlyphRange:atPoint:) error:nil];
	});
}

#pragma mark Swizzled Methods

- (void)xb_drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin
{
	[self xb_drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
	
	NSTextContainer *textContainer = [self textContainerForGlyphAtIndex:glyphsToShow.location effectiveRange:NULL];
	
	for (unsigned long i = 0; i < glyphsToShow.length; i++)
	{
		NSRange highlightRange;
		NSColor *color = [self.textStorage attribute:XBHighlightColorAttributeName atIndex:i effectiveRange:&highlightRange];
		
		NSRect rangeRect = [self boundingRectForGlyphRange:highlightRange inTextContainer:textContainer];
		
		NSRect insetRect = NSInsetRect(rangeRect, -1, -1);
		NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:insetRect xRadius:3 yRadius:3];
		
		if (color)
		{
			[[NSColor colorWithWhite:1.0 alpha:0.5] set];
			[bezierPath stroke];
			
			[color set];
			[bezierPath fill];
			
			i = highlightRange.location + highlightRange.length;
		}
	}
}

- (void)xb_drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin
{
	[self xb_drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
}

@end