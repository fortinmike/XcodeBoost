//
//  NSUserDefaults+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-05-25.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "Collector.h"
#import "NSUserDefaults+XcodeBoost.h"

@implementation NSUserDefaults (XcodeBoost)

- (NSColor *)xb_colorForKey:(NSString *)key
{
	NSString *stringRepresentation = [self stringForKey:key];
	NSString *componentsString = [stringRepresentation substringFromIndex:6];
	NSArray *components = [[componentsString componentsSeparatedByString:@","] ct_map:^id(NSString *string)
	{
		return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	}];
	
	if ([components count] != 4)
	{
		NSString *reason = [NSString stringWithFormat:@"Couldn't parse color from string %@", stringRepresentation];
		@throw [NSException exceptionWithName:@"XcodeBoost Exception" reason:reason userInfo:nil];
	}
	
	CGFloat red = [components[0] floatValue];
	CGFloat green = [components[1] floatValue];
	CGFloat blue = [components[2] floatValue];
	CGFloat alpha = [components[3] floatValue];
	
	return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
}

- (void)xb_setColor:(NSColor *)color forKey:(NSString *)key
{
	CGFloat red, green, blue, alpha;
	[color getRed:&red green:&green blue:&blue alpha:&alpha];
	
	NSString *stringRepresentation = [NSString stringWithFormat:@"color(%f, %f, %f, %f)", red, green, blue, alpha];
	
	[self setObject:stringRepresentation forKey:key];
}

@end