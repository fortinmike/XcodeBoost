//
//  RXMatch.h
//  Regexer
//
//  Created by Michaël Fortin on 2014-05-03.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RXMatch : NSObject

@property (readonly) NSArray *captures;
@property (readonly) NSString *text;
@property (readonly) NSRange range;

#pragma mark Lifetime

- (id)initWithCaptures:(NSArray *)captures;

@end