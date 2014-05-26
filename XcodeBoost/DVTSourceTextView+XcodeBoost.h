//
//  DVTSourceTextView+XcodeBoost.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFSourceTextViewManipulator.h"
#import "DVTKit.h"

@interface DVTSourceTextView (XcodeBoost)

#pragma mark Obtaining the Manipulator Instance

- (MFSourceTextViewManipulator *)xb_manipulator;

#pragma mark Working With Selections

- (NSArray *)xb_selectedLineRanges;
- (NSRange)xb_firstSelectedLineRange;
- (NSString *)xb_firstSelectedLineRangeString;
- (NSArray *)xb_rangesFullyOrPartiallyContainedInSelection:(NSArray *)rangesToFilter wholeLines:(BOOL)wholeLines;
- (BOOL)xb_rangeIsFullyOrPartiallyContainedInSelection:(NSRange)range wholeLines:(BOOL)wholeLines;

@end