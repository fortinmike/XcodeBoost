//
//  MFSourceTextViewManipulator.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFSourceTextViewManipulator.h"
#import "NSArray+XcodeBoost.h"
#import "NSString+XcodeBoost.h"
#import "NSColor+XcodeBoost.h"
#import "NSAlert+XcodeBoost.h"
#import "DVTKit.h"

@interface MFSourceTextViewManipulator ()

@property (readonly, unsafe_unretained) DVTSourceTextView *sourceTextView;
@property (readonly) NSTextStorage *textStorage;
@property (readonly) NSString *string;

@end

@implementation MFSourceTextViewManipulator
{
	NSUInteger _highlightCount;
	NSMutableArray *_highlightColors;
}

#pragma mark Lifetime

- (id)initWithSourceTextView:(DVTSourceTextView *)textView
{
	self = [super init];
	if (self)
	{
		_sourceTextView = textView;
		
		[self setupHighlightColors];
	}
	return self;
}

- (void)setupHighlightColors
{
	_highlightColors = [@[[NSColor greenColor], [NSColor orangeColor], [NSColor blueColor],
						 [NSColor redColor], [NSColor purpleColor], [NSColor yellowColor],
						 [NSColor brownColor]] mutableCopy];
}

#pragma mark Line Manipulation Helpers

- (NSArray *)selectedLineRanges
{
	NSArray *selectedRanges = [self.sourceTextView selectedRanges];
	return [self lineRangesForRanges:selectedRanges];
}

- (NSString *)concatenatedStringForRanges:(NSArray *)ranges
{
	NSMutableString *concatenated = [[NSMutableString alloc] init];
	
	for (NSValue *range in ranges)
		[concatenated appendString:[self.string substringWithRange:[range rangeValue]]];
	
	return concatenated;
}

- (NSRange)firstSelectedLineRange
{
	NSValue *selectedRange = [[self.sourceTextView selectedRanges] firstObject];
	if (!selectedRange) return NSMakeRange(NSNotFound, 0);
	
	return [self.string lineRangeForRange:[selectedRange rangeValue]];
}

