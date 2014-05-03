//
//  NSString+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-19.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSString+XcodeBoost.h"
#import "NSArray+XcodeBoost.h"
#import "NSString+Regexer.h"

@implementation NSString (XcodeBoost)

#pragma mark Basic Patterns

// Unescaped: [a-zA-Z0-9_]
static NSString *s_symbolCharacterPattern = @"[a-zA-Z0-9_]";

// Unescaped: [a-zA-Z0-9_]+
static NSString *s_genericSymbolPattern = @"[a-zA-Z0-9_]+";

// Unescaped: @".+?"
static NSString *s_stringLiteralPattern = @"@\".+?\"";

// Unescaped: @\(.+?\)|@[0-9]+.?[0-9]+
static NSString *s_numberLiteralPattern = @"@\\(.+\\)|@[0-9]+?.??[0-9]+?";

// Unescaped: @selector\(.+?\)
static NSString *s_selectorPattern = @"@selector\\(.+?\\)";

// Unescaped: //.+?(?=\n)|/\*.+?\*/
static NSString *s_commentPattern = @"//.+?(?=\\n)|/\\*.+?\\*/";

#pragma mark Complex Patterns

// Unescaped: ((([-\+] ?\(.+?\).*)|[a-zA-Z0-9_]+? [a-zA-Z0-9_]+?\(.+?\))\n?)\{(.*\n)+?(\n?)\}
static NSString *s_subroutinePattern = @"((([-\\+] ?\\(.+?\\).*)|[a-zA-Z0-9_]+? [a-zA-Z0-9_]+?\\(.+?\\))\\n?)\\{(.*\\n)+?(\\n?)\\}";

// Unescaped: ([-\+] ?\(.+?\).*)(\n?)\{(.*\n)+?(\n?)\}
static NSString *s_methodPattern = @"([-\\+] ?\\(.+?\\).*)(\\n?)\\{(.*\\n)+?(\\n?)\\}";

// Unescaped: [a-zA-Z0-9_]+? [a-zA-Z0-9_]+?\(.+?\)\n?\{(.*\n)+?(\n?)\}
static NSString *s_functionPattern = @"[a-zA-Z0-9_]+? [a-zA-Z0-9_]+?\\(.+?\\)\\n?\\{(.*\\n)+?(\\n?)\\}";

#pragma mark Dynamic Patterns (Created From Other Patterns)

static NSString *s_symbolPattern;

#pragma mark Lifetime

+ (void)load
{
	// Generate dynamic symbols
	s_symbolPattern = [NSString stringWithFormat:@"%@|%@|%@|%@",
					   s_genericSymbolPattern, s_stringLiteralPattern,
					   s_numberLiteralPattern, s_selectorPattern];
}

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
	return [self xb_rangesForCaptures:matches];
}

#pragma mark Code Patterns - Subroutines

- (BOOL)xb_startsWithSubroutineDefinition
{
	@throw [NSException exceptionWithName:@"TODO" reason:@"TODO" userInfo:nil];
}

- (NSString *)xb_extractSubroutineDeclarations
{
	@throw [NSException exceptionWithName:@"TODO" reason:@"TODO" userInfo:nil];
}

- (NSArray *)xb_subroutineDefinitionRanges
{
	@throw [NSException exceptionWithName:@"TODO" reason:@"TODO" userInfo:nil];
}

- (NSArray *)xb_subroutineSignatureRanges
{
	@throw [NSException exceptionWithName:@"TODO" reason:@"TODO" userInfo:nil];
}

#pragma mark Code Patterns - Methods

- (BOOL)xb_startsWithMethodDefinition
{
	NSRegularExpression *startsWithDefinitionPattern = [[@"^" stringByAppendingString:s_methodPattern] rx_regex];
	NSUInteger numberOfMatches = [startsWithDefinitionPattern numberOfMatchesInString:self options:0 range:[self xb_range]];
	return numberOfMatches == 1;
}

- (NSString *)xb_extractMethodDeclarations
{
	NSRegularExpression *methodRegex = [s_methodPattern rx_regex];
	NSString *declarations = [methodRegex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@"$1;"];
	NSString *trimmedDeclarations = [declarations stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return trimmedDeclarations;
}

- (NSArray *)xb_methodDefinitionRanges
{
	return [self xb_rangesForCaptures:[self rx_capturesWithPattern:s_methodPattern]];
}

- (NSArray *)xb_methodSignatureRanges
{
	return [self xb_rangesForCaptures:[self rx_capturesWithPattern:s_methodPattern] group:1];
}

#pragma mark Code Patterns - Functions

- (BOOL)xb_startsWithFunctionDefinition
{
	@throw [NSException exceptionWithName:@"TODO" reason:@"TODO" userInfo:nil];
}

- (NSString *)xb_extractFunctionDeclarations
{
	@throw [NSException exceptionWithName:@"TODO" reason:@"TODO" userInfo:nil];
}

- (NSArray *)xb_functionDefinitionRanges
{
	@throw [NSException exceptionWithName:@"TODO" reason:@"TODO" userInfo:nil];
}

- (NSArray *)xb_functionSignatureRanges
{
	@throw [NSException exceptionWithName:@"TODO" reason:@"TODO" userInfo:nil];
}

#pragma mark Code Patterns - Other

- (NSArray *)xb_symbolRanges
{
	NSArray *matches = [self rx_capturesWithPattern:s_symbolPattern];
	return [self xb_rangesForCaptures:matches];
}

- (NSArray *)xb_commentRanges
{
	NSArray *matches = [self rx_capturesWithPattern:s_commentPattern];
	return [self xb_rangesForCaptures:matches];
}

#pragma mark Private Methods

- (NSArray *)xb_rangesForCaptures:(NSArray *)captures
{
	return [self xb_rangesForCaptures:captures group:-1];
}

- (NSArray *)xb_rangesForCaptures:(NSArray *)captures group:(NSUInteger)captureGroup
{
	NSMutableArray *ranges = [NSMutableArray array];
	for (NSTextCheckingResult *match in captures)
	{
		NSRange matchRange = (captureGroup == -1) ? [match range] : [match rangeAtIndex:captureGroup];
		[ranges addObject:[NSValue valueWithRange:matchRange]];
	}
	return ranges;
}

@end