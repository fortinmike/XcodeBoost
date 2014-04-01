//
//  DVTSourceTextView+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "DVTSourceTextView+XcodeBoost.h"
#import "NSObject+XcodeBoost.h"

@implementation DVTSourceTextView (XcodeBoost)

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