- (NSString *)firstSelectedLineRangeString
{
	NSRange linesRange = [self firstSelectedLineRange];
	NSString *sourceString = [[self.textStorage attributedSubstringFromRange:linesRange] string];
	NSString *trimmedString = [sourceString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	return trimmedString;
}

- (NSArray *)lineRangesForRanges:(NSArray *)ranges
{
	return [ranges xctt_map:^id(NSValue *range)
	{
		NSRange lineRange = [self.string lineRangeForRange:[range rangeValue]];
		return [NSValue valueWithRange:lineRange];
	}];
}

- (NSArray *)rangesFullyOrPartiallyContainedInSelection:(NSArray *)rangesToFilter wholeLines:(BOOL)wholeLines
{
	NSArray *selectedRanges = wholeLines ? [self selectedLineRanges] : [self.sourceTextView selectedRanges];
	
	NSMutableArray *rangesOverlappingSelection = [NSMutableArray array];
	for (NSValue *range in rangesToFilter)
	{
		for (NSValue *selectedRange in selectedRanges)
		{
			if (MFRangeOverlaps([range rangeValue], [selectedRange rangeValue]))
				[rangesOverlappingSelection addObject:range];
		}
	}
	
	return rangesOverlappingSelection;
}

- (NSRange)unionRangeWithRanges:(NSArray *)ranges
{
	if ([ranges count] == 0)
		return NSMakeRange(NSNotFound, 0);
	
	NSRange unionRange = [ranges[0] rangeValue];
	
	for (int i = 1; i < [ranges count]; i++)
		unionRange = NSUnionRange([ranges[i] rangeValue], unionRange);
	
	return unionRange;
}

- (void)conditionallyChangeTextInRange:(NSRange)range replacementString:(NSString *)replacementString operation:(Block)operation
{
	if (range.location == NSNotFound) return;
	
	// Preserves undo/redo behavior!
	if ([self.sourceTextView shouldChangeTextInRange:range replacementString:replacementString])
	{
		operation();
		[self.sourceTextView didChangeText];
	}
}

- (void)duplicateLines:(NSRange)linesRange
{
	NSString *selectedLinesString = [[self.textStorage attributedSubstringFromRange:linesRange] string];
	
	NSMutableString *insertedString = [[NSMutableString alloc] init];
	
	if ([selectedLinesString xctt_startsWithMethodDefinition])
		[insertedString appendString:@"\n"];
	
	[insertedString appendString:selectedLinesString];
	
	[self insertString:insertedString afterRange:linesRange reindent:NO];
}

- (void)insertString:(NSString *)string afterRange:(NSRange)range reindent:(BOOL)reindent
{
	// Make sure we're working with a line range
	range = [self.string lineRangeForRange:range];
	
	NSMutableString *stringToInsert = [string mutableCopy];
	
	if (![stringToInsert hasSuffix:@"\n"])
		[stringToInsert appendString:@"\n"];
	
	NSUInteger rangeEnd = range.location + range.length;
	NSUInteger beforeRangeEnd = rangeEnd - 1;
	
	[self conditionallyChangeTextInRange:NSMakeRange(beforeRangeEnd, 0) replacementString:stringToInsert operation:^
	{
		[self.textStorage insertAttributedString:[stringToInsert xctt_attributedString] atIndex:rangeEnd];
		[self.sourceTextView setSelectedRange:NSMakeRange(beforeRangeEnd + [stringToInsert length], 0)];
		
		if (reindent) [self.sourceTextView indentSelection:self];
	}];
}

#pragma mark Highlighting Helpers

- (void)highlightRanges:(NSArray *)ranges
{
	NSColor *highlightColor = [self pushHighlightColor];
	
	for (NSValue *range in ranges)
	{
		[self.textStorage addAttribute:NSBackgroundColorAttributeName value:highlightColor range:[range rangeValue]];
		
		// Sometimes when the window is not key (such as when a panel is opened in front of it)
		// the text view won't update to show the newly added highlighting.
		[self.sourceTextView setNeedsDisplay:YES];
	}
}

- (NSColor *)pushHighlightColor
{
	NSColor *color;
	
	if (_highlightCount < [_highlightColors count])
	{
		color = _highlightColors[_highlightCount];
	}
	else
	{
		color = [NSColor xctt_randomColor];
		
		// Add the color to the array of colors so that we can undo highlighting
		// step-by-step afterwards (by enumerating over ranges with those background colors).
		[_highlightColors addObject:color];
	}
	
	_highlightCount++;
	
	return color;
}

- (NSColor *)popHighlightColor
{
	if (_highlightCount == 0) return nil;
	_highlightCount--;
	
	return _highlightColors[_highlightCount];
}

- (void)popAllHighlightColors
{
	_highlightCount = 0;
}

#pragma mark Pasteboard Helpers

- (NSString *)getPasteboardString
{
	return [[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString];
}

- (void)setPasteboardString:(NSString *)string
{
	NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
	[generalPasteboard declareTypes:@[NSPasteboardTypeString] owner:nil];
	[generalPasteboard setString:string forType:NSPasteboardTypeString];
}

#pragma mark Line Manipulation

- (void)cutLines
{
	[self setPasteboardString:[self firstSelectedLineRangeString]];
	[self deleteLines];
}

- (void)copyLines
{
	[self setPasteboardString:[self concatenatedStringForRanges:[self selectedLineRanges]]];
}

- (void)pasteLinesWithReindent:(BOOL)reindent
{
	NSMutableString *pasteboardString = [[self getPasteboardString] mutableCopy];
	NSRange linesRange = [self firstSelectedLineRange];
	
	[self insertString:pasteboardString afterRange:linesRange reindent:reindent];
}

- (void)duplicateLines
{
	[self duplicateLines:[self firstSelectedLineRange]];
}

- (void)deleteLines
{
	NSRange linesRange = [self firstSelectedLineRange];
	[self conditionallyChangeTextInRange:linesRange replacementString:@"" operation:^
	{
		[self.textStorage deleteCharactersInRange:linesRange];
		[self.sourceTextView moveToRightEndOfLine:self];
	}];
}

#pragma mark Working With Methods

- (void)selectMethods
{
	NSArray *methodDefinitionRanges = [self.string xctt_methodDefinitionRanges];
	NSArray *rangesToSelect = [self rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES];
	
	if ([rangesToSelect count] > 0)
		[self.sourceTextView setSelectedRanges:rangesToSelect affinity:NSSelectionAffinityUpstream stillSelecting:NO];
}

- (void)selectMethodSignatures
{
	NSArray *methodDefinitionRanges = [self.string xctt_methodDefinitionRanges];
	NSArray *selectedMethodDefinitionRanges = [self rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES];
	NSArray *methodSignatureRanges = [self.string xctt_methodSignatureRanges];
	
	NSMutableArray *rangesToSelect = [NSMutableArray array];
	for (NSValue *methodSignatureRange in methodSignatureRanges)
	{
		for (NSValue *selectedMethodDefinitionRange in selectedMethodDefinitionRanges)
		{
			if (NSIntersectionRange([methodSignatureRange rangeValue], [selectedMethodDefinitionRange rangeValue]).length != 0)
				[rangesToSelect addObject:methodSignatureRange];
		}
	}
	
	if ([rangesToSelect count] > 0)
		[self.sourceTextView setSelectedRanges:rangesToSelect affinity:NSSelectionAffinityUpstream stillSelecting:NO];
}

- (void)copyMethodDeclarations
{
	NSArray *methodDefinitionRanges = [self.string xctt_methodDefinitionRanges];
	NSArray *selectedMethodDefinitionRanges = [self rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES];
	
	NSRange overarchingRange = [self unionRangeWithRanges:selectedMethodDefinitionRanges];
	if (overarchingRange.location == NSNotFound) return;
	
	NSString *overarchingString = [[self.textStorage string] substringWithRange:overarchingRange];
	NSString *methodDeclarations = [overarchingString xctt_extractMethodDeclarations];
	
	[self setPasteboardString:methodDeclarations];
}

- (void)duplicateMethods
{
	NSArray *methodDefinitionRanges = [self.string xctt_methodDefinitionRanges];
	NSArray *selectedMethodDefinitionRanges = [self rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES];
	NSArray *selectedMethodDefinitionLineRanges = [self lineRangesForRanges:selectedMethodDefinitionRanges];
	
	if ([selectedMethodDefinitionLineRanges count] == 0) return;
	
	NSRange unionRange = [selectedMethodDefinitionLineRanges[0] rangeValue];
	for (NSValue *range in selectedMethodDefinitionLineRanges)
		unionRange = NSUnionRange(unionRange, [range rangeValue]);
	
	[self duplicateLines:unionRange];
}

#pragma mark Highlighting

- (void)highlightSelectedStrings
{
	for (NSValue *range in [self.sourceTextView selectedRanges])
	{
		NSString *string = [self.string substringWithRange:[range rangeValue]];
		NSArray *stringRanges = [self.string xctt_rangesOfString:string];
		
		[self highlightRanges:stringRanges];
	}
}

- (void)highlightSelectedSymbols
{
	NSArray *symbolRanges = [self.string xctt_symbolRanges];
	NSArray *selectedSymbolRanges = [self rangesFullyOrPartiallyContainedInSelection:symbolRanges wholeLines:NO];
	
	for (NSValue *selectedSymbolRange in selectedSymbolRanges)
	{
		NSString *symbolString = [self.string substringWithRange:[selectedSymbolRange rangeValue]];
		NSArray *selectedSymbolOccurenceRanges = [self.string xctt_rangesOfSymbol:symbolString];
		[self highlightRanges:selectedSymbolOccurenceRanges];
	}
}

- (void)highlightRegexMatchesWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options
{
	[self highlightRanges:[self.string xctt_rangesOfRegex:pattern options:options]];
}

- (void)removeMostRecentlyAddedHighlight
{
	NSColor *highlightColorToRemove = [self popHighlightColor];
	if (!highlightColorToRemove) return;
	
	NSTextStorage *textStorage = self.textStorage;
	NSRange documentRange = NSMakeRange(0, [[textStorage string] length]);
	
	[textStorage enumerateAttribute:NSBackgroundColorAttributeName inRange:documentRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop)
	{
		if ([value isEqual:highlightColorToRemove])
			[textStorage removeAttribute:NSBackgroundColorAttributeName range:range];
	}];
}

- (void)removeAllHighlighting
{
	NSTextStorage *textStorage = self.textStorage;
	NSRange documentRange = NSMakeRange(0, [[textStorage string] length]);
	
	[textStorage enumerateAttribute:NSBackgroundColorAttributeName inRange:documentRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop)
	{
		[textStorage removeAttribute:NSBackgroundColorAttributeName range:range];
	}];
	
	[self popAllHighlightColors];
}

#pragma mark Accessor Overrides

- (NSTextStorage *)textStorage
{
	return [self.sourceTextView textStorage];
}

- (NSString *)string
{
	return [self.textStorage string];
}

@end