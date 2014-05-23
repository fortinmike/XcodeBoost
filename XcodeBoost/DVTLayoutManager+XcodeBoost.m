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
		[self jr_swizzleMethod:@selector(drawBackgroundForGlyphRange:atPoint:)
					withMethod:@selector(xb_drawBackgroundForGlyphRange:atPoint:) error:nil];
		
		[self jr_swizzleMethod:@selector(drawGlyphsForGlyphRange:atPoint:)
					withMethod:@selector(xb_drawGlyphsForGlyphRange:atPoint:) error:nil];
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
				[color set];
				NSRectFill(highlightRect);
				
				lastHighlightRect = highlightRect;
			}
		}
	}
}

- (void)xb_drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin
{
	[self xb_drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
}

@end