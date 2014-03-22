//
//  MFTextViewManipulator.h
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MFTextViewManipulator : NSObject

- (id)initWithTextView:(NSTextView *)textView;

#pragma mark Line Manipulation

- (void)cutLines;
- (void)copyLines;
- (void)pasteLines;
- (void)duplicateLines;
- (void)deleteLines;

#pragma mark Highlighting

- (void)highlightSelection;
- (void)removeHighlighting;

#pragma mark Selection

- (void)expandSelection;

@end