//
//  NSArray+Sorting.m
//  Collector
//
//  Created by Michaël Fortin on 2014-05-12.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSArray+Sorting.h"

@implementation NSArray (Sorting)

- (NSArray *)ct_reversed
{
	return [[self reverseObjectEnumerator] allObjects];
}

- (NSArray *)ct_shuffled
{
	NSMutableArray *copy = [self mutableCopy];
	NSMutableArray *shuffled = [NSMutableArray array];
	
	while ([copy count] > 0)
	{
		int randomInteger = arc4random_uniform((int)[copy count]);
		id randomItem = copy[randomInteger];
		[shuffled addObject:randomItem];
		[copy removeObject:randomItem];
	}
	
	return [shuffled copy];
}

- (NSArray *)ct_orderedByAscending:(CollectorValueBlock)valueBlock
{
	return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
	{
		id value1 = valueBlock(obj1);
		id value2 = valueBlock(obj2);
		
		if (value1 != nil && value2 == nil)
		{
			return NSOrderedDescending;
		}
		else if (value1 == nil && value2 != nil)
		{
			return NSOrderedAscending;
		}
		else if (!value1 && !value2)
		{
			return NSOrderedSame;
		}
		if ([value1 isKindOfClass:[NSNumber class]] && [value2 isKindOfClass:[NSNumber class]])
		{
			return [(NSNumber *)value1 compare:(NSNumber *)value2];
		}
		else if ([value1 isKindOfClass:[NSString class]] && [value2 isKindOfClass:[NSString class]])
		{
			return [(NSString *)value1 localizedStandardCompare:(NSString *)value2];
		}
		else
		{
			NSString *reason = [NSString stringWithFormat:@"Cannot compare values %@ and %@ for ordering", value1, value2];
			@throw [NSException exceptionWithName:@"Ordering Exception" reason:reason userInfo:nil];
		}
	}];
}

- (NSArray *)ct_orderedByDescending:(CollectorValueBlock)valueBlock
{
	return [[self ct_orderedByAscending:valueBlock] ct_reversed];
}

@end