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
	NSArray *menuItems = @[[NSMenuItem separatorItem], [self createTextToolsMenuItem]];
	
	NSMenu *editMenu = [[[NSApp mainMenu] itemWithTitle:@"Edit"] submenu];
	[editMenu xctt_insertItems:menuItems beforeItem:1 where:^BOOL(NSMenuItem *item) { return [item isSeparatorItem]; }];
}

- (NSMenuItem *)createTextToolsMenuItem
{
	NSMenu *submenu = [[NSMenu alloc] init];
	[submenu addItem:[[NSMenuItem alloc] initWithTitle:@"Cut Line" action:nil keyEquivalent:@""]];
	[submenu addItem:[[NSMenuItem alloc] initWithTitle:@"Copy Line" action:nil keyEquivalent:@""]];
	[submenu addItem:[[NSMenuItem alloc] initWithTitle:@"Paste Line" action:nil keyEquivalent:@""]];
	[submenu addItem:[[NSMenuItem alloc] initWithTitle:@"Duplicate Line" action:nil keyEquivalent:@""]];
	[submenu addItem:[[NSMenuItem alloc] initWithTitle:@"Delete Line" action:nil keyEquivalent:@""]];
	
	NSMenuItem *textToolsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Text Tools" action:NULL keyEquivalent:@""];
	[textToolsMenuItem setSubmenu:submenu];
	
	return textToolsMenuItem;
}

- (void)registerForNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(activeEditorContextDidChange:)
												 name:@"IDEEditorAreaLastActiveEditorContextDidChangeNotification"
											   object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Notifications

- (void)activeEditorContextDidChange:(NSNotification *)notification
{
	NSLog(@"Test");
	
//	IDEEditorContext *context = [notification userInfo][@"IDEEditorContext"];
//    self.activeEditor = [self getSourceTextViewFromEditorContext:context];
}

//- (DVTSourceTextView *)getSourceTextViewFromEditorContext:(IDEEditorContext *)context
//{
//    IDEEditor *editor = [context editor];
//    NSScrollView *scrollView = [editor mainScrollView];
//    NSClipView *clipView = [scrollView contentView];
//    id documentView = [clipView documentView];
//    if ([documentView isKindOfClass:[DVTSourceTextView class]]) {
//        return documentView;
//    } else {
//        return nil;
//    }
//}

@end