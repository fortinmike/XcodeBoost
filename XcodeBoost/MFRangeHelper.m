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
		if ([self range:[range rangeValue] isFullyOrPartiallyContainedInRanges:targetRanges])
			[rangesOverlappingSelection addObject:range];
	}
	
	return rangesOverlappingSelection;
}

+ (BOOL)range:(NSRange)range isFullyOrPartiallyContainedInRanges:(NSArray *)containerRanges
{
	for (NSValue *containerRange in containerRanges)
	{
		if (MFRangeOverlaps(range, [containerRange rangeValue]))
			return YES;
	}
	
	return NO;
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