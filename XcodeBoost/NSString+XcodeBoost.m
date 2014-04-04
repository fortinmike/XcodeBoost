//
//  NSString+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-19.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSString+XcodeBoost.h"
#import "NSAlert+XcodeBoost.h"
#import "NSArray+XcodeBoost.h"

@implementation NSString (XcodeBoost)

static BOOL s_regexesPrepared;

static NSString *s_symbolCharacterPattern = @"[a-zA-Z0-9_]";
static NSString *s_stringLiteralPattern = @"@\".+?\""; // Unescaped: @".+?"
static NSString *s_numberLiteralPattern = @"@\\(.+\\)|@[0-9]+?.??[0-9]+?"; // Unescaped: @\(.+?\)|@[0-9]+.?[0-9]+
static NSString *s_selectorPattern = @"@selector\\(.+?\\)"; // Unescaped: @selector\(.+?\)
static NSString *s_methodDefinitionsPattern = @"([-\\+] ?\\(.+?\\).*)(\\n?)\\{(.*\\n)+?(\\n?)\\}"; // Unescaped: ([-\+] ?\(.+?\).*)(\n?)\{(.*\n)+?(\n?)\}
static NSString *s_commentPattern = @"//.+?(?=\\n)|/\\*.+?\\*/"; // Unescaped: //.+?(?=\n)|/\*.+?\*/

// Primitives
static NSRegularExpression *s_genericSymbolRegex;
static NSRegularExpression *s_stringLiteralRegex;
static NSRegularExpression *s_numberLiteralRegex;
static NSRegularExpression *s_selectorRegex;
static NSRegularExpression *s_methodDefinitionRegex;
static NSRegularExpression *s_commentRegex;

// Composite
static NSRegularExpression *s_symbolRegex;

// Special Cases
static NSRegularExpression *s_singleMethodDefinitionRegex;

#pragma mark Creating Instances

- (NSAttributedString *)xb_attributedString
{
	return [[NSAttributedString alloc] initWithString:self];
}

- (NSString *)xb_concatenatedStringForRanges:(NSArray *)ranges
{
	NSMutableString *concatenated = [[NSMutableString alloc] init];
	
	for (NSValue *range in ranges)
		[concatenated appendString:[self substringWithRange:[range rangeValue]]];
	
	return concatenated;
}

#pragma mark Checks

- (BOOL)xb_containsOnlyWhitespace
{
	return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""];
}

#pragma mark Ranges

- (NSRange)xb_range
{
	return NSMakeRange(0, [self length]);
}

- (NSArray *)xb_lineRangesForRanges:(NSArray *)ranges
{
	return [ranges xb_map:^id(NSValue *range)
	{
		NSRange lineRange = [self lineRangeForRange:[range rangeValue]];
		return [NSValue valueWithRange:lineRange];
	}];
}

- (NSArray *)xb_rangesOfString:(NSString *)string
{
	NSUInteger length = [self length];
	
	NSRange searchRange = NSMakeRange(0, length);
	NSRange foundRange = NSMakeRange(0, 0);

	NSMutableArray *ranges = [NSMutableArray array];
	while(YES)
	{
		foundRange = [self rangeOfString:string options:0 range:searchRange];
		
		NSUInteger searchRangeStart = foundRange.location + foundRange.length;
		searchRange = NSMakeRange(searchRangeStart, length - searchRangeStart);
		
		if (foundRange.location != NSNotFound) [ranges addObject:[NSValue valueWithRange:foundRange]];
		else break;
	}
	
	return ranges;
}

- (NSArray *)xb_rangesOfSymbol:(NSString *)symbol
{
	// Using negative look-behind and look-ahead so that we obtain
	// the actual symbols and not all occurences of the string in
	// the text. Enough for helpful results.
	
	[self xb_prepareRegexes];
	NSString *symbolPattern = [NSString stringWithFormat:@"(?<!(%@))%@(?!(%@))", s_symbolCharacterPattern, symbol, s_symbolCharacterPattern];
	NSArray *rawSymbolRanges = [self xb_rangesOfRegex:symbolPattern options:0];
	
	// Simple, brute-force approach to removing symbols detected in strings, comments, ...
	
	NSMutableArray *invalidRanges = [[self xb_rangesOfRegex:@"@\".+?\"" options:0] mutableCopy];
	[invalidRanges addObjectsFromArray:[self xb_commentRanges]];
	
	NSMutableArray *symbolRanges = [NSMutableArray array];
	for (NSValue *rawSymbolRange in rawSymbolRanges)
	{
		BOOL symbolIsInAnInvalidRange = [invalidRanges xb_any:^BOOL(NSValue *stringRange)
		{
			return NSIntersectionRange([stringRange rangeValue], [rawSymbolRange rangeValue]).length > 0;
		}];
		
		if (!symbolIsInAnInvalidRange)
			[symbolRanges addObject:rawSymbolRange];
	}
	
	return symbolRanges;
}

