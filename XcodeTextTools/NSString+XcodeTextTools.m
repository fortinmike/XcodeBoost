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

- (NSArray *)xctt_rangesOfRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options
{
	NSError *error;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&error];
	NSArray *matches = [regex matchesInString:self options:0 range:[self xctt_range]];
	return [self xctt_rangesForMatches:matches];
}

- (NSRange)xctt_range
{
	return NSMakeRange(0, [self length]);
}

#pragma mark Code Patterns

- (BOOL)xctt_startsWithMethodDefinition
{
	[self xctt_prepareRegexes];
	NSUInteger numberOfMatches = [s_singleMethodDefinitionRegex numberOfMatchesInString:self options:0 range:[self xctt_range]];
	return numberOfMatches == 1;
}

- (NSString *)xctt_extractMethodDeclarations
{
	[self xctt_prepareRegexes];
	NSString *declarations = [s_methodDefinitionsRegex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length])
																					 withTemplate:@"$1;"];
	NSString *trimmedDeclarations = [declarations stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return trimmedDeclarations;
}

- (NSArray *)xctt_methodDefinitionRanges
{
	[self xctt_prepareRegexes];
	NSArray *matches = [s_methodDefinitionsRegex matchesInString:self options:0 range:[self xctt_range]];
	return [self xctt_rangesForMatches:matches];
}

- (NSArray *)xctt_methodSignatureRanges
{
	[self xctt_prepareRegexes];
	NSArray *matches = [s_methodDefinitionsRegex matchesInString:self options:0 range:[self xctt_range]];
	return [self xctt_rangesForMatches:matches captureGroup:1];
}

#pragma mark Private Methods

- (void)xctt_prepareRegexes
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

- (NSArray *)xctt_rangesForMatches:(NSArray *)matches
{
	return [self xctt_rangesForMatches:matches captureGroup:-1];
}

- (NSArray *)xctt_rangesForMatches:(NSArray *)matches captureGroup:(NSUInteger)captureGroup
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