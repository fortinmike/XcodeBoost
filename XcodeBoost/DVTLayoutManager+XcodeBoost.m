//
//  DVTLayoutManager+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-05-21.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "DVTLayoutManager+XcodeBoost.h"
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
	
	NSUInteger rectCount;
	NSRectArray rects = [self rectArrayForGlyphRange:glyphsToShow withinSelectedGlyphRange:NSMakeRange(NSNotFound, 0) inTextContainer:textContainer rectCount:&rectCount];
	
	CGFloat randomRed = 0 + ((float)arc4random() / 0x100000000) * 1;
	CGFloat randomGreen = 0 + ((float)arc4random() / 0x100000000) * 1;
	CGFloat randomBlue = 0 + ((float)arc4random() / 0x100000000) * 1;
	[[NSColor colorWithRed:randomRed green:randomGreen blue:randomBlue alpha:1] set];
	if (rectCount > 0) NSRectFill(rects[0]);
}

- (void)xb_drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin
{
	[self xb_drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
}

@end