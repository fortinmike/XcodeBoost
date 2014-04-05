//
//  DVTMarkedScroller+XcodeBoost.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-05.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DVTKit.h"

@interface DVTMarkedScroller (XcodeBoost)

- (void)xb_addMarkWithColor:(NSColor *)color atRatio:(CGFloat)ratio;
- (void)xb_removeMarksWithColor:(NSColor *)color;
- (void)xb_removeAllMarks;

@end