//
//  DVTSourceTextView+XcodeTextTools.m
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "DVTSourceTextView+XcodeTextTools.h"
#import "NSObject+XcodeTextTools.h"

@implementation DVTSourceTextView (XcodeTextTools)

static NSString *kXCTTManipulatorKey = @"XCTTManipulator";

- (MFSourceTextViewManipulator *)manipulator
{
	MFSourceTextViewManipulator *manipulator = [self xctt_associatedObjectForKey:kXCTTManipulatorKey];
	if (!manipulator)
	{
		manipulator = [[MFSourceTextViewManipulator alloc] initWithSourceTextView:self];
		[self xctt_setAssociatedObject:manipulator forKey:kXCTTManipulatorKey];
	}
	return manipulator;
}

@end