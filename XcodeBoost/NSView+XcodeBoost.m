//
//  NSView+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-04.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSView+XcodeBoost.h"

@implementation NSView (XcodeBoost)

- (NSView *)ancestorOfKind:(Class)kind
{
	NSView *superview = [self superview];
	if ([superview isKindOfClass:kind]) return superview;
	return [superview ancestorOfKind:kind];
}

- (NSArray *)descendantsOfKind:(Class)kind
{
	NSMutableArray *childrenOfKind = [NSMutableArray array];
	for (NSView *child in [self subviews])
	{
		if ([child isKindOfClass:kind]) [childrenOfKind addObject:child];
		[childrenOfKind addObjectsFromArray:[child descendantsOfKind:kind]];
	}
	return childrenOfKind;
}

@end