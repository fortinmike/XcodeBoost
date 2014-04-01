//
//  MFHighlightRegexWindowController.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-25.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XcodeBoostFoundation.h"

@interface MFHighlightRegexWindowController : NSWindowController

@property (copy) NSString *pattern;
@property (readonly) NSRegularExpressionOptions options;

@property (strong) Block highlightButtonClickedBlock;

#pragma mark Lifetime

- (id)initWithBundle:(NSBundle *)bundle;

#pragma mark Action Methods

- (IBAction)addHighlight_clicked:(id)sender;

@end