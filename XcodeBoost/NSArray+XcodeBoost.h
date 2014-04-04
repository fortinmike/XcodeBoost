//
//  NSArray+XcodeBoost.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VoidObjectBlock)(id object);
typedef BOOL (^BoolObjectBlock)(id object);
typedef id (^ObjectObjectBlock)(id object);

@interface NSArray (XcodeBoost)

- (instancetype)xb_each:(VoidObjectBlock)operation;
- (instancetype)xb_where:(BoolObjectBlock)condition; // Returns objects that match the specified condition
- (instancetype)xb_map:(ObjectObjectBlock)gatheringBlock;
- (instancetype)xb_distinct;
- (BOOL)xb_any:(BoolObjectBlock)testBlock;

@end