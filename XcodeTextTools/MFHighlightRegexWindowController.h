//
//  MFHighlightRegexWindowController.h
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-25.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XcodeTextToolsFoundation.h"

@interface MFHighlightRegexWindowController : NSWindowController

@property (copy) NSString *pattern;
@property (readonly) NSRegularExpressionOptions options;

@property (assign) BOOL caseSensitive;
@property (assign) BOOL allowCommentsAndWhitespace;
@property (assign) BOOL ignoreMetacharacters;
@property (assign) BOOL dotMatchesLineSeparators;
@property (assign) BOOL anchorsMatchLines;
@property (assign) BOOL useUnixLineSeparators;
@property (assign) BOOL useUnicodeWordBoundaries;

@property (strong) Block highlightButtonClickedBlock;

#pragma mark Lifetime

- (id)initWithBundle:(NSBundle *)bundle;

#pragma mark Action Methods

- (IBAction)addHighlight_clicked:(id)sender;

@end