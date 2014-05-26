//
//  MFPreferencesWindowController.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-05-25.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "XcodeBoostConstants.h"
#import "NSUserDefaults+XcodeBoost.h"
#import "MFPreferencesWindowController.h"

@implementation MFPreferencesWindowController
{
	NSUserDefaults *_defaults;
}

#pragma mark Lifetime

- (id)initWithBundle:(NSBundle *)bundle
{
    NSString *nibPath = [bundle pathForResource:@"PreferencesWindow" ofType:@"nib"];
	self = [super initWithWindowNibPath:nibPath owner:self];
	if (self)
	{
		_defaults = [NSUserDefaults standardUserDefaults];
	}
	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	
	[self loadHighlightColors];
}

#pragma mark Highlighting

- (void)loadHighlightColors
{
	[self.colorWell1 setColor:[_defaults xb_colorForKey:XBHighlightColor1Key]];
	[self.colorWell2 setColor:[_defaults xb_colorForKey:XBHighlightColor2Key]];
	[self.colorWell3 setColor:[_defaults xb_colorForKey:XBHighlightColor3Key]];
	[self.colorWell4 setColor:[_defaults xb_colorForKey:XBHighlightColor4Key]];
}

- (void)saveHighlightColors
{
	[_defaults xb_setColor:self.colorWell1.color forKey:XBHighlightColor1Key];
	[_defaults xb_setColor:self.colorWell2.color forKey:XBHighlightColor2Key];
	[_defaults xb_setColor:self.colorWell3.color forKey:XBHighlightColor3Key];
	[_defaults xb_setColor:self.colorWell4.color forKey:XBHighlightColor4Key];
}

#pragma mark Action Methods

- (IBAction)colorChanged:(id)sender
{
	[self saveHighlightColors];
}

@end