//
//  NSTextView+XcodeTextTools.m
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSTextView+XcodeTextTools.h"
#import "NSObject+XcodeTextTools.h"

@implementation NSTextView (XcodeTextTools)

- (MFTextViewManipulator *)manipulator
{
	MFTextViewManipulator *manipulator = [self xctt_associatedObjectForKey:@"XCTTManipulator"];
	if (!manipulator) manipulator = [[MFTextViewManipulator alloc] initWithTextView:self];
	return manipulator;
}

@end