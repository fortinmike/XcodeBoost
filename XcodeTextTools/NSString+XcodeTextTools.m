//
//  NSString+XcodeTextTools.m
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-19.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSString+XcodeTextTools.h"
#import "NSAlert+XcodeTextTools.h"

@implementation NSString (XcodeTextTools)

static BOOL s_regexesPrepared;
static NSRegularExpression *s_singleMethodDefinitionRegex;
static NSRegularExpression *s_methodDefinitionsRegex;

#pragma mark Creating Instances

- (NSAttributedString *)xctt_attributedString
{
	return [[NSAttributedString alloc] initWithString:self];
}

#pragma mark Ranges

- (NSArray *)xctt_rangesOfString:(NSString *)string
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

- (NSRange)xctt_range
{
	return NSMakeRange(0, [self length]);
}

#pragma mark Code Patterns

- (BOOL)xctt_startsWithMethodDefinition
{
	[self prepareRegexes];
	NSUInteger numberOfMatches = [s_singleMethodDefinitionRegex numberOfMatchesInString:self options:0 range:[self xctt_range]];
	return numberOfMatches == 1;
}

- (NSString *)xctt_extractMethodDeclarations
{
	[self prepareRegexes];
	
	NSString *declarations = [s_methodDefinitionsRegex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length])
																					 withTemplate:@"$1;"];
	NSString *trimmedDeclarations = [declarations stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	return trimmedDeclarations;
}

- (NSArray *)xctt_methodDefinitionRanges
{
	[self prepareRegexes];
	
	NSArray *matches = [s_methodDefinitionsRegex matchesInString:self options:0 range:[self xctt_range]];
	
	return [self rangesForMatches:matches];
}

#pragma mark Private Methods

- (void)prepareRegexes
{
	if (!s_regexesPrepared)
	{
		NSString *methodDefinitionsPattern = @"([-\\+] ?\\(.+?\\).*)(\\n?)\\{(.*\\n)+?(\\n?)\\}";
		s_methodDefinitionsRegex = [NSRegularExpression regularExpressionWithPattern:methodDefinitionsPattern options:0 error:nil];
		
		NSString *startsWithMethodDefinitionPattern = [@"^" stringByAppendingString:methodDefinitionsPattern];
		s_singleMethodDefinitionRegex = [NSRegularExpression regularExpressionWithPattern:startsWithMethodDefinitionPattern options:0 error:nil];
		
		s_regexesPrepared = YES;
	}
}

- (NSArray *)rangesForMatches:(NSArray *)matches
{
	NSMutableArray *ranges = [NSMutableArray array];
	for (NSTextCheckingResult *match in matches)
	{
		NSRange matchRange = [match range];
		[ranges addObject:[NSValue valueWithRange:matchRange]];
	}
	return ranges;
}

@end