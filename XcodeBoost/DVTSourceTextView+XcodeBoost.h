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

- (MFSourceTextViewManipulator *)xctt_manipulator;

#pragma mark Working With Selections

- (NSArray *)xctt_selectedLineRanges;
- (NSRange)xctt_firstSelectedLineRange;
- (NSString *)xctt_firstSelectedLineRangeString;
- (NSArray *)xctt_rangesFullyOrPartiallyContainedInSelection:(NSArray *)rangesToFilter wholeLines:(BOOL)wholeLines;

@end