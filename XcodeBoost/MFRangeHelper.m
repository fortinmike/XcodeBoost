//
//  MFRangeHelper.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-03.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFRangeHelper.h"

@implementation MFRangeHelper

+ (NSArray *)ranges:(NSArray *)rangesToFilter fullyOrPartiallyContainedInRanges:(NSArray *)targetRanges
{
	NSMutableArray *rangesOverlappingSelection = [NSMutableArray array];
	for (NSValue *range in rangesToFilter)
	{
		for (NSValue *selectedRange in targetRanges)
		{
			if (MFRangeOverlaps([range rangeValue], [selectedRange rangeValue]))
				[rangesOverlappingSelection addObject:range];
		}
	}
	
	return rangesOverlappingSelection;
}

+ (NSRange)unionRangeWithRanges:(NSArray *)ranges
{
	if ([ranges count] == 0)
		return NSMakeRange(NSNotFound, 0);
	
	NSRange unionRange = [ranges[0] rangeValue];
	
	for (int i = 1; i < [ranges count]; i++)
		unionRange = NSUnionRange([ranges[i] rangeValue], unionRange);
	
	return unionRange;
}

@end