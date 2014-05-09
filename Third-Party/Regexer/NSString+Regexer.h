//
//  NSString+Regexer.h
//  Regexer
//
//  Created by Michaël Fortin on 2014-05-02.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RXMatch.h"
#import "RXCapture.h"

@interface NSString (Regexer)

#pragma mark Obtaining Lazily-Compiled, Cached Regexes

- (NSRegularExpression *)rx_regex;
- (NSRegularExpression *)rx_regexWithOptions:(NSRegularExpressionOptions)options;

#pragma mark Checking For Matches

- (BOOL)rx_matchesPattern:(NSString *)regexPattern;
- (BOOL)rx_matchesPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options;
- (BOOL)rx_matchesRegex:(NSRegularExpression *)regex;

#pragma mark Matches

- (NSUInteger)rx_numberOfMatchesWithPattern:(NSString *)regexPattern;
- (NSUInteger)rx_numberOfMatchesWithPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options;
- (NSArray *)rx_textsForMatchesWithPattern:(NSString *)regexPattern;
- (NSArray *)rx_textsForMatchesWithPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options;
- (NSArray *)rx_rangesForMatchesWithPattern:(NSString *)regexPattern;
- (NSArray *)rx_rangesForMatchesWithPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options;
- (NSArray *)rx_matchesWithPattern:(NSString *)regexPattern;
- (NSArray *)rx_matchesWithPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options;

#pragma mark Capturing Groups

- (NSArray *)rx_textsForGroup:(NSInteger)group withPattern:(NSString *)regexPattern;
- (NSArray *)rx_textsForGroup:(NSInteger)group withPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options;
- (NSArray *)rx_rangesForGroup:(NSInteger)group withPattern:(NSString *)regexPattern;
- (NSArray *)rx_rangesForGroup:(NSInteger)group withPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options;
- (NSArray *)rx_capturesForGroup:(NSInteger)group withPattern:(NSString *)regexPattern;
- (NSArray *)rx_capturesForGroup:(NSInteger)group withPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options;

#pragma mark Replacement

- (NSString *)rx_stringByReplacingMatchesOfPattern:(NSString *)regexPattern withTemplate:(NSString *)templateString;
- (NSString *)rx_stringByReplacingMatchesOfPattern:(NSString *)regexPattern withTemplate:(NSString *)templateString options:(NSMatchingOptions)options;

@end