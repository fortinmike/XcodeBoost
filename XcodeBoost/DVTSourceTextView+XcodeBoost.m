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

static NSString *kXCTTManipulatorKey = @"XCTTManipulator";

#pragma mark Obtaining the Manipulator Instance

- (MFSourceTextViewManipulator *)xctt_manipulator
{
	MFSourceTextViewManipulator *manipulator = [self xctt_associatedObjectForKey:kXCTTManipulatorKey];
	if (!manipulator)
	{
		manipulator = [[MFSourceTextViewManipulator alloc] initWithSourceTextView:self];
		[self xctt_setAssociatedObject:manipulator forKey:kXCTTManipulatorKey];
	}
	return manipulator;
}

#pragma mark Working With Selections

- (NSArray *)xctt_selectedLineRanges
{
	NSArray *selectedRanges = [self selectedRanges];
	return [self.string xctt_lineRangesForRanges:selectedRanges];
}

- (NSRange)xctt_firstSelectedLineRange
{
	NSValue *selectedRange = [[self selectedRanges] firstObject];
	if (!selectedRange) return NSMakeRange(NSNotFound, 0);
	
	return [self.string lineRangeForRange:[selectedRange rangeValue]];
}

- (NSString *)xctt_firstSelectedLineRangeString
{
	NSRange linesRange = [self xctt_firstSelectedLineRange];
	NSString *sourceString = [[self.textStorage attributedSubstringFromRange:linesRange] string];
	NSString *trimmedString = [sourceString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	return trimmedString;
}

- (NSArray *)xctt_rangesFullyOrPartiallyContainedInSelection:(NSArray *)rangesToFilter wholeLines:(BOOL)wholeLines
{
	NSArray *selectedRanges = wholeLines ? [self xctt_selectedLineRanges] : [self selectedRanges];
	NSArray *rangesOverlappingSelection = [MFRangeHelper ranges:rangesToFilter fullyOrPartiallyContainedInRanges:selectedRanges];
	
	return rangesOverlappingSelection;
}

@end