- (NSArray *)xb_rangesOfRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options
{
	NSError *error;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&error];
	NSArray *matches = [regex matchesInString:self options:0 range:[self xb_range]];
	return [self xb_rangesForMatches:matches];
}

#pragma mark Code Patterns

- (BOOL)xb_startsWithMethodDefinition
{
	[self xb_prepareRegexes];
	NSUInteger numberOfMatches = [s_singleMethodDefinitionRegex numberOfMatchesInString:self options:0 range:[self xb_range]];
	return numberOfMatches == 1;
}

- (NSString *)xb_extractMethodDeclarations
{
	[self xb_prepareRegexes];
	NSString *declarations = [s_methodDefinitionRegex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@"$1;"];
	NSString *trimmedDeclarations = [declarations stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return trimmedDeclarations;
}

- (NSArray *)xb_methodDefinitionRanges
{
	[self xb_prepareRegexes];
	NSArray *matches = [s_methodDefinitionRegex matchesInString:self options:0 range:[self xb_range]];
	return [self xb_rangesForMatches:matches];
}

- (NSArray *)xb_methodSignatureRanges
{
	[self xb_prepareRegexes];
	NSArray *matches = [s_methodDefinitionRegex matchesInString:self options:0 range:[self xb_range]];
	return [self xb_rangesForMatches:matches captureGroup:1];
}

- (NSArray *)xb_symbolRanges
{
	[self xb_prepareRegexes];
	NSArray *matches = [s_symbolRegex matchesInString:self options:0 range:[self xb_range]];
	return [self xb_rangesForMatches:matches];
}

- (NSArray *)xb_commentRanges
{
	[self xb_prepareRegexes];
	NSArray *matches = [s_commentRegex matchesInString:self options:0 range:[self xb_range]];
	return [self xb_rangesForMatches:matches];
}

#pragma mark Private Methods

- (void)xb_prepareRegexes
{
	if (!s_regexesPrepared)
	{
		NSString *genericSymbolPattern = [NSString stringWithFormat:@"%@+", s_symbolCharacterPattern];
		s_genericSymbolRegex = [NSRegularExpression regularExpressionWithPattern:genericSymbolPattern options:0 error:nil];
		
		s_stringLiteralRegex = [NSRegularExpression regularExpressionWithPattern:s_stringLiteralPattern options:0 error:nil];
		
		s_numberLiteralRegex = [NSRegularExpression regularExpressionWithPattern:s_numberLiteralPattern options:0 error:nil];
		
		s_selectorRegex = [NSRegularExpression regularExpressionWithPattern:s_selectorPattern options:0 error:nil];
		
		s_methodDefinitionRegex = [NSRegularExpression regularExpressionWithPattern:s_methodDefinitionsPattern options:0 error:nil];
		
		s_commentRegex = [NSRegularExpression regularExpressionWithPattern:s_commentPattern options:0 error:nil];
		
		NSString *symbolPattern = [NSString stringWithFormat:@"%@|%@|%@|%@",
								   genericSymbolPattern, s_stringLiteralPattern,
								   s_numberLiteralPattern, s_selectorPattern];
		s_symbolRegex = [NSRegularExpression regularExpressionWithPattern:symbolPattern options:0 error:nil];
		
		
		NSString *startsWithMethodDefinitionPattern = [@"^" stringByAppendingString:s_methodDefinitionsPattern];
		s_singleMethodDefinitionRegex = [NSRegularExpression regularExpressionWithPattern:startsWithMethodDefinitionPattern options:0 error:nil];
		
		s_regexesPrepared = YES;
	}
}

- (NSArray *)xb_rangesForMatches:(NSArray *)matches
{
	return [self xb_rangesForMatches:matches captureGroup:-1];
}

- (NSArray *)xb_rangesForMatches:(NSArray *)matches captureGroup:(NSUInteger)captureGroup
{
	NSMutableArray *ranges = [NSMutableArray array];
	for (NSTextCheckingResult *match in matches)
	{
		NSRange matchRange = (captureGroup == -1) ? [match range] : [match rangeAtIndex:captureGroup];
		[ranges addObject:[NSValue valueWithRange:matchRange]];
	}
	return ranges;
}

@end