//
//  XcodeBoostFoundation.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-21.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "XcodeBoostFoundation.h"

BOOL MFRangeOverlaps(NSRange range, NSRange targetRange)
{
	NSUInteger rangeStart = range.location;
	NSUInteger rangeEnd = range.location + range.length;
	NSUInteger targetRangeStart = targetRange.location;
	NSUInteger targetRangeEnd = targetRange.location + targetRange.length;
	
	BOOL rangeOverlapsTargetRange = (rangeStart >= targetRangeStart && rangeStart <= targetRangeEnd) ||
									(rangeEnd >= targetRangeStart && rangeEnd <= targetRangeEnd);
	
	BOOL targetRangeContainedInRange = (targetRangeStart >= rangeStart && targetRangeStart <= rangeEnd) ||
									   (targetRangeEnd >= rangeStart && targetRangeEnd <= rangeEnd);
	
	return rangeOverlapsTargetRange || targetRangeContainedInRange;
}