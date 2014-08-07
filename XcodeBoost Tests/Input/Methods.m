@implementation NSString (Test)

// 0- Simple method with blocks, object parameters and return type, underscore in method name...
- (NSArray *)xb_lineRangesForRanges:(NSArray *)ranges
{
	return [ranges ct_map:^id(NSValue *range)
	{
		NSRange lineRange = [self lineRangeForRange:[range rangeValue]];
		return [NSValue valueWithRange:lineRange];
	}];
}

// 1- Method with signature on multiple lines
- (void)downloadDataFileAtURL:(NSURL *)url
					   toFile:(NSString *)destinationFile
					  timeout:(NSTimeInterval)timeout
{
	return;
}

// 2- Method with superfluous whitespace between signature and braces
- (void)downloadDataFileAtURL:(NSURL *)url

{
	return;
}

// 3- Empty method with no parameters
- (void)update
{
}

// 4- K & R
- (void)bam {
	if (test) {
		return;
	}
}

// 5- K & R weird spacing and superfluous whitespace
- (void)bam{    
	if(test){   
		return;  
	}
}

// 6- Jumbo method with lots of code and comments
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

@end