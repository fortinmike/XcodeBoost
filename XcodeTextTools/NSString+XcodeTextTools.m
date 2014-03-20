//
//  NSString+XcodeTextTools.m
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-19.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSString+XcodeTextTools.h"

@implementation NSString (XcodeTextTools)

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

@end