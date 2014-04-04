//
//  MFHighlighter.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-03.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface MFHighlighter : NSObject

#pragma mark Highlighting

- (NSColor *)pushHighlightColor;
- (NSColor *)popHighlightColor;
- (void)popAllHighlightColors;

@end