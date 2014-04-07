//
//  MFIDEHelper.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-07.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFIDEHelper.h"

@implementation MFIDEHelper

+ (IDEEditor *)currentEditor
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

+ (DVTSourceTextView *)currentSourceTextView
{
	IDEEditor *currentEditor = [self currentEditor];
	
    if ([currentEditor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")])
        return (DVTSourceTextView *)[(id)currentEditor textView];
    
    if ([currentEditor isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")])
        return [(id)currentEditor performSelector:NSSelectorFromString(@"keyTextView")];
    
    return nil;
}

+ (NSString *)currentFile
{
	IDEEditor *currentEditor = [self currentEditor];
	
    if (![currentEditor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")])
        return nil;
	
	return [[[currentEditor document] filePath] pathString];
}

@end