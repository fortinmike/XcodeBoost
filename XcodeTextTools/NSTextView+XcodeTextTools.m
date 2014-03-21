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

static NSString *kXCTTManipulatorKey = @"XCTTManipulator";

- (MFTextViewManipulator *)manipulator
{
	MFTextViewManipulator *manipulator = [self xctt_associatedObjectForKey:kXCTTManipulatorKey];
	if (!manipulator)
	{
		manipulator = [[MFTextViewManipulator alloc] initWithTextView:self];
		[self xctt_setAssociatedObject:manipulator forKey:kXCTTManipulatorKey];
	}
	return manipulator;
}

@end