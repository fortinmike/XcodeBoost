//
//  NSMutableArray+Collector.h
//  Collector
//
//  Created by Michaël Fortin on 2014-05-19.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectorBlockTypes.h"

@interface NSMutableArray (Collector)

#pragma mark Adding Objects

/**
 *  Add an object to the array if no other object in the array is equal to the given object.
 *
 *  @param object The object to conditionally add to the array.
 *
 *  @return YES if the object was added to the array.
 */
- (BOOL)ct_addObjectIfNoneEquals:(id)object;

/**
 *  Adds the object argument to the array if the argument is not nil.
 *
 *  @param object The object to insert, or nil.
 *
 *  @return YES if the object was not nil and was added to the array.
 */
- (BOOL)ct_addObjectIfNotNil:(id)object;

#pragma mark Removing Objects

/**
 *  Remove all objects that match a certain condition from the array.
 *
 *  @param conditionBlock Return YES from this block for objects you wish to remove.
 */
- (void)ct_removeObjectsWhere:(CollectorConditionBlock)conditionBlock;

@end