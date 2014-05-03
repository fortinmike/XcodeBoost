//
//  DVTMarkedScroller+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-05.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "DVTMarkedScroller+XcodeBoost.h"
#import "MFScrollerMark.h"
#import "NSObject+XcodeBoost.h"
#import "JRSwizzle.h"

@implementation DVTMarkedScroller (XcodeBoost)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
	{
		[self jr_swizzleMethod:@selector(drawRect:) withMethod:@selector(xb_drawRect:) error:nil];
	});
}

#pragma mark Swizzled Methods

- (void)xb_drawRect:(NSRect)dirtyRect
{
	[self xb_drawRect:dirtyRect];
	
	CGFloat scrollerWidth = [NSScroller scrollerWidthForControlSize:[self controlSize] scrollerStyle:[self scrollerStyle]];
	
	for (MFScrollerMark *mark in [self xb_marks])
	{
		[mark.color set];
		
		if ([self scrollerStyle] == NSScrollerStyleLegacy)
		{
			NSRectFill(NSMakeRect(2, (int)(mark.ratio * [self bounds].size.height) - 1,
								  scrollerWidth - 4, 2));
		}
		else if ([self scrollerStyle] == NSScrollerStyleOverlay)
		{
			NSRectFill(NSMakeRect(5, (int)(mark.ratio * [self bounds].size.height) - 1,
								  scrollerWidth - 6, 2));
		}
	}
}

#pragma mark Category Methods

- (void)xb_addMarkWithColor:(NSColor *)color atRatio:(CGFloat)ratio
{
	[[self xb_marks] addObject:[MFScrollerMark markWithColor:color ratio:ratio]];
	
	[self setNeedsDisplay];
}

- (void)xb_removeMarksWithColor:(NSColor *)color
{
	NSMutableArray *marks = [self xb_marks];
	NSMutableArray *marksToRemove = [NSMutableArray array];
	
	for (MFScrollerMark *mark in marks)
	{
		if ([mark.color isEqual:color])
			[marksToRemove addObject:mark];
	}
	
	[marks removeObjectsInArray:marksToRemove];
	
	[self setNeedsDisplay];
}

- (void)xb_removeAllMarks
{
	[[self xb_marks] removeAllObjects];
	
	[self setNeedsDisplay];
}

#pragma mark Helper Methods

- (NSMutableArray *)xb_marks
{
	NSString *marksKey = @"XcodeBoostMarks";
	
	NSMutableArray *marks = [self xb_associatedObjectForKey:marksKey];
	if (!marks)
	{
		marks = [NSMutableArray array];
		[self xb_setAssociatedObject:marks forKey:marksKey];
	}
	
	return marks;
}

@end