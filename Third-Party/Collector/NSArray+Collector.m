//
//  NSArray+Collector.m
//  Collector
//
//  Created by Michaël Fortin on 12-07-09.
//  Copyright (c) 2012 irradiated.net. All rights reserved.
//

#import "NSArray+Collector.h"

@implementation NSArray (Collector)

#pragma mark Creating Other Instances

- (NSArray *)ct_arrayByRemovingObject:(id)object
{
	return [self ct_arrayByRemovingObjectsInArray:@[object]];
}

- (NSArray *)ct_arrayByRemovingObjectsInArray:(NSArray *)array
{
	NSMutableArray *newArray = [self mutableCopy];
	[newArray removeObjectsInArray:array];
	return [newArray copy];
}

#pragma mark Block-based Array Manipulation and Filtering

- (id)ct_first:(CollectorConditionBlock)condition
{
	for (id object in self)
		if (condition(object)) return object;
	
	return nil;
}

- (id)ct_first:(CollectorConditionBlock)condition orDefault:(id)defaultObject
{
	return [self ct_first:condition] ?: defaultObject;
}

- (id)ct_last:(CollectorConditionBlock)condition
{
	return [[[self reverseObjectEnumerator] allObjects] ct_first:condition];
}

- (id)ct_last:(CollectorConditionBlock)condition orDefault:(id)defaultObject
{
	return [self ct_last:condition] ?: defaultObject;
}

- (NSArray *)ct_where:(CollectorConditionBlock)condition
{
	NSMutableArray *selectedObjects = [NSMutableArray array];
	
	for (id obj in self)
	{
		if (condition(obj))
			[selectedObjects addObject:obj];
	}
	
	return [selectedObjects copy];
}

- (NSArray *)ct_map:(CollectorValueBlock)valueBlock
{
	NSMutableArray *values = [NSMutableArray array];
	
	for (id obj in self)
	{
		id value = valueBlock(obj);
		if (value != nil) [values addObject:value];
	}
	
	return [values copy];
}

- (id)ct_reduce:(id(^)(id cumulated, id object))reducingBlock
{
	id result = [self firstObject];
	
	for (int i = 1; i < [self count]; i++)
		result = reducingBlock(result, self[i]);
	
	return result;
}

- (id)ct_reduceWithSeed:(id)seed block:(id(^)(id cumulated, id object))reducingBlock
{
	id result = seed;
	
	for (id obj in self)
		result = reducingBlock(result, obj);
	
	return result;
}

- (void)ct_each:(CollectorOperationBlock)operation
{
	for (id obj in self)
		operation(obj);
}

- (void)ct_eachWithIndex:(void(^)(id object, NSUInteger index, BOOL *stop))operation
{
	[self enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop)
	{
		operation(object, index, stop);
	}];
}

- (NSArray *)ct_except:(CollectorConditionBlock)condition
{
	return [self ct_where:^BOOL(id object){ return !condition(object); }];
}

- (NSArray *)ct_take:(NSUInteger)amount
{
	return [[self ct_objectsInRange:NSMakeRange(0, MIN(amount, [self count]))] mutableCopy];
}

- (NSArray *)ct_distinct
{
	NSMutableArray *distinct = [NSMutableArray array];
	
	for (id object in self)
	{
		if ([distinct indexOfObject:object] == NSNotFound)
			[distinct addObject:object];
	}
	
	return [distinct copy];
}

- (NSArray *)ct_distinct:(CollectorValueBlock)valueBlock
{
	NSMutableArray *distinct = [self ct_reduceWithSeed:[NSMutableArray array] block:^id(NSMutableArray *cumulated, id object)
	{
		id value = valueBlock(object);
		BOOL objectAlreadyInArray = [cumulated ct_any:^(id tested) { return [valueBlock(tested) isEqual:value]; }];
		if (!objectAlreadyInArray) [cumulated addObject:object];
		return cumulated;
	}];
	
	return [distinct copy];
}

- (NSArray *)ct_objectsInRange:(NSRange)range
{
	return [self objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
}

- (NSArray *)ct_objectsOfKind:(Class)kind
{
	return [self ct_where:^BOOL(id object) { return [object isKindOfClass:kind]; }];
}

- (id)ct_winner:(id(^)(id object1, id object2))comparisonBlock
{
	if ([self count] == 0) return nil;
	if ([self count] == 1) return self[0];
	
	__block id winner = self[0];
	
	for (id contestant in self)
		winner = comparisonBlock(winner, contestant);
	
	return winner;
}

- (BOOL)ct_all:(CollectorConditionBlock)testBlock
{
	BOOL success = YES;
	
	for (id object in self)
		success &= testBlock(object);
	
	return success;
}

- (BOOL)ct_any:(CollectorConditionBlock)testBlock
{
	for (id object in self)
		if (testBlock(object)) return YES;
	
	return NO;
}

- (BOOL)ct_none:(CollectorConditionBlock)testBlock
{
	BOOL success = YES;
	
	for (id object in self)
		success &= !testBlock(object);
	
	return success;
}

- (NSUInteger)ct_count:(CollectorConditionBlock)testBlock
{
	NSUInteger count = 0;
	
	for (id object in self)
		count += testBlock(object);
	
	return count;
}

@end