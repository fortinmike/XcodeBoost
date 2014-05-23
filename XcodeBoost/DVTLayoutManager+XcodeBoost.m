//
//  DVTLayoutManager+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-05-21.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "DVTLayoutManager+XcodeBoost.h"
#import "XcodeBoostConstants.h"
#import "NSColor+XcodeBoost.h"
#import "JRSwizzle.h"

@implementation DVTLayoutManager (XcodeBoost)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
	{
		[self jr_swizzleMethod:@selector(drawBackgroundForGlyphRange:atPoint:)
					withMethod:@selector(xb_drawBackgroundForGlyphRange:atPoint:) error:nil];
	});
}

#pragma mark Swizzled Methods

- (void)xb_drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin
{
	[self xb_drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
	
	NSRect lastHighlightRect = NSZeroRect;
	
	for (unsigned long i = 0; i < glyphsToShow.length; i++)
	{
		unsigned long glyphIndex = glyphsToShow.location + i;
		
		NSRange highlightRange;
		NSColor *color = [self.textStorage attribute:XBHighlightColorAttributeName atIndex:glyphIndex effectiveRange:&highlightRange];
		
		if (color)
		{
			NSTextContainer *textContainer = [self textContainerForGlyphAtIndex:glyphIndex effectiveRange:NULL];
			NSRect highlightRect = [self boundingRectForGlyphRange:highlightRange inTextContainer:textContainer];
			
			if (!NSEqualRects(highlightRect, lastHighlightRect))
			{
				NSRect insetRect = NSInsetRect(highlightRect, -2, -1);
				NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:insetRect xRadius:2 yRadius:2];
				
				[color set];
				[path fill];
				
				[[color lighterByPercent:0.5] set];
				[path stroke];
				
				lastHighlightRect = highlightRect;
			}
		}
	}
}

@end