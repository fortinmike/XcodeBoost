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
static NSRegularExpression *s_methodDefinitionRegex;
static NSRegularExpression *s_methodDeclarationExtractionRegex;

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
	NSUInteger numberOfMatches = [s_methodDefinitionRegex numberOfMatchesInString:self options:0 range:[self xctt_range]];
	return numberOfMatches == 1;
}

- (NSString *)xctt_extractMethodDeclarations
{
	[self prepareRegexes];
	
	return [s_methodDeclarationExtractionRegex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length])
																   withTemplate:@"$1;"];
}

#pragma mark Private Methods

- (void)prepareRegexes
{
	if (!s_regexesPrepared)
	{
		s_methodDefinitionRegex = [NSRegularExpression regularExpressionWithPattern:@"^[-\\+] ?\\(.+?\\).*(\\n?)\\{(.*\\n)+?(\\n?)\\}"
																			options:0 error:nil];
		
		s_methodDeclarationExtractionRegex = [NSRegularExpression regularExpressionWithPattern:@"([-\\+] ?\\(.+?\\).*)(\\n?)\\{(.*\\n)+?(\\n?)\\}"
																					   options:0 error:nil];
		
		s_regexesPrepared = YES;
	}
}

@end