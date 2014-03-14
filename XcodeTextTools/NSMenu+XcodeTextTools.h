//
//  NSMenu+XcodeTextTools.h
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef BOOL (^BoolItemBlock)(NSMenuItem *item);

@interface NSMenu (XcodeTextTools)

- (void)xctt_insertItem:(NSMenuItem *)item beforeItem:(NSUInteger)itemIndexInMatches where:(BoolItemBlock)condition;
- (void)xctt_insertItems:(NSArray *)items beforeItem:(NSUInteger)itemIndexInMatches where:(BoolItemBlock)condition;

@end