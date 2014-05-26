//
//  NSArray+Collector.h
//  Collector
//
//  Created by Michaël Fortin on 12-07-09.
//  Copyright (c) 2012 irradiated.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectorBlockTypes.h"

@interface NSArray (Collector)

#pragma mark Creating Other Instances

/**
 *  Returns an array that is the same as the receiver but with the given object removed if it was present.
 *
 *  @param object The object to remove.
 *
 *  @return A new array containing all of the receiver's objects but the ones that are equal to the given object.
 */
- (NSArray *)ct_arrayByRemovingObject:(id)object;

/**
 *  Returns an array that is the same as the receiver but with the given objects removed if they were present.
 *
 *  @param array The objects to remove.
 *
 *  @return A new array containing all of the receiver's objects but the ones that are equal to the given objects.
 */
- (NSArray *)ct_arrayByRemovingObjectsInArray:(NSArray *)array;

#pragma mark Block-based Array Manipulation and Filtering

/**
 *  Returns the first object that matches *condition* or nil if no object matches the condition.
 *
 *  @param condition A block that tests a single object for match.
 *
 *  @return The first object that matches the condition or nil if there is no match.
 */
- (id)ct_first:(CollectorConditionBlock)condition;

/**
 *  Returns the first object that matches *condition* or the specified default value.
 *
 *  @param condition     A block that tests a single object for match.
 *  @param defaultObject The object that gets returned if no object was found.
 */
- (id)ct_first:(CollectorConditionBlock)condition orDefault:(id)defaultObject;

/**
 *  Returns the last object that matches a condition.
 *
 *  @param condition A block that tests a single object for match.
 *
 *  @return The last object that matches the condition, or nil if there is no match.
 */
- (id)ct_last:(CollectorConditionBlock)condition;

/**
 *  Returns the last object that matches *condition* or the specified default value.
 *
 *  @param condition     A block that tests a single object for match.
 *  @param defaultObject The object that gets returned if no object was found.
 */
- (id)ct_last:(CollectorConditionBlock)condition orDefault:(id)defaultObject;

/**
 *  Selects items that match *condition*.
 *
 *  @param condition A block that tests a single object for match.
 *
 *  @return All objects that match the specified condition.
 */
- (NSArray *)ct_where:(CollectorConditionBlock)condition;

/**
 *  Creates a new array containing the objects returned from the gathering block.
 *
 *  @param gatheringBlock A block that extracts a value from each of the receiver's objects,
 *                        or creates entirely new objects constructed from those values.
 *
 *  @return An array containing all objects returned from invocations of the gathering block.
 */
- (NSArray *)ct_map:(CollectorValueBlock)gatheringBlock;

/**
 *  Returns a single value by applying the block to all of the receiver's objects in sequence and cumulating the results.
 *  The *cumulated* block parameter is nil for the first block invocation.
 *
 *  @param reducingBlock A block that returns the cumulated value at each iteration.
 *  @param cumulated The last value that was returned from *reducingBlock*.
 *  @param object The current array object.
 *
 *  @return The cumulated value after invoking *reducingBlock* on each of the receiver's objects.
 */
- (id)ct_reduce:(id(^)(id cumulated, id object))reducingBlock;

/**
 *  Same as -reduce: but with an initial seed value.
 */
- (id)ct_reduceWithSeed:(id)seed block:(id(^)(id cumulated, id object))reducingBlock;

/**
 *  Iterates over each object and performs the given operation with each object as an argument.
 *  Equivalent to a *for each* but makes for a clean one-liner when iterating over array elements.
 *
 *  @param operation The operation to perform for each of the array's objects.
 */
- (void)ct_each:(CollectorOperationBlock)operation;

/**
 *  Iterates over each object and performs the given operation with each object and the current index as arguments.
 *  Useful when you care both about the current object and that object's index in the array.
 *
 *  @param operation The operation to perform for each of the array's objects.
 */
- (void)ct_eachWithIndex:(void(^)(id object, NSUInteger index, BOOL *stop))operation;

/**
 *  Selects all objects but those that match the specified condition.
 *
 *  @param condition A block that tests a single object for match.
 *
 *  @return All objects that *don't* match the specified condition.
 */
- (NSArray *)ct_except:(CollectorConditionBlock)condition;

/**
 *  Returns a given number of items from the array.
 *
 *  @param count The number of objects to take.
 *
 *  @return The first *[amount]* objects of the array or fewer objects if the array is smaller than the specified amount.
 */
- (NSArray *)ct_take:(NSUInteger)amount;

/**
 *  Eliminates duplicates from an array by comparing objects together using -isEqual:.
 *
 *  @return A new array containing only distinct objects (no duplicates).
 */
- (NSArray *)ct_distinct;

/**
 *  Eliminates duplicates from an array by comparing the return value of *valueBlock* instead of comparing objects directly.
 *  For example, given an array that contains Person objects and a *valueBlock* that returns a person's first name, the resulting
 *  array would contain only one Person object per distinct first name.
 *
 *  @param valueBlock A block that returns the value to use for comparison..
 *
 *  @return A new array containing only one object per distinct value returned from *valueBlock*.
 */
- (NSArray *)ct_distinct:(CollectorValueBlock)valueBlock;

/**
 *  Obtains a range of objects from the array.
 *
 *  @param range The range of objects to obtain.
 *
 *  @return A new array containing the objects for the given range in the receiver.
 */
- (NSArray *)ct_objectsInRange:(NSRange)range;

/**
 *  Returns all objects whose class is the same as the specified kind.
 *
 *  @param kind The class of objects to obtain from the receiver.
 *
 *  @return A new array containing all objects that are of the given kind.
 */
- (NSArray *)ct_objectsOfKind:(Class)kind;

/**
 *  Compares all array objects using the given *comparisonBlock* and returns the final winner.
 *
 *  @param comparisonBlock The comparison operation to determine the winner between any two objects.
 *
 *  @return The object that wins the comparison against all other array objects.
 */
- (id)ct_winner:(id(^)(id object1, id object2))comparisonBlock;

/**
 *  Tests each array object and returns YES only when all objects pass the test.
 *
 *  @param testBlock The test to perform for each object. Return YES when the object passes.
 *
 *  @return Whether all objects in the array pass the test.
 */
- (BOOL)ct_all:(CollectorConditionBlock)testBlock;

/**
 *  Tests each array object and returns YES if at least one of the objects passes the test.
 *
 *  @param testBlock The test to perform for each object. Return YES when the object passes.
 *
 *  @return Whether or not at least one of the objects in the array passes the test.
 */
- (BOOL)ct_any:(CollectorConditionBlock)testBlock;

/**
 *  Tests each array object and returns YES only if no object passes the test.
 *
 *  @param testBlock The test to perform for each object. Return YES when the object passes.
 *
 *  @return Whether or not *none* all objects in the array fails the test.
 */
- (BOOL)ct_none:(CollectorConditionBlock)testBlock;

/**
 *  Counts objects that match a given test block.
 *
 *  @param testBlock The test to perform for each object. Return YES when the object passes.
 *
 *  @return The number of objects that pass the test.
 */
- (NSUInteger)ct_count:(CollectorConditionBlock)testBlock;

@end