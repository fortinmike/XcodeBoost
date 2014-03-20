//
//  MFPluginController.m
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFPluginController.h"
#import "NSMenu+XcodeTextTools.h"
#import "NSString+XcodeTextTools.h"
#import "IDEKit.h"

@implementation MFPluginController
{
	NSBundle *_pluginBundle;
	NSTextView *_activeTextView;
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
	[submenu addItem:[self createMenuItemWithTitle:@"Cut Line" action:@selector(cutLine_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Copy Line" action:@selector(copyLine_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Paste Line" action:@selector(pasteLine_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Duplicate Line" action:@selector(duplicateLine_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Delete Line" action:@selector(deleteLine_clicked:)]];
	[submenu addItem:[NSMenuItem separatorItem]];
	[submenu addItem:[self createMenuItemWithTitle:@"Highlight Occurences of Selection" action:@selector(highlightSelection_clicked:)]];
	
	NSMenuItem *textToolsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Text Tools" action:NULL keyEquivalent:@""];
	[textToolsMenuItem setSubmenu:submenu];
	
	return textToolsMenuItem;
}

- (NSMenuItem *)createMenuItemWithTitle:(NSString *)title action:(SEL)action
{
	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
	[item setTarget:self];
	return item;
}

- (void)registerForNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeEditorContextDidChange:)
												 name:@"IDEEditorAreaLastActiveEditorContextDidChangeNotification" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Action Methods

- (void)cutLine_clicked:(id)sender
{
	[_activeTextView setHidden:![_activeTextView isHidden]];
}

- (void)copyLine_clicked:(id)sender
{
	[[NSAlert alertWithMessageText:@"Copy Line" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
}

- (void)pasteLine_clicked:(id)sender
{
	[[NSAlert alertWithMessageText:@"Paste Line" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
}

- (void)duplicateLine_clicked:(id)sender
{
	[[NSAlert alertWithMessageText:@"Duplicate Line" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
}

- (void)deleteLine_clicked:(id)sender
{
	[[NSAlert alertWithMessageText:@"Delete Line" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
}

- (void)highlightSelection_clicked:(id)sender
{
	NSTextStorage *textStorage = [_activeTextView textStorage];
	
	NSColor *color = [NSColor greenColor];
	
	// TODO: Find selected string(s) (selection can have multiple ranges) and highlight
	//       occurences in a different color for each range
	
	// TODO: Use associated objects to store a text tools info instance to store currently
	//       used colors for highlighting on the NSTextView and more!
	
	// TODO: Implement clearing of highlights
	
	NSString *selection = @"NS";
	NSArray *ranges = [[textStorage string] xctt_rangesOfString:selection];
	
	for (NSValue *rangeValue in ranges)
	{
		NSRange range = [rangeValue rangeValue];
		[textStorage addAttribute:NSBackgroundColorAttributeName value:color range:range];
	}
}

#pragma mark Notifications

- (void)activeEditorContextDidChange:(NSNotification *)notification
{
	IDEEditorContext *context = [notification userInfo][@"IDEEditorContext"];
    _activeTextView = [self getSourceTextViewFromEditorContext:context];
}

- (DVTSourceTextView *)getSourceTextViewFromEditorContext:(IDEEditorContext *)context
{
    IDEEditor *editor = [context editor];
    NSScrollView *scrollView = [editor mainScrollView];
    NSClipView *clipView = [scrollView contentView];
	
    id documentView = [clipView documentView];
    
	return [documentView isKindOfClass:[DVTSourceTextView class]] ? documentView : nil;
}

@end