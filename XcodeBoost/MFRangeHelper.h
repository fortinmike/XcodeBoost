//
//  MFRangeHelper.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-03.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFRangeHelper : NSObject

+ (NSArray *)ranges:(NSArray *)rangesToFilter fullyOrPartiallyContainedInRanges:(NSArray *)targetRanges;
+ (BOOL)range:(NSRange)range isFullyOrPartiallyContainedInRanges:(NSArray *)containerRanges;
+ (NSRange)unionRangeWithRanges:(NSArray *)ranges;

@end