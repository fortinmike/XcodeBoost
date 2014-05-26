//
//  NSMenu+XcodeBoost.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "Collector.h"
#import <Cocoa/Cocoa.h>

@interface NSMenu (XcodeBoost)

- (void)xb_insertItem:(NSMenuItem *)item beforeItem:(NSUInteger)itemIndexInMatches where:(CollectorConditionBlock)condition;
- (void)xb_insertItems:(NSArray *)items beforeItem:(NSUInteger)itemIndexInMatches where:(CollectorConditionBlock)condition;

@end