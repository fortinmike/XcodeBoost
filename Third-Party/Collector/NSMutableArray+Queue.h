//
//  NSMutableArray+Queue.h
//  Collector
//
//  Created by Michaël Fortin on 2014-05-19.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)

/**
 *  Enqueue an object at the end of the array.
 *
 *  @param object The object to enqueue.
 */
- (void)ct_enqueue:(id)object;

/**
 *  Dequeue an object from the front of the array.
 *
 *  @return The first object in the array, or nil if the array is empty.
 */
- (id)ct_dequeue;

@end