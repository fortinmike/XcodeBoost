//
//  NSMenu+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSMenu+XcodeBoost.h"

@implementation NSMenu (XcodeBoost)

- (void)xb_insertItem:(NSMenuItem *)item beforeItem:(NSUInteger)itemIndexInMatches where:(CollectorConditionBlock)condition
{
	[self xb_insertItems:@[item] beforeItem:itemIndexInMatches where:condition];
}

- (void)xb_insertItems:(NSArray *)items beforeItem:(NSUInteger)itemIndexInMatches where:(CollectorConditionBlock)condition
{
	NSArray *matches = [[self itemArray] ct_where:condition];
	NSMenuItem *match = (itemIndexInMatches < [matches count] ? matches[itemIndexInMatches] : [matches lastObject]);
	
	if (match)
	{
		[self xb_insertItems:items atIndex:[self indexOfItem:match]];
	}
	else
	{
		// If we didn't find a match, append the menu items
		// at the end rather than not displaying them at all.
		[self xb_addItems:items];
	}
}

- (void)xb_addItems:(NSArray *)items
{
	for (NSMenuItem *item in items)
		[self addItem:item];
}

- (void)xb_insertItems:(NSArray *)items atIndex:(NSUInteger)index
{
	for (NSMenuItem *item in [items reverseObjectEnumerator])
		[self insertItem:item atIndex:index];
}

@end