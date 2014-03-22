//
//  MFTextViewManipulator.h
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DVTSourceTextView;

@interface MFTextViewManipulator : NSObject

- (id)initWithTextView:(DVTSourceTextView *)textView;

#pragma mark Line Manipulation

- (void)cutLines;
- (void)copyLines;
- (void)pasteLinesWithReindent:(BOOL)reindent;
- (void)duplicateLines;
- (void)deleteLines;

#pragma mark Highlighting

- (void)highlightSelection;
- (void)removeHighlighting;

#pragma mark Selection

- (void)expandSelection;

@end