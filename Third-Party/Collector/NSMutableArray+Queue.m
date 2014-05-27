//
//  NSMutableArray+Queue.m
//  Collector
//
//  Created by Michaël Fortin on 2014-05-19.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSMutableArray+Queue.h"

@implementation NSMutableArray (Queue)

- (void)ct_enqueue:(id)object
{
	[self addObject:object];
}

- (id)ct_dequeue
{
	if ([self count] == 0) return nil;
	id object = [self objectAtIndex:0];
	[self removeObjectAtIndex:0];
	return object;
}

@end