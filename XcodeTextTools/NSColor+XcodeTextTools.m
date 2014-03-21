//
//  NSColor+XcodeTextTools.m
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-21.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSColor+XcodeTextTools.h"

@implementation NSColor (XcodeTextTools)

+ (NSColor *)xctt_randomColor
{
	CGFloat randomR = arc4random_uniform(256) / 255.0;
	CGFloat randomG = arc4random_uniform(256) / 255.0;
	CGFloat randomB = arc4random_uniform(256) / 255.0;
	
	return [NSColor colorWithCalibratedRed:randomR green:randomG blue:randomB alpha:1.0];
}

@end