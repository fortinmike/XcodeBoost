//
//  NSColor+XcodeBoost.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-21.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (XcodeBoost)

+ (NSColor *)xb_randomColor;

#pragma mark Derived Colors

- (NSColor *)darkerByPercent:(CGFloat)percentage;
- (NSColor *)lighterByPercent:(CGFloat)percentage;

#pragma mark Interpolation

+ (NSColor *)interpolateFrom:(NSColor *)fromColor to:(NSColor *)toColor percentage:(float)percentage;
- (NSColor *)interpolateFrom:(NSColor *)fromColor percentage:(float)percentage;
- (NSColor *)interpolateTo:(NSColor *)toColor percentage:(float)percentage;

#pragma mark String Representation

+ (NSColor *)xb_colorWithStringRepresentation:(NSString *)stringRepresentation;
- (NSString *)xb_stringRepresentation;

@end