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

- (void)cutLine;
- (void)copyLine;
- (void)pasteLine;
- (void)duplicateLine;
- (void)deleteLine;

#pragma mark Highlighting

- (void)highlightSelection;
- (void)removeHighlighting;

#pragma mark Selection

- (void)expandSelection;

@end