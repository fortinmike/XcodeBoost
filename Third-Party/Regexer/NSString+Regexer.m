//
//  NSString+Regexer.m
//  Regexer
//
//  Created by Michaël Fortin on 2014-05-02.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSString+Regexer.h"
#import "RXRegexCache.h"

@implementation NSString (Regexer)

static RXRegexCache *_regexCache;

#pragma mark Lifetime

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
	{
		// Note: It's important that we use the shared cache so
		// that we can clear the cache for testing purposes.
		_regexCache = [RXRegexCache sharedCache];
	});
}

#pragma mark Obtaining Lazily-Compiled, Cached Regexes

- (NSRegularExpression *)rx_regex
{
	return [self rx_regexWithOptions:0];
}

- (NSRegularExpression *)rx_regexWithOptions:(NSRegularExpressionOptions)options
{
	return [_regexCache regexForPattern:self options:options];
}

#pragma mark Checking for Match

- (BOOL)rx_matchesPattern:(NSString *)regexPattern
{
	return [self rx_matchesPattern:regexPattern options:NSRegularExpressionCaseInsensitive];
}

- (BOOL)rx_matchesPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options;
{
	return [self rx_matchesRegex:[regexPattern rx_regexWithOptions:options]];
}

- (BOOL)rx_matchesRegex:(NSRegularExpression *)regex
{
	return ([regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])] > 0);
}

#pragma mark Extracting Strings with Capture Groups

- (NSString *)rx_capture:(NSInteger)group withPattern:(NSString *)regexPattern
{
	return [self rx_capture:group withPattern:regexPattern options:0];
}

- (NSString *)rx_capture:(NSInteger)group withPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options
{
	NSArray *matchedGroups = [self rx_capturesWithPattern:regexPattern];
	if (group >= [matchedGroups count]) return nil;
	return [matchedGroups objectAtIndex:group];
}

- (NSArray *)rx_capturesWithPattern:(NSString *)regexPattern
{
	return [self rx_capturesWithPattern:regexPattern options:0];
}

- (NSArray *)rx_capturesWithPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options
{
	NSRegularExpression *regex = [_regexCache regexForPattern:regexPattern options:options];
	
	NSArray *textCheckingResults = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
	
	NSMutableArray *strings = [NSMutableArray array];
	for (NSTextCheckingResult *result in textCheckingResults)
	{
		NSInteger numberOfRanges = [result numberOfRanges];
		
		if (numberOfRanges <= 1) return nil; // The first range is the whole string
		
		for (int rangeIndex = 1; rangeIndex < numberOfRanges; rangeIndex++)
		{
			NSRange range = [result rangeAtIndex:rangeIndex];
			if (range.location == NSNotFound) continue;
			
			NSString *group = [self substringWithRange:range];
			[strings addObject:group];
		}
	}
	
	return strings;
}

@end