//
//  MFPreferencesWindowController.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-05-25.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "XcodeBoostConstants.h"
#import "NSColor+XcodeBoost.h"
#import "NSUserDefaults+XcodeBoost.h"
#import "MFPreferencesWindowController.h"

@implementation MFPreferencesWindowController
{
	NSDictionary *_defaults;
	NSUserDefaults *_userDefaults;
}

#pragma mark Lifetime

- (id)initWithBundle:(NSBundle *)bundle
{
    NSString *nibPath = [bundle pathForResource:@"PreferencesWindow" ofType:@"nib"];
	self = [super initWithWindowNibPath:nibPath owner:self];
	if (self)
	{
		NSString *defaultsFilePath = [bundle pathForResource:@"Defaults" ofType:@"plist"];
		_defaults = [NSDictionary dictionaryWithContentsOfFile:defaultsFilePath];
		_userDefaults = [NSUserDefaults standardUserDefaults];
	}
	return self;
}

- (void)awakeFromNib
{
	[self loadHighlightColors];
}

#pragma mark Highlighting

- (void)resetHighlightColors
{
	[self.colorWell1 setColor:[NSColor xb_colorWithStringRepresentation:[_defaults objectForKey:XBHighlightColor1Key]]];
	[self.colorWell2 setColor:[NSColor xb_colorWithStringRepresentation:[_defaults objectForKey:XBHighlightColor2Key]]];
	[self.colorWell3 setColor:[NSColor xb_colorWithStringRepresentation:[_defaults objectForKey:XBHighlightColor3Key]]];
	[self.colorWell4 setColor:[NSColor xb_colorWithStringRepresentation:[_defaults objectForKey:XBHighlightColor4Key]]];
	
	[self saveHighlightColors];
}

- (void)loadHighlightColors
{
	[self.colorWell1 setColor:[_userDefaults xb_colorForKey:XBHighlightColor1Key]];
	[self.colorWell2 setColor:[_userDefaults xb_colorForKey:XBHighlightColor2Key]];
	[self.colorWell3 setColor:[_userDefaults xb_colorForKey:XBHighlightColor3Key]];
	[self.colorWell4 setColor:[_userDefaults xb_colorForKey:XBHighlightColor4Key]];
}

- (void)saveHighlightColors
{
	[_userDefaults xb_setColor:self.colorWell1.color forKey:XBHighlightColor1Key];
	[_userDefaults xb_setColor:self.colorWell2.color forKey:XBHighlightColor2Key];
	[_userDefaults xb_setColor:self.colorWell3.color forKey:XBHighlightColor3Key];
	[_userDefaults xb_setColor:self.colorWell4.color forKey:XBHighlightColor4Key];
}

#pragma mark Action Methods

- (IBAction)well_colorChanged:(id)sender
{
	[self saveHighlightColors];
}

- (IBAction)resetColors_clicked:(id)sender
{
	[self resetHighlightColors];
}

@end