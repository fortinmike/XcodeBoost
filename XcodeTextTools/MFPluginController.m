//
//  MFPluginController.m
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFPluginController.h"
#import "NSMenu+XcodeTextTools.h"

@implementation MFPluginController
{
	NSBundle *_pluginBundle;
}

#pragma mark Lifetime

- (id)initWithPluginBundle:(NSBundle *)pluginBundle
{
    self = [super init];
    if (self)
    {
		_pluginBundle = pluginBundle;
		
		[self insertMenuItems];
        [self registerForNotifications];
    }
    return self;
}

- (void)insertMenuItems
{
	NSMenuItem *textToolsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Text Tools" action:NULL keyEquivalent:@""];
	NSArray *menuItems = @[[NSMenuItem separatorItem], textToolsMenuItem];
	
	NSMenu *editMenu = [[[NSApp mainMenu] itemWithTitle:@"Edit"] submenu];
	[editMenu xctt_insertItems:menuItems beforeItem:1 where:^BOOL(NSMenuItem *item) { return [item isSeparatorItem]; }];
}

- (void)registerForNotifications
{
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(activeEditorContextDidChange:)
//												 name:@"IDEEditorAreaLastActiveEditorContextDidChangeNotification"
//											   object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Notifications

- (void)activeEditorContextDidChange:(NSNotification *)notification
{
	[[NSAlert alertWithMessageText:@"Change!" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
}

@end