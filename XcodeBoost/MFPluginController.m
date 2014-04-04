//
//  MFPluginController.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFPluginController.h"
#import "NSMenu+XcodeBoost.h"
#import "DVTSourceTextView+XcodeBoost.h"
#import "MFHighlightRegexWindowController.h"
#import "IDEKit.h"

@implementation MFPluginController
{
	NSBundle *_pluginBundle;
	NSTextView *_activeTextView;
	
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
		[self insertMenuItems];
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
	[editMenu xctt_insertItems:menuItems beforeItem:1 where:^BOOL(NSMenuItem *item) { return [item isSeparatorItem]; }];
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
	[submenu addItem:[self createMenuItemWithTitle:@"Select Methods" action:@selector(selectMethods_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Select Method Signatures" action:@selector(selectMethodSignatures_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Duplicate Methods" action:@selector(duplicateMethods_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Copy Method Declarations" action:@selector(copyMethodDeclarations_clicked:)]];
	[submenu addItem:[NSMenuItem separatorItem]];
	[submenu addItem:[self createMenuItemWithTitle:@"Highlight Occurences of Symbol" action:@selector(highlightSelectedSymbols_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Highlight Occurences of String" action:@selector(highlightSelectedStrings_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Highlight Regex Matches" action:@selector(highlightRegexMatches_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Remove Most Recently Added Highlight" action:@selector(removeMostRecentlyAddedHighlight_clicked:)]];
	[submenu addItem:[self createMenuItemWithTitle:@"Remove All Highlighting" action:@selector(removeAllHighlighting_clicked:)]];
	
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
	[[[self currentSourceTextView] xctt_manipulator] cutLines];
}

- (void)copyLines_clicked:(id)sender
{
	[[[self currentSourceTextView] xctt_manipulator] copyLines];
}

- (void)pasteLines_clicked:(id)sender
{
	[[[self currentSourceTextView] xctt_manipulator] pasteLinesWithReindent:YES];
}

- (void)pasteLinesWithoutReindent_clicked:(id)sender
{
	[[[self currentSourceTextView] xctt_manipulator] pasteLinesWithReindent:NO];
}

- (void)duplicateLines_clicked:(id)sender
{
	[[[self currentSourceTextView] xctt_manipulator] duplicateLines];
}

- (void)deleteLines_clicked:(id)sender
{
	[[[self currentSourceTextView] xctt_manipulator] deleteLines];
}

#pragma mark Method Manipulation Action Methods

- (void)selectMethods_clicked:(id)sender
{
	[[[self currentSourceTextView] xctt_manipulator] selectMethods];
}

- (void)selectMethodSignatures_clicked:(id)sender
{
	[[[self currentSourceTextView] xctt_manipulator] selectMethodSignatures];
}

- (void)duplicateMethods_clicked:(id)sender
{
	[[[self currentSourceTextView] xctt_manipulator] duplicateMethods];
}

- (void)copyMethodDeclarations_clicked:(id)sender
{
	[[[self currentSourceTextView] xctt_manipulator] copyMethodDeclarations];
}

#pragma mark Highlighting Action Methods

- (void)highlightSelectedStrings_clicked:(id)sender
{
	[[[self currentSourceTextView] xctt_manipulator] highlightSelectedStrings];
}

- (void)highlightSelectedSymbols_clicked:(id)sender
{
	[[[self currentSourceTextView] xctt_manipulator] highlightSelectedSymbols];
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
			
			[[[sSelf currentSourceTextView] xctt_manipulator] highlightRegexMatchesWithPattern:pattern options:options];
		}];
	}
	
	[_highlightRegexWindowController showWindow:self];
}

- (void)removeMostRecentlyAddedHighlight_clicked:(id)sender
{
	[[[self currentSourceTextView] xctt_manipulator] removeMostRecentlyAddedHighlight];
}

- (void)removeAllHighlighting_clicked:(id)sender
{
	[[[self currentSourceTextView] xctt_manipulator] removeAllHighlighting];
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