//
//  DVTSourceTextView+XcodeTextTools.h
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFTextViewManipulator.h"
#import "DVTKit.h"

@interface DVTSourceTextView (XcodeTextTools)

- (MFTextViewManipulator *)manipulator;

@end