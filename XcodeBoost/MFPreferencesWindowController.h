//
//  MFPreferencesWindowController.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-05-25.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MFPreferencesWindowController : NSWindowController

@property (weak) IBOutlet NSColorWell *colorWell1;
@property (weak) IBOutlet NSColorWell *colorWell2;
@property (weak) IBOutlet NSColorWell *colorWell3;
@property (weak) IBOutlet NSColorWell *colorWell4;

#pragma mark Lifetime

- (id)initWithBundle:(NSBundle *)bundle;

#pragma mark Action Methods

- (IBAction)well_colorChanged:(id)sender;
- (IBAction)resetColors_clicked:(id)sender;

@end