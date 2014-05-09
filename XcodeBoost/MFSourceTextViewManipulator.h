//
//  MFSourceTextViewManipulator.h
//  XcodeBoost
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
- (void)duplicateLines;
- (void)deleteLines;

#pragma mark Working With Subroutines (Methods and Functions)

- (void)selectSubroutines;
- (void)selectSubroutineSignatures;
- (void)copySubroutineDeclarations;
- (void)duplicateSubroutines;

#pragma mark Highlighting

- (void)highlightSelectedStrings;
- (void)highlightSelectedSymbols;
- (void)highlightRegexMatchesWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (void)removeMostRecentlyAddedHighlight;
- (void)removeAllHighlighting;

@end