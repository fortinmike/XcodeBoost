//
//  MFScrollerMark.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-05.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFScrollerMark.h"

@implementation MFScrollerMark

+ (instancetype)markWithColor:(NSColor *)color ratio:(CGFloat)ratio
{
	MFScrollerMark *mark = [[self alloc] init];
	[mark setColor:color];
	[mark setRatio:ratio];
	return mark;
}

@end