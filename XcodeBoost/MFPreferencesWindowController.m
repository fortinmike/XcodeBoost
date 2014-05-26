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

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
	{
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
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[self.colorWell1 setColor:[defaults xb_colorForKey:XBHighlightColor1Key]];
	[self.colorWell2 setColor:[defaults xb_colorForKey:XBHighlightColor2Key]];
	[self.colorWell3 setColor:[defaults xb_colorForKey:XBHighlightColor3Key]];
	[self.colorWell4 setColor:[defaults xb_colorForKey:XBHighlightColor4Key]];
}

- (void)saveHighlightColors
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults xb_setColor:self.colorWell1.color forKey:XBHighlightColor1Key];
	[defaults xb_setColor:self.colorWell2.color forKey:XBHighlightColor2Key];
	[defaults xb_setColor:self.colorWell3.color forKey:XBHighlightColor3Key];
	[defaults xb_setColor:self.colorWell4.color forKey:XBHighlightColor4Key];
}

#pragma mark Action Methods

- (IBAction)colorChanged:(id)sender
{
	[self saveHighlightColors];
}

@end