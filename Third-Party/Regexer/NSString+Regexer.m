//
//  NSString+Regexer.m
//  Regexer
//
//  Created by Michaël Fortin on 2014-05-02.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSString+Regexer.h"
#import "RXRegexCache.h"
#import "NSArray+Regexer.h"

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

#pragma mark Checking For Matches

- (BOOL)rx_matchesPattern:(NSString *)regexPattern
{
	return [self rx_matchesPattern:regexPattern options:0];
}

- (BOOL)rx_matchesPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options;
{
	return [self rx_matchesRegex:[regexPattern rx_regexWithOptions:options]];
}

- (BOOL)rx_matchesRegex:(NSRegularExpression *)regex
{
	return ([regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])] > 0);
}

#pragma mark Matches

- (NSUInteger)rx_numberOfMatchesWithPattern:(NSString *)regexPattern
{
	return [self rx_numberOfMatchesWithPattern:regexPattern options:0];
}

- (NSUInteger)rx_numberOfMatchesWithPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options
{
	NSRegularExpression *regex = [regexPattern rx_regexWithOptions:options];
	return [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];
}

- (NSArray *)rx_textsForMatchesWithPattern:(NSString *)regexPattern
{
	return [self rx_textsForMatchesWithPattern:regexPattern options:0];
}

- (NSArray *)rx_textsForMatchesWithPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options
{
	return [self rx_textsForGroup:0 withPattern:regexPattern options:options];
}

- (NSArray *)rx_rangesForMatchesWithPattern:(NSString *)regexPattern
{
	return [self rx_rangesForMatchesWithPattern:regexPattern options:0];
}

- (NSArray *)rx_rangesForMatchesWithPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options
{
	return [self rx_rangesForGroup:0 withPattern:regexPattern options:options];
}

- (NSArray *)rx_matchesWithPattern:(NSString *)regexPattern
{
	return [self rx_matchesWithPattern:regexPattern options:0];
}

- (NSArray *)rx_matchesWithPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options
{
	NSRegularExpression *regex = [_regexCache regexForPattern:regexPattern options:options];
	
	NSArray *results = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
	
	NSMutableArray *matches = [NSMutableArray array];
	for (NSTextCheckingResult *textCheckingResult in results)
	{
		NSInteger numberOfRanges = [textCheckingResult numberOfRanges];
		
		NSMutableArray *captures = [NSMutableArray array];
		for (int rangeIndex = 0; rangeIndex < numberOfRanges; rangeIndex++)
		{
			NSRange range = [textCheckingResult rangeAtIndex:rangeIndex];
			if (range.location == NSNotFound)
			{
				[captures addObject:[RXCapture notFoundCapture]];
				continue;
			}
			
			NSString *text = [self substringWithRange:range];
			RXCapture *capture = [[RXCapture alloc] initWithRange:range text:text];
			
			[captures addObject:capture];
		}
		
		[matches addObject:[[RXMatch alloc] initWithCaptures:[captures copy]]];
	}
	
	return matches;
}

#pragma mark Capturing Groups

- (NSArray *)rx_textsForGroup:(NSInteger)group withPattern:(NSString *)regexPattern
{
	return [self rx_textsForGroup:group withPattern:regexPattern options:0];
}

- (NSArray *)rx_textsForGroup:(NSInteger)group withPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options
{
	NSArray *captures = [self rx_capturesForGroup:group withPattern:regexPattern options:options];
	return [captures rx_map:^id(RXCapture *capture) { return [capture text]; }];
}

- (NSArray *)rx_rangesForGroup:(NSInteger)group withPattern:(NSString *)regexPattern
{
	return [self rx_rangesForGroup:group withPattern:regexPattern options:0];
}

- (NSArray *)rx_rangesForGroup:(NSInteger)group withPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options
{
	NSArray *captures = [self rx_capturesForGroup:group withPattern:regexPattern options:options];
	return [captures rx_map:^id(RXCapture *capture) { return [NSValue valueWithRange:[capture range]]; }];
}

- (NSArray *)rx_capturesForGroup:(NSInteger)group withPattern:(NSString *)regexPattern
{
	return [self rx_capturesForGroup:group withPattern:regexPattern options:0];
}

- (NSArray *)rx_capturesForGroup:(NSInteger)group withPattern:(NSString *)regexPattern options:(NSRegularExpressionOptions)options
{
	NSArray *matches = [self rx_matchesWithPattern:regexPattern];
	
	[self validateGroup:group inMatches:matches];
	
	NSMutableArray *captures = [NSMutableArray array];
	
	for (RXMatch *match in matches)
		[captures addObject:[[match captures] objectAtIndex:group]];
	
	return captures;
}

#pragma mark Replacement

- (NSString *)rx_stringByReplacingMatchesOfPattern:(NSString *)regexPattern withTemplate:(NSString *)templateString
{
	return [self rx_stringByReplacingMatchesOfPattern:regexPattern withTemplate:templateString options:0];
}

- (NSString *)rx_stringByReplacingMatchesOfPattern:(NSString *)regexPattern withTemplate:(NSString *)templateString options:(NSMatchingOptions)options
{
	return [[regexPattern rx_regex] stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:templateString];
}

#pragma mark Private Helpers

- (void)validateGroup:(NSUInteger)group inMatches:(NSArray *)matches
{
	// Make sure the numbered group exists. Since there is always the same
	// number of captures in each match, we only check the first match.
	RXMatch *firstMatch = [matches firstObject];
	if (firstMatch)
	{
		if (group >= [[firstMatch captures] count])
		{
			@throw [NSException exceptionWithName:@"Invalid Parameter"
										   reason:@"The given group exceeds the number of capture groups in the regex pattern" userInfo:nil];
		}
	}
}

@end