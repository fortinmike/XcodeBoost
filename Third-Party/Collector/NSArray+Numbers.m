//
//  NSArray+Numbers.m
//  Collector
//
//  Created by Michaël Fortin on 2014-05-11.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSArray+Numbers.h"
#import "NSArray+Collector.h"

@implementation NSArray (Numbers)

#pragma mark Manipulating Arrays of NSNumber Instances

- (NSNumber *)ct_min
{
	return [self ct_min:^NSNumber *(NSNumber *number) { return number; }];
}

- (NSNumber *)ct_min:(CollectorNumberBlock)numberBlock
{
	return [self ct_winner:^id(id obj1, id obj2)
	{
		return (([numberBlock(obj1) compare:numberBlock(obj2)] == NSOrderedAscending) ? obj1 : obj2);
	}];
}

- (NSNumber *)ct_max
{
	return [self ct_max:^NSNumber *(NSNumber *number) { return number; }];
}

- (NSNumber *)ct_max:(CollectorNumberBlock)numberBlock
{
	return [self ct_winner:^id(id obj1, id obj2)
	{
		return (([numberBlock(obj1) compare:numberBlock(obj2)] == NSOrderedDescending) ? obj1 : obj2);
	}];
}

- (NSNumber *)ct_sum
{
	return [self ct_reduce:^id(NSNumber *cumulated, NSNumber *number)
	{
		return @([cumulated doubleValue] + [number doubleValue]);
	}];
}

- (NSNumber *)ct_sum:(CollectorNumberBlock)numberBlock
{
	return [self ct_reduceWithSeed:@0 block:^id(NSNumber *cumulated, id object)
	{
		return @([cumulated doubleValue] + [numberBlock(object) doubleValue]);
	}];
}

- (NSNumber *)ct_average
{
	return [self ct_average:^NSNumber *(NSNumber *number) { return number; }];
}

- (NSNumber *)ct_average:(CollectorNumberBlock)numberBlock
{
	double sum = 0;
	
	for (id object in self)
		sum += [numberBlock(object) doubleValue];
	
	return @(sum / [self count]);
}

@end