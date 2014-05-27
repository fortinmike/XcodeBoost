//
//  NSMutableArray+Stack.m
//  Collector
//
//  Created by Michaël Fortin on 2014-05-19.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSMutableArray+Stack.h"

@implementation NSMutableArray (Stack)

- (void)ct_push:(id)object
{
	[self addObject:object];
}

- (id)ct_pop
{
	if ([self count] == 0) return nil;
	id object = [self lastObject];
	[self removeLastObject];
	return object;
}

@end