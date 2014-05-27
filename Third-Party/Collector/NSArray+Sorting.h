//
//  NSArray+Sorting.h
//  Collector
//
//  Created by Michaël Fortin on 2014-05-12.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectorBlockTypes.h"

@interface NSArray (Sorting)

/**
 *  Returns the array's elements in reverse order.
 *
 *  @return A new array containing the receiver's objects in reverse order.
 */
- (NSArray *)ct_reversed;

/**
 *  Returns the array's objects in random order.
 *
 *  @return A new array containing the same items as the receiver but in random order.
 */
- (NSArray *)ct_shuffled;

/**
 *  Returns the array items in ascending order based on the value returned by the block.
 *
 *  @param valueBlock Returns the value used to perform ordering (ex: person.firstName).
 *                    Supported types include NSString and NSNumber.
 *
 *  @return A new array with the same items as the receiver but sorted in ascending order based on the values returned from *valueBlock*.
 */
- (NSArray *)ct_orderedByAscending:(CollectorValueBlock)valueBlock;

/**
 *  Returns the array items in descending order based on the value returned by the block.
 *
 *  @param valueBlock Returns the value used to perform ordering (ex: person.firstName).
 *                    Supported types include NSString and NSNumber.
 *
 *  @return A new array with the same items as the receiver but sorted in descending order based on the values returned from *valueBlock*.
 */
- (NSArray *)ct_orderedByDescending:(CollectorValueBlock)valueBlock;

@end