//
//  NSMutableArray+Stack.h
//  Collector
//
//  Created by Michaël Fortin on 2014-05-19.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Stack)

/**
 *  Push an array at the top of the stack (the end of the array).
 *
 *  @param object The object to push.
 */
- (void)ct_push:(id)object;

/**
 *  Pop an item from the top of the stack (the end of the array).
 *
 *  @return The popped object or nil if the array is empty.
 */
- (id)ct_pop;

@end