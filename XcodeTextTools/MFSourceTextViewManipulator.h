//
//  MFSourceTextViewManipulator.h
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DVTSourceTextView;

@interface MFSourceTextViewManipulator : NSObject

- (id)initWithSourceTextView:(DVTSourceTextView *)textView;

#pragma mark Line Manipulation

- (void)cutLines;
- (void)copyLines;
- (void)pasteLinesWithReindent:(BOOL)reindent;
- (void)pasteMethodDeclarations;
- (void)duplicateLines;
- (void)deleteLines;

#pragma mark Highlighting

- (void)highlightSelectedStrings;
- (void)removeMostRecentlyAddedHighlight;
- (void)removeAllHighlighting;

#pragma mark Selection

- (void)selectMethods;
- (void)selectMethodSignatures;
- (void)duplicateMethods;

@end