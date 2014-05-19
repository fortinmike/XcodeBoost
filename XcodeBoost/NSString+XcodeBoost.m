//
//  NSString+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-19.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSString+Regexer.h"
#import "NSString+XcodeBoost.h"
#import "NSArray+XcodeBoost.h"

@implementation NSString (XcodeBoost)

// Note for contributors:
//
// Using regexes to interpret code gets unwieldy pretty quickly...
// If you want to help get rid of those, investigate the clang-playground branch!
// In the meantime, I recommend something like Patterns.app to experiment with the unescape patterns below.

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

// Unescaped: ([-\+] ?[a-zA-Z0-9 \(\)_\*^:\n\s]+)\{(.*\n)+?(\n?)\}
static NSString *s_methodPattern = @"([-\\+] ?[a-zA-Z0-9 \\(\\)_\\*^:\\n\\s]+)\\{(.*\\n)+?(\\n?)\\}";

// Unescaped: ([a-zA-Z0-9_]+? [a-zA-Z0-9_]+?\(.+?\))\n?\{(.*\n)+?(\n?)\}
static NSString *s_functionPattern = @"([a-zA-Z0-9_]+? [a-zA-Z0-9_]+?\\(.+?\\))\\n?\\{(.*\\n)+?(\\n?)\\}";

#pragma mark Creating Instances

+ (NSString *)xb_stringByConcatenatingStringsInArray:(NSArray *)stringsArray delimiter:(NSString *)delimiter
{
	NSMutableString *concatenated = [[NSMutableString alloc] init];
	
	[stringsArray enumerateObjectsUsingBlock:^(NSString *string, NSUInteger index, BOOL *stop)
	{
		[concatenated appendString:string];
		
		if (index != [stringsArray count] - 1)
			[concatenated appendString:delimiter];
	}];
	
	return concatenated;
}

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
	// Using negative look-behind and look-ahead so that we obtain the actual symbols
	// and not all occurences of the string in the text. Enough for helpful results.
	
	NSString *symbolPattern = [NSString stringWithFormat:@"(?<!(%@))%@(?!(%@))", s_symbolCharacterPattern, symbol, s_symbolCharacterPattern];
	NSArray *rawSymbolRanges = [self rx_rangesForMatchesWithPattern:symbolPattern];
	
	// Simple, brute-force approach to removing symbols detected in strings, comments, ...
	
	NSMutableArray *invalidRanges = [NSMutableArray array];
	[invalidRanges addObjectsFromArray:[self xb_stringRanges]];
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

#pragma mark Code Patterns - Subroutines

- (BOOL)xb_startsWithSubroutineDefinition
{
	return [self xb_startsWithMethodDefinition] || [self xb_startsWithFunctionDefinition];
}

- (NSString *)xb_extractSubroutineDeclarations
{
	return [[self xb_extractMethodDeclarations] xb_extractFunctionDeclarations];
}

- (NSArray *)xb_subroutineDefinitionRanges
{
	return [[self xb_methodDefinitionRanges] arrayByAddingObjectsFromArray:[self xb_functionDefinitionRanges]];
}

- (NSArray *)xb_subroutineSignatureRanges
{
	return [[self xb_methodSignatureRanges] arrayByAddingObjectsFromArray:[self xb_functionSignatureRanges]];
}

#pragma mark Code Patterns - Methods

- (BOOL)xb_startsWithMethodDefinition
{
	return [self rx_matchesPattern:[@"^" stringByAppendingString:s_methodPattern]];
}

- (NSString *)xb_extractMethodDeclarations
{
	return [self xb_extractDeclarationsWithPattern:s_methodPattern];
}

- (NSArray *)xb_methodDefinitionRanges
{
	return [self rx_rangesForMatchesWithPattern:s_methodPattern];
}

- (NSArray *)xb_methodSignatureRanges
{
	return [self rx_rangesForGroup:1 withPattern:s_methodPattern];
}

#pragma mark Code Patterns - Functions

- (BOOL)xb_startsWithFunctionDefinition
{
	return [self rx_matchesPattern:[@"^" stringByAppendingString:s_functionPattern]];
}

- (NSString *)xb_extractFunctionDeclarations
{
	return [self xb_extractDeclarationsWithPattern:s_functionPattern];
}

- (NSArray *)xb_functionDefinitionRanges
{
	return [self rx_rangesForMatchesWithPattern:s_functionPattern];
}

- (NSArray *)xb_functionSignatureRanges
{
	return [self rx_rangesForGroup:1 withPattern:s_functionPattern];
}

#pragma mark Code Patterns - Other

- (NSArray *)xb_symbolRanges
{
	NSString *symbolPattern = [NSString stringWithFormat:@"%@|%@|%@|%@", s_genericSymbolPattern, s_stringLiteralPattern,
																		 s_numberLiteralPattern, s_selectorPattern];
	return [self rx_rangesForMatchesWithPattern:symbolPattern];
}

- (NSArray *)xb_commentRanges
{
	return [self rx_rangesForMatchesWithPattern:s_commentPattern];
}

- (NSArray *)xb_stringRanges
{
	return [self rx_rangesForMatchesWithPattern:s_stringLiteralPattern];
}

#pragma mark Helpers

- (NSString *)xb_extractDeclarationsWithPattern:(NSString *)pattern
{
	NSArray *declarations = [self rx_textsForGroup:1 withPattern:pattern];
	NSArray *trimmedDeclarations = [declarations xb_map:^id(NSString *declaration)
	{
		NSString *trimmedDeclaration = [declaration stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		return [trimmedDeclaration stringByAppendingString:@";"];
	}];
	
	return [NSString xb_stringByConcatenatingStringsInArray:trimmedDeclarations delimiter:@"\n\n"];
}

@end