//
//  NSArray+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSArray+XcodeBoost.h"

@implementation NSArray (XcodeBoost)

- (instancetype)xctt_each:(VoidObjectBlock)operation
{
	for (id obj in self)
		operation(obj);
	
	return self;
}

- (instancetype)xctt_where:(BoolObjectBlock)condition
{
	NSMutableArray *selectedObjects = [NSMutableArray array];
	
	for (id obj in self)
	{
		if (condition(obj))
			[selectedObjects addObject:obj];
	}
	
	return selectedObjects;
}

- (instancetype)xctt_map:(ObjectObjectBlock)gatheringBlock
{
	NSMutableArray *values = [NSMutableArray array];
	
	for (id obj in self)
	{
		id value = gatheringBlock(obj);
		if (value != nil) [values addObject:value];
	}
	
	return values;
}

- (instancetype)xctt_distinct
{
	NSMutableArray *distinct = [NSMutableArray array];
	
	for (id object in self)
	{
		if ([distinct indexOfObject:object] == NSNotFound)
			[distinct addObject:object];
	}
	
	return distinct;
}

- (BOOL)xctt_any:(BoolObjectBlock)testBlock
{
	for (id object in self)
		if (testBlock(object)) return YES;
	
	return NO;
}

@end