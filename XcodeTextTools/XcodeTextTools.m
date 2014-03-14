//
//  XcodeTextTools.m
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-14.
//    Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "XcodeTextTools.h"

static XcodeTextTools *sharedPlugin;

@interface XcodeTextTools()

@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation XcodeTextTools

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"])
	{
        dispatch_once(&onceToken, ^{ sharedPlugin = [[self alloc] initWithBundle:plugin]; });
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init])
	{
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        
        // Create menu items, initialize UI, etc.
		
        // Sample Menu Item:
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
        if (menuItem)
		{
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@""];
            [actionMenuItem setTarget:self];
            [[menuItem submenu] addItem:actionMenuItem];
        }
    }
    return self;
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Hello, World" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [alert runModal];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
