//
//  MFScrollerMark.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-05.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MFScrollerMark : NSObject

@property (copy) NSColor *color;
@property (assign) CGFloat ratio;

+ (instancetype)markWithColor:(NSColor *)color ratio:(CGFloat)ratio;

@end