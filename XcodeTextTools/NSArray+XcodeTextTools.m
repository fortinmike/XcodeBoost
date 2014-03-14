//
//  NSArray+XcodeTextTools.m
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSArray+XcodeTextTools.h"

@implementation NSArray (XcodeTextTools)

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

@end