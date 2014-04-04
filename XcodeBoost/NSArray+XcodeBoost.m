//
//  NSArray+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSArray+XcodeBoost.h"

@implementation NSArray (XcodeBoost)

- (instancetype)xb_each:(VoidObjectBlock)operation
{
	for (id obj in self)
		operation(obj);
	
	return self;
}

- (instancetype)xb_where:(BoolObjectBlock)condition
{
	NSMutableArray *selectedObjects = [NSMutableArray array];
	
	for (id obj in self)
	{
		if (condition(obj))
			[selectedObjects addObject:obj];
	}
	
	return selectedObjects;
}

- (instancetype)xb_map:(ObjectObjectBlock)gatheringBlock
{
	NSMutableArray *values = [NSMutableArray array];
	
	for (id obj in self)
	{
		id value = gatheringBlock(obj);
		if (value != nil) [values addObject:value];
	}
	
	return values;
}

- (instancetype)xb_distinct
{
	NSMutableArray *distinct = [NSMutableArray array];
	
	for (id object in self)
	{
		if ([distinct indexOfObject:object] == NSNotFound)
			[distinct addObject:object];
	}
	
	return distinct;
}

- (BOOL)xb_any:(BoolObjectBlock)testBlock
{
	for (id object in self)
		if (testBlock(object)) return YES;
	
	return NO;
}

@end