//
//  MFHighlightRegexWindowController.m
//  XcodeBoost
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

#pragma mark Helpers

- (BOOL)boolValue:(NSString *)userDefaultsKey
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:userDefaultsKey];
}

#pragma mark Accessor Overrides

- (NSRegularExpressionOptions)options
{
	NSRegularExpressionOptions options = [self boolValue:@"XBRegexCaseSensitive"] ? 0 : NSRegularExpressionCaseInsensitive;
	options |= [self boolValue:@"XBRegexIgnoreMetacharacters"] ? NSRegularExpressionIgnoreMetacharacters : 0;
	options |= [self boolValue:@"XBRegexDotMatchesLineSeparators"] ? NSRegularExpressionDotMatchesLineSeparators : 0;
	options |= [self boolValue:@"XBRegexAnchorsMatchLines"] ? NSRegularExpressionAnchorsMatchLines : 0;
	options |= [self boolValue:@"XBRegexUseUnixLineSeparators"] ? NSRegularExpressionUseUnixLineSeparators : 0;
	options |= [self boolValue:@"XBRegexUseUnicodeWordBoundaries"] ? NSRegularExpressionUseUnicodeWordBoundaries : 0;
	return options;
}

@end