//
//  NSArray+Contents.h
//  Collector
//
//  Created by Michaël Fortin on 2014-05-11.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Contents)

#pragma mark Array Contents Checking

/**
 *  Checks whether the receiver contains all of the given objects.
 *
 *  @param array The objects to search for.
 *
 *  @return YES if all of the objects are found in the receiver.
 */
- (BOOL)ct_containsObjects:(NSArray *)array;

/**
 *  Checks if the receiver contains *only* objects in the given array, regardless of their order.
 *
 *  @param array The objects to search for.
 *
 *  @return YES if the receiver contains all of the objects, but no more.
 */
- (BOOL)ct_containsOnlyObjects:(NSArray *)array;

/**
 *  Checks if the receiver contains one or more of the given objects.
 *
 *  @param objects The objects to search for.
 *
 *  @return YES if the receiver contains at least one of the receiver's objects.
 */
- (BOOL)ct_containsAnyObject:(NSArray *)objects;

/**
 *  Checks whether all objects in the array are of the specified kind.
 *
 *  @return YES if all objects are of kind *klass*.
 */
- (BOOL)ct_areObjectsKindOfClass:(Class)klass; // Checks whether all objects in the array are of the specified class or any of its subclasses

@end