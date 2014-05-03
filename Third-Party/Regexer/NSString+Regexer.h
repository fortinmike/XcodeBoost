//
//  NSString+Regexer.h
//  Regexer
//
//  Created by Michaël Fortin on 2014-05-02.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Regexer)

#pragma mark Obtaining Lazily-Compiled, Cached Regexes

- (NSRegularExpression *)rx_regex;
- (NSRegularExpression *)rx_regexWithOptions:(NSRegularExpressionOptions)options;

#pragma mark Checking for Match

- (BOOL)rx_matchesPattern:(NSString *)regexPattern;
- (BOOL)rx_matchesPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options;
- (BOOL)rx_matchesRegex:(NSRegularExpression *)regex;

#pragma mark Extracting Strings with Capture Groups

- (NSString *)rx_capture:(NSInteger)group withPattern:(NSString *)regexPattern;
- (NSString *)rx_capture:(NSInteger)group withPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options;
- (NSArray *)rx_capturesWithPattern:(NSString *)regexPattern;
- (NSArray *)rx_capturesWithPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options;

@end