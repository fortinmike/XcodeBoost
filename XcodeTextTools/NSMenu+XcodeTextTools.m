//
//  NSMenu+XcodeTextTools.m
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSMenu+XcodeTextTools.h"
#import "NSArray+XcodeTextTools.h"

@implementation NSMenu (XcodeTextTools)

- (void)xctt_insertItem:(NSMenuItem *)item beforeItem:(NSUInteger)itemIndexInMatches where:(BoolItemBlock)condition
{
	[self xctt_insertItems:@[item] beforeItem:itemIndexInMatches where:condition];
}

- (void)xctt_insertItems:(NSArray *)items beforeItem:(NSUInteger)itemIndexInMatches where:(BoolItemBlock)condition
{
	NSArray *matches = [[self itemArray] xctt_where:condition];
	NSMenuItem *match = (itemIndexInMatches < [matches count] ? matches[itemIndexInMatches] : [matches lastObject]);
	
	if (match)
	{
		[self xctt_insertItems:items atIndex:[self indexOfItem:match]];
	}
	else
	{
		// If we didn't find a match, append the menu items
		// at the end rather than not displaying them at all.
		[self xctt_addItems:items];
	}
}

- (void)xctt_addItems:(NSArray *)items
{
	for (NSMenuItem *item in items)
		[self addItem:item];
}

- (void)xctt_insertItems:(NSArray *)items atIndex:(NSUInteger)index
{
	for (NSMenuItem *item in [items reverseObjectEnumerator])
		[self insertItem:item atIndex:index];
}

@end