//
//  NSColor+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-21.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "Collector.h"
#import "NSColor+XcodeBoost.h"

@implementation NSColor (XcodeBoost)

+ (NSColor *)xb_randomColor
{
	CGFloat randomR = arc4random_uniform(256) / 255.0;
	CGFloat randomG = arc4random_uniform(256) / 255.0;
	CGFloat randomB = arc4random_uniform(256) / 255.0;
	
	return [NSColor colorWithCalibratedRed:randomR green:randomG blue:randomB alpha:1.0];
}

#pragma mark Derived Colors

- (NSColor *)darkerByPercent:(CGFloat)percentage
{
	return [self interpolateTo:[NSColor blackColor] percentage:percentage];
}

- (NSColor *)lighterByPercent:(CGFloat)percentage
{
	return [self interpolateTo:[NSColor whiteColor] percentage:percentage];
}

#pragma mark Interpolation

+ (NSColor *)interpolateFrom:(NSColor *)fromColor to:(NSColor *)toColor percentage:(float)percentage
{
	NSColor *fromRGBColor = [fromColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
	NSColor *toRGBColor = [toColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
	
    float red = XBInterpolate(percentage, [fromRGBColor redComponent], [toRGBColor redComponent]);
	float green = XBInterpolate(percentage, [fromRGBColor greenComponent], [toRGBColor greenComponent]);
	float blue = XBInterpolate(percentage, [fromRGBColor blueComponent], [toRGBColor blueComponent]);
	float alpha = XBInterpolate(percentage, [fromRGBColor alphaComponent], [toRGBColor alphaComponent]);
    
    return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
}

- (NSColor *)interpolateFrom:(NSColor *)fromColor percentage:(float)percentage
{
    return [NSColor interpolateFrom:fromColor to:self percentage:percentage];
}

- (NSColor *)interpolateTo:(NSColor *)toColor percentage:(float)percentage
{
    return [NSColor interpolateFrom:self to:toColor percentage:percentage];
}

#pragma mark String Representation

+ (NSColor *)xb_colorWithStringRepresentation:(NSString *)stringRepresentation
{
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

- (NSString *)xb_stringRepresentation
{
	CGFloat red, green, blue, alpha;
	[self getRed:&red green:&green blue:&blue alpha:&alpha];
	
	return [NSString stringWithFormat:@"color(%f, %f, %f, %f)", red, green, blue, alpha];
}

#pragma mark Helper Functions

CGFloat XBInterpolate(CGFloat value, CGFloat start, CGFloat end)
{
	return start + (end - start) * value;
}

@end