//
//  NSUserDefaults+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-05-25.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "Collector.h"
#import "NSUserDefaults+XcodeBoost.h"
#import "NSColor+XcodeBoost.h"

@implementation NSUserDefaults (XcodeBoost)

- (NSColor *)xb_colorForKey:(NSString *)key
{
	return [NSColor xb_colorWithStringRepresentation:[self stringForKey:key]];
}

- (void)xb_setColor:(NSColor *)color forKey:(NSString *)key
{
	[self setObject:[color xb_stringRepresentation] forKey:key];
}

@end