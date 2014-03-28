//
//  NSArray+XcodeTextTools.h
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VoidObjectBlock)(id object);
typedef BOOL (^BoolObjectBlock)(id object);
typedef id (^ObjectObjectBlock)(id object);

@interface NSArray (XcodeTextTools)

- (instancetype)xctt_each:(VoidObjectBlock)operation;
- (instancetype)xctt_where:(BoolObjectBlock)condition; // Returns objects that match the specified condition
- (instancetype)xctt_map:(ObjectObjectBlock)gatheringBlock;
- (instancetype)xctt_distinct;
- (BOOL)xctt_any:(BoolObjectBlock)testBlock;

@end