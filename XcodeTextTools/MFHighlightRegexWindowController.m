//
//  MFHighlightRegexWindowController.m
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-25.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFHighlightRegexWindowController.h"

@interface MFHighlightRegexWindowController ()

@property (weak) IBOutlet NSTextField *regexTextField;

@end

@implementation MFHighlightRegexWindowController

#pragma mark Lifetime

- (id)initWithBundle:(NSBundle *)bundle
{
	NSString *nibPath = [bundle pathForResource:@"HighlightRegexWindow" ofType:@"nib"];
	self = [super initWithWindowNibPath:nibPath owner:self];
	if (self)
	{
	}
	return self;
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	[self.window setLevel:NSFloatingWindowLevel];
}

#pragma mark Action Methods

- (IBAction)addHighlight_clicked:(id)sender
{
	if (self.highlightButtonClickedBlock)
		self.highlightButtonClickedBlock();
}

- (IBAction)optionCheckbox_clicked:(id)sender
{
	_options = self.caseSensitive ? 0 : NSRegularExpressionCaseInsensitive;
	_options |= self.allowCommentsAndWhitespace ? NSRegularExpressionAllowCommentsAndWhitespace : 0;
	_options |= self.ignoreMetacharacters ? NSRegularExpressionIgnoreMetacharacters : 0;
	_options |= self.dotMatchesLineSeparators ? NSRegularExpressionDotMatchesLineSeparators : 0;
	_options |= self.anchorsMatchLines ? NSRegularExpressionAnchorsMatchLines : 0;
	_options |= self.useUnixLineSeparators ? NSRegularExpressionUseUnixLineSeparators : 0;
	_options |= self.caseSensitive ? 0 : NSRegularExpressionCaseInsensitive;
	_options |= self.useUnicodeWordBoundaries ? NSRegularExpressionUseUnicodeWordBoundaries : 0;
}

@end