//
//  RXRegexCache.m
//  Regexer
//
//  Created by Michaël Fortin on 2014-05-02.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "RXRegexCache.h"

@implementation RXRegexCache
{
	NSMutableDictionary *_cache;
}

#pragma mark Lifetime

+ (instancetype)sharedCache
{
	static dispatch_once_t pred;
	static RXRegexCache *instance = nil;
	dispatch_once(&pred, ^{ instance = [[self alloc] init]; });
	return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _cache = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark Public Methods

- (NSRegularExpression *)regexForPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options
{
	@synchronized(self)
	{
		NSString *key = [self keyForPattern:pattern options:options];
		
		NSRegularExpression *regex = _cache[key];
		if (!regex)
		{
			NSError *error;
			regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&error];
			
			if (error)
			{
				NSString *reason = [NSString stringWithFormat:@"Could not create regex with pattern %@ and options %lu", pattern, (unsigned long)options];
				@throw [NSException exceptionWithName:@"Can't Create Regex" reason:reason userInfo:nil];
			}
			
			_cache[key] = regex;
		}
		
		return regex;
	}
}

- (void)clear
{
	@synchronized(self)
	{
		[_cache removeAllObjects];
	}
}

#pragma mark Private Methods

- (NSString *)keyForPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options
{
	// A super-simple way to create a unique key for the regex:
	return [pattern stringByAppendingString:[@(options) stringValue]];
}

@end