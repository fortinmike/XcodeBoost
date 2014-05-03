//
//  RXRegexCache.h
//  Regexer
//
//  Created by Michaël Fortin on 2014-05-02.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RXRegexCache : NSObject

#pragma mark Lifetime

+ (instancetype)sharedCache;

#pragma mark Public Methods

- (NSRegularExpression *)regexForPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (void)clear;

@end