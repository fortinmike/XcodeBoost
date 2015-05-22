//
//  MFPluginController.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFPluginController.h"
#import "NSMenu+XcodeBoost.h"
#import "MFPreferencesWindowController.h"
#import "DVTSourceTextView+XcodeBoost.h"
#import "MFHighlightRegexWindowController.h"
#import "IDEKit.h"
#import "MFMigrationManager.h"

@implementation MFPluginController
{
	NSBundle *_pluginBundle;
	NSTextView *_activeTextView;
	
	MFPreferencesWindowController *_preferencesWindowController;
	MFHighlightRegexWindowController *_highlightRegexWindowController;
}

#pragma mark Lifetime

- (id)initWithPluginBundle:(NSBundle *)pluginBundle
{
    self = [super init];
    if (self)
    {
		_pluginBundle = pluginBundle;
		
		[self registerDefaults];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self insertMenuItems];
        }];
		[self showNewVersionWarningIfAppropriate];
    }
    return self;
}

#pragma mark Setup

- (void)registerDefaults
{
	NSString *defaultsFilePath = [_pluginBundle pathForResource:@"Defaults" ofType:@"plist"];
	NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:defaultsFilePath];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)insertMenuItems
{
	NSArray *menuItems = @[[NSMenuItem separatorItem], [self createTextToolsMenuItem]];
	
	NSMenu *editMenu = [[[NSApp mainMenu] itemWithTitle:@"Edit"] submenu];
	[editMenu xb_insertItems:menuItems beforeItem:1 where:^BOOL(NSMenuItem *item) { return [item isSeparatorItem]; }];
}

- (void)showNewVersionWarningIfAppropriate
{
	MFMigrationManager *manager = [MFMigrationManager migrationManagerWithCurrentVersion:@"1.1"];
	
	[manager whenMigratingToVersion:@"1.1" run:^
	{
		NSString *text = @"Some of XcodeBoost's menu titles have changed. Please update your XcodeBoost keyboard shortcuts through System Preferences!";
		NSAlert *alert = [NSAlert alertWithMessageText:@"Please update your XcodeBoost shortcuts" defaultButton:@"Understood!" alternateButton:nil otherButton:nil informativeTextWithFormat:text];
		[alert runModal];
	}];
}

- (NSMenuItem *)createTextToolsMenuItem
{
	NSMenu *submenu = [[NSMenu alloc] init];
	[submenu addItem:[self createMenuItemWithTitle:@"Cut Lines" action:@selector(cutLines_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Copy Lines" action:@selector(copyLines_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Paste Lines" action:@selector(pasteLines_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Paste Lines Without Reindent" action:@selector(pasteLinesWithoutReindent_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Duplicate Lines" action:@selector(duplicateLines_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Delete Lines" action:@selector(deleteLines_clicked:)]];
	[submenu addItem:[NSMenuItem separatorItem]];
	[submenu addItem:[self createMenuItemWithTitle:@"Select Methods and Functions" action:@selector(selectSubroutines_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Select Method and Function Signatures" action:@selector(selectSubroutineSignatures_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Duplicate Methods and Functions" action:@selector(duplicateSubroutines_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Copy Method and Function Declarations" action:@selector(copySubroutineDeclarations_clicked:)]];
	[submenu addItem:[NSMenuItem separatorItem]];
	[submenu addItem:[self createMenuItemWithTitle:@"Highlight Occurences of Symbol" action:@selector(highlightSelectedSymbols_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Highlight Occurences of String" action:@selector(highlightSelectedStrings_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Highlight Regex Matches" action:@selector(highlightRegexMatches_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Remove Most Recently Added Highlight" action:@selector(removeMostRecentlyAddedHighlight_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Remove All Highlighting" action:@selector(removeAllHighlighting_clicked:)]];
	[submenu addItem:[NSMenuItem separatorItem]];
	[submenu addItem:[self createMenuItemWithTitle:@"Preferences..." action:@selector(preferences_clicked:)]];
	
	NSMenuItem *textToolsMenuItem = [[NSMenuItem alloc] initWithTitle:@"XcodeBoost" action:NULL keyEquivalent:@""];
	[textToolsMenuItem setSubmenu:submenu];
	
	return textToolsMenuItem;
}

- (NSMenuItem *)createMenuItemWithTitle:(NSString *)title action:(SEL)action
{
	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
	[item setTarget:self];
	return item;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Line Manipulation Action Methods

- (void)cutLines_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] cutLines];
}

- (void)copyLines_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] copyLines];
}

- (void)pasteLines_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] pasteLinesWithReindent:YES];
}

- (void)pasteLinesWithoutReindent_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] pasteLinesWithReindent:NO];
}

- (void)duplicateLines_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] duplicateLines];
}

- (void)deleteLines_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] deleteLines];
}

#pragma mark Subroutine Manipulation Action Methods

- (void)selectSubroutines_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] selectSubroutines];
}

- (void)selectSubroutineSignatures_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] selectSubroutineSignatures];
}

- (void)duplicateSubroutines_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] duplicateSubroutines];
}

- (void)copySubroutineDeclarations_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] copySubroutineDeclarations];
}

#pragma mark Highlighting Action Methods

- (void)highlightSelectedStrings_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] highlightSelectedStrings];
}

- (void)highlightSelectedSymbols_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] highlightSelectedSymbols];
}

- (void)highlightRegexMatches_clicked:(id)sender
{
	if (!_highlightRegexWindowController)
	{
		__weak MFPluginController *wSelf = self;
		
		_highlightRegexWindowController = [[MFHighlightRegexWindowController alloc] initWithBundle:_pluginBundle];
		[_highlightRegexWindowController setHighlightButtonClickedBlock:^
		{
			__strong MFPluginController *sSelf = wSelf;
			NSString *pattern = sSelf->_highlightRegexWindowController.pattern;
			NSRegularExpressionOptions options = sSelf->_highlightRegexWindowController.options;
			
			if (!pattern) return;
			
			[[[sSelf currentSourceTextView] xb_manipulator] highlightRegexMatchesWithPattern:pattern options:options];
		}];
	}
	
	[_highlightRegexWindowController showWindow:self];
}

- (void)removeMostRecentlyAddedHighlight_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] removeMostRecentlyAddedHighlight];
}

- (void)removeAllHighlighting_clicked:(id)sender
{
	[[[self currentSourceTextView] xb_manipulator] removeAllHighlighting];
}

#pragma mark Preferences

- (void)preferences_clicked:(id)sender
{
	if (!_preferencesWindowController)
		_preferencesWindowController = [[MFPreferencesWindowController alloc] initWithBundle:_pluginBundle];
	
	[_preferencesWindowController showWindow:self];
}

#pragma mark Implementation

- (IDEEditor *)currentEditor
{
	NSWindowController *mainWindowController = [[NSApp mainWindow] windowController];
	if ([mainWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")])
	{
		IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)mainWindowController;
		IDEEditorArea *editorArea = [workspaceController editorArea];
		IDEEditorContext *editorContext = [editorArea lastActiveEditorContext];
		return [editorContext editor];
	}
	return nil;
}

- (DVTSourceTextView *)currentSourceTextView
{
	IDEEditor *currentEditor = [self currentEditor];
	
    if ([currentEditor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")])
        return (DVTSourceTextView *)[(id)currentEditor textView];
    
    if ([currentEditor isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")])
        return [(id)currentEditor performSelector:NSSelectorFromString(@"keyTextView")];
    
    return nil;
}

@end
