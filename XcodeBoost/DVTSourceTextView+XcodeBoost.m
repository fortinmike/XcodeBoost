//
//  DVTSourceTextView+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "DVTSourceTextView+XcodeBoost.h"
#import "MFRangeHelper.h"
#import "NSObject+XcodeBoost.h"
#import "NSString+XcodeBoost.h"

@implementation DVTSourceTextView (XcodeBoost)

static NSString *kXBManipulatorKey = @"XBManipulator";

#pragma mark Obtaining the Manipulator Instance

- (MFSourceTextViewManipulator *)xb_manipulator
{
	MFSourceTextViewManipulator *manipulator = [self xb_associatedObjectForKey:kXBManipulatorKey];
	if (!manipulator)
	{
		manipulator = [[MFSourceTextViewManipulator alloc] initWithSourceTextView:self];
		[self xb_setAssociatedObject:manipulator forKey:kXBManipulatorKey];
	}
	return manipulator;
}

#pragma mark Working With Selections

- (NSArray *)xb_selectedLineRanges
{
	NSArray *selectedRanges = [self selectedRanges];
	return [self.string xb_lineRangesForRanges:selectedRanges];
}

- (NSRange)xb_firstSelectedLineRange
{
	NSValue *selectedRange = [[self selectedRanges] firstObject];
	if (!selectedRange) return NSMakeRange(NSNotFound, 0);
	
	return [self.string lineRangeForRange:[selectedRange rangeValue]];
}

- (NSString *)xb_firstSelectedLineRangeString
{
	NSRange linesRange = [self xb_firstSelectedLineRange];
	NSString *sourceString = [[self.textStorage attributedSubstringFromRange:linesRange] string];
	NSString *trimmedString = [sourceString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	return trimmedString;
}

- (NSArray *)xb_rangesFullyOrPartiallyContainedInSelection:(NSArray *)rangesToFilter wholeLines:(BOOL)wholeLines
{
	NSArray *selectedRanges = wholeLines ? [self xb_selectedLineRanges] : [self selectedRanges];
	NSArray *rangesOverlappingSelection = [MFRangeHelper ranges:rangesToFilter fullyOrPartiallyContainedInRanges:selectedRanges];
	
	return rangesOverlappingSelection;
}

- (BOOL)xb_rangeIsFullyOrPartiallyContainedInSelection:(NSRange)range wholeLines:(BOOL)wholeLines
{
	NSArray *selectedRanges = wholeLines ? [self xb_selectedLineRanges] : [self selectedRanges];
	return [MFRangeHelper range:range isFullyOrPartiallyContainedInRanges:selectedRanges];
}

@end