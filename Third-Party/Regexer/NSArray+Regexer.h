//
//  NSArray+Regexer.h
//  Regexer
//
//  Created by Michaël Fortin on 2014-05-04.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^ObjectObjectBlock)(id object);

@interface NSArray (Regexer)

- (instancetype)rx_map:(ObjectObjectBlock)gatheringBlock;

@end