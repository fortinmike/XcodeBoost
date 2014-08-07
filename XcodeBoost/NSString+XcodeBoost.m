//
//  NSString+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-19.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "Collector.h"
#import "NSString+Regexer.h"
#import "NSString+XcodeBoost.h"

@implementation NSString (XcodeBoost)

// Note for contributors:
//
// Using regexes to interpret code gets unwieldy pretty quickly...
// If you want to help get rid of those, investigate the clang-playground branch!
// In the meantime, I recommend something like Patterns.app to experiment with the unescaped patterns below.

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

// Unescaped: (?<![a-zA-Z0-9_])_[a-zA-Z0-9_]+
static NSString *s_fieldPattern = @"(?<![a-zA-Z0-9_])_[a-zA-Z0-9_]+";

// Unescaped: (?:\\.)[a-zA-Z0-9_]+
static NSString *s_propertyAccessPattern = @"(?:\\.)([a-zA-Z0-9_]+)";

// Unescaped: //.+?(?=\n)|/\*.+?\*/
static NSString *s_commentPattern = @"//.+?(?=\\n)|/\\*.+?\\*/";

#pragma mark Complex Patterns

// Unescaped: ([-\+] ?[a-zA-Z0-9 \(\)_,\*^:\n\s]+)\{(?:.*\n)+?(?:\n?)\}
static NSString *s_methodPattern = @"([-\\+] ?[a-zA-Z0-9 \\(\\)_\\*^:\\n\\s]+)\\{(?:.*\\n)+?(?:\\n?)\\}";

// Unescaped: ([a-zA-Z0-9\(\)_,\*^: ]+?[a-zA-Z0-9_]+?\(.*?\))[\s\n]*?\{(?:.*\n)+?(?:\n?)\}
static NSString *s_functionPattern = @"([a-zA-Z0-9\\(\\)_,\\*^: ]+?[a-zA-Z0-9_]+?\\(.*?\\))[\\s\\n]*?\\{(?:.*\\n)+?(?:\\n?)\\}";

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
	return [ranges ct_map:^id(NSValue *range)
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
	while (YES)
	{
		foundRange = [self rangeOfString:string options:0 range:searchRange];
		
		NSUInteger searchRangeStart = foundRange.location + foundRange.length;
		searchRange = NSMakeRange(searchRangeStart, length - searchRangeStart);
		
		if (foundRange.location != NSNotFound) [ranges addObject:[NSValue valueWithRange:foundRange]];
		else break;
	}
	
	return ranges;
}

- (NSArray *)xb_rangesOfSymbol:(MFSymbol *)symbol
{
	NSString *escapedSymbol = [[symbol matchText] xb_escapeForRegex];
	BOOL isGenericSymbol = [[symbol matchText] rx_matchesPattern:[NSString stringWithFormat:@"^%@$", s_genericSymbolPattern]];
	
	NSString *pattern;
	
	if (isGenericSymbol)
	{
		// Using negative look-behind and look-ahead so that we obtain the actual symbols
		// and not all occurences of the string in the text. Enough for helpful results.
		
		pattern = [NSString stringWithFormat:@"(?<!(%@))%@(?!(%@))",
				   s_symbolCharacterPattern, escapedSymbol, s_symbolCharacterPattern];
	}
	else
	{
		// In case of a complex symbol pattern, we don't use look-behind and look-ahead.
		pattern = escapedSymbol;
	}
	
	NSArray *rawSymbolRanges = [self rx_rangesForMatchesWithPattern:pattern];
	
	// Simple, brute-force approach to removing symbols detected in strings, comments, ...
	
	NSMutableArray *invalidRanges = [NSMutableArray array];
	[invalidRanges addObjectsFromArray:[self xb_stringRanges]];
	[invalidRanges addObjectsFromArray:[self xb_commentRanges]];
	
	NSMutableArray *symbolRanges = [NSMutableArray array];
	for (NSValue *rawSymbolRange in rawSymbolRanges)
	{
		BOOL symbolIsInAnInvalidRange = [invalidRanges ct_any:^BOOL(NSValue *stringRange)
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
	NSString *methodOrFunctionPattern = [NSString stringWithFormat:@"%@|%@", s_methodPattern, s_functionPattern];
	NSArray *matches = [self rx_matchesWithPattern:methodOrFunctionPattern];
	
	NSMutableArray *declarations = [NSMutableArray array];
	
	for (RXMatch *match in matches)
	{
		NSAssert([[match captures] count] == 3, @"The capture group count has changed; this extraction code should be revised!");
		
		RXCapture *methodSignature = match[1];
		
		if ([methodSignature found])
			[declarations addObject:[self xb_cleanupSubroutineDeclaration:[methodSignature text]]];
		
		RXCapture *functionSignature = match[2];
		
		if ([functionSignature found])
			[declarations addObject:[self xb_cleanupSubroutineDeclaration:[functionSignature text]]];
	}
	
	return [NSString xb_stringByConcatenatingStringsInArray:declarations delimiter:@"\n\n"];
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

- (NSArray *)xb_functionDefinitionRanges
{
	return [self rx_rangesForMatchesWithPattern:s_functionPattern];
}

- (NSArray *)xb_functionSignatureRanges
{
	return [self rx_rangesForGroup:1 withPattern:s_functionPattern];
}

#pragma mark Code Patterns - Other

- (NSArray *)xb_symbols
{
	NSMutableArray *symbols = [NSMutableArray array];
	
	[symbols addObjectsFromArray:[self xb_symbolsOfType:MFSymbolTypeStringLiteral withPattern:s_stringLiteralPattern]];
	[symbols addObjectsFromArray:[self xb_symbolsOfType:MFSymbolTypeNumberLiteral withPattern:s_numberLiteralPattern]];
	[symbols addObjectsFromArray:[self xb_symbolsOfType:MFSymbolTypeSelector withPattern:s_selectorPattern]];
	[symbols addObjectsFromArray:[self xb_symbolsOfType:MFSymbolTypeField withPattern:s_fieldPattern]];
	[symbols addObjectsFromArray:[self xb_symbolsOfType:MFSymbolTypePropertyAccess withPattern:s_propertyAccessPattern]];
	[symbols addObjectsFromArray:[self xb_symbolsOfType:MFSymbolTypeUnknown withPattern:s_genericSymbolPattern]];
	
	// Eliminate potential duplicates and return the distinct symbols
	return [symbols ct_distinct:^id(MFSymbol *symbol) { return [NSValue valueWithRange:[symbol range]]; }];
}

- (NSArray *)xb_symbolsOfType:(MFSymbolType)type withPattern:(NSString *)symbolPattern
{
	NSArray *matches = [self rx_matchesWithPattern:symbolPattern];
	
	NSMutableArray *symbols = [NSMutableArray array];
	for (RXMatch *match in matches)
	{
		MFSymbol *symbol = [[MFSymbol alloc] initWithType:type matchRange:[match range] matchText:[match text]];
		
		if ([[match captures] count] == 2)
		{
			// Set the range and text to the "relevant" part of the symbol match
			[symbol setRange:[match[1] range]];
			[symbol setText:[match[1] text]];
		}
		
		[symbols addObject:symbol];
	}
	
	return symbols;
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

- (NSString *)xb_cleanupSubroutineDeclaration:(NSString *)declaration
{
	NSString *trimmedDeclaration = [declaration stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return [trimmedDeclaration stringByAppendingString:@";"];
}

- (NSString *)xb_escapeForRegex
{
	NSString *escaped = [self stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
	escaped = [escaped stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
	return escaped;
	
}

@end