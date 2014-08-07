- (NSArray *)xb_lineRangesForRanges:(NSArray *)ranges
{
	return [ranges ct_map:^id(NSValue *range)
	{
		NSRange lineRange = [self lineRangeForRange:[range rangeValue]];
		return [NSValue valueWithRange:lineRange];
	}];
}