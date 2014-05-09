//
//  NSArray+Regexer.m
//  Regexer
//
//  Created by Michaël Fortin on 2014-05-04.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSArray+Regexer.h"

@implementation NSArray (Regexer)

- (instancetype)rx_map:(ObjectObjectBlock)gatheringBlock
{
	NSMutableArray *values = [NSMutableArray array];
	
	for (id obj in self)
	{
		id value = gatheringBlock(obj);
		if (value != nil) [values addObject:value];
	}
	
	return values;
}

@end