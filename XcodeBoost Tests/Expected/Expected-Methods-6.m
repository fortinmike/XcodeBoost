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