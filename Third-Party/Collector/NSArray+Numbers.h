//
//  NSArray+Numbers.h
//  Collector
//
//  Created by Michaël Fortin on 2014-05-11.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectorBlockTypes.h"

@interface NSArray (Numbers)

#pragma mark Manipulating Arrays of NSNumber Instances

/**
 *  Assuming that the array contains only NSNumber instances, returns the NSNumber
 *  instance with the lowest value.
 *
 *  @return The lowest NSNumber in the array.
 */
- (NSNumber *)ct_min;

/**
 *  Making no assumption about array contents, this method provides a block from which an
 *  NSNumber must be returned. The object that is returned from this method is the object for
 *  which *numberBlock* returns the lowest value.
 *
 *  @return the object where *numberBlock* returns the lowest value.
 */
- (NSNumber *)ct_min:(CollectorNumberBlock)numberBlock;

/**
 *  Assuming that the array contains only NSNumber instances, returns the NSNumber
 *  instance with the highest value.
 *
 *  @return The highest NSNumber in the array.
 */
- (NSNumber *)ct_max;

/**
 *  Making no assumption about array contents, this method provides a block from which an
 *  NSNumber must be returned. The object that is returned from this method is the object for
 *  which *numberBlock* returns the highest value.
 *
 *  @return The object where *numberBlock* returns the highest value.
 */
- (NSNumber *)ct_max:(CollectorNumberBlock)numberBlock;

/**
 *  Assuming the array contains only NSNumber instances, returns a new NSNumber whose value
 *  is the sum of all NSNumber instances in the array.
 *
 *  @return The sum of all NSNumber instances in the array.
 */
- (NSNumber *)ct_sum;

/**
 *  Making no assumption about array contents, this method provides a block from which an
 *  NSNumber must be returned. This method returns the sum of all values returned from *numberBlock*.
 *
 *  @return The sum of all values returned by *numberBlock*.
 */
- (NSNumber *)ct_sum:(CollectorNumberBlock)numberBlock;

/**
 *  Assuming the array contains only NSNumber instances, returns a new NSNumber whose value
 *  is the arithmetic mean of all NSNumber instances in the array.
 *
 *  @return The arithmetic mean (a.k.a. "mean" or "average") of all NSNumber instances in the array.
 */
- (NSNumber *)ct_average;

/**
 *  Making no assumption about array contains, this method provides a block from which an NSnumber must
 *  be returned. This method returns the arithmetic mean of all values returned from *numberBlock*.
 *
 *  @return The arithmetic mean (a.k.a. "mean" or "average") of all NSNumber instances returned by *numberBlock*.
 */
- (NSNumber *)ct_average:(CollectorNumberBlock)numberBlock;

@end