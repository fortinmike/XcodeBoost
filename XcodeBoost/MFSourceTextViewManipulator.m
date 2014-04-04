//
//  MFSourceTextViewManipulator.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFSourceTextViewManipulator.h"
#import "MFRangeHelper.h"
#import "NSArray+XcodeBoost.h"
#import "NSString+XcodeBoost.h"
#import "NSColor+XcodeBoost.h"
#import "NSAlert+XcodeBoost.h"
#import "DVTSourceTextView+XcodeBoost.h"
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
	NSColor *yellowColor = [NSColor colorWithCalibratedRed:0.91 green:0.74 blue:0.14 alpha:1];
	NSColor *blueColor = [NSColor colorWithCalibratedRed:0.05 green:0.24 blue:1 alpha:1];
	NSColor *redColor = [NSColor colorWithCalibratedRed:0.69 green:0.07 blue:0.14 alpha:1];
	NSColor *purpleColor = [NSColor colorWithCalibratedRed:0.58 green:0.09 blue:0.93 alpha:1];
	
	_highlightColors = [@[purpleColor, redColor, blueColor, yellowColor] mutableCopy];
}

#pragma mark Line Manipulation Helpers

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
	[self setPasteboardString:[self.sourceTextView xctt_firstSelectedLineRangeString]];
	[self deleteLines];
}

- (void)copyLines
{
	[self setPasteboardString:[self.string xctt_concatenatedStringForRanges:[self.sourceTextView xctt_selectedLineRanges]]];
}

- (void)pasteLinesWithReindent:(BOOL)reindent
{
	NSMutableString *pasteboardString = [[self getPasteboardString] mutableCopy];
	NSRange linesRange = [self.sourceTextView xctt_firstSelectedLineRange];
	
	[self insertString:pasteboardString afterRange:linesRange reindent:reindent];
}

- (void)duplicateLines
{
	[self duplicateLines:[self.sourceTextView xctt_firstSelectedLineRange]];
}

- (void)deleteLines
{
	NSRange linesRange = [self.sourceTextView xctt_firstSelectedLineRange];
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
	NSArray *rangesToSelect = [self.sourceTextView xctt_rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES];
	
	if ([rangesToSelect count] > 0)
		[self.sourceTextView setSelectedRanges:rangesToSelect affinity:NSSelectionAffinityUpstream stillSelecting:NO];
}

- (void)selectMethodSignatures
{
	NSArray *methodDefinitionRanges = [self.string xctt_methodDefinitionRanges];
	NSArray *selectedMethodDefinitionRanges = [self.sourceTextView xctt_rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES];
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
	NSArray *selectedMethodDefinitionRanges = [self.sourceTextView xctt_rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES];
	
	NSRange overarchingRange = [MFRangeHelper unionRangeWithRanges:selectedMethodDefinitionRanges];
	if (overarchingRange.location == NSNotFound) return;
	
	NSString *overarchingString = [[self.textStorage string] substringWithRange:overarchingRange];
	NSString *methodDeclarations = [overarchingString xctt_extractMethodDeclarations];
	
	[self setPasteboardString:methodDeclarations];
}

- (void)duplicateMethods
{
	NSArray *methodDefinitionRanges = [self.string xctt_methodDefinitionRanges];
	NSArray *selectedMethodDefinitionRanges = [self.sourceTextView xctt_rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES];
	NSArray *selectedMethodDefinitionLineRanges = [self.string xctt_lineRangesForRanges:selectedMethodDefinitionRanges];
	
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
	NSArray *selectedSymbolRanges = [self.sourceTextView xctt_rangesFullyOrPartiallyContainedInSelection:symbolRanges wholeLines:NO];
	NSArray *methodDefinitionRanges = [self.string xctt_methodDefinitionRanges];
	
	for (NSValue *selectedSymbolRange in selectedSymbolRanges)
	{
		NSString *symbolString = [self.string substringWithRange:[selectedSymbolRange rangeValue]];
		NSArray *occurenceRanges = [self.string xctt_rangesOfSymbol:symbolString];
		
		// Basic scope-checking
		
		NSArray *symbolsInMethodDefinitions = [MFRangeHelper ranges:occurenceRanges fullyOrPartiallyContainedInRanges:methodDefinitionRanges];
		if ([symbolsInMethodDefinitions count] == [occurenceRanges count])
		{
			// All symbol occurences were found in method definitions; consider symbol as local
			NSValue *currentMethodDefinitionRange = [[self.sourceTextView xctt_rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES] firstObject];
			if (!currentMethodDefinitionRange) continue;
			
			[self highlightRanges:[MFRangeHelper ranges:occurenceRanges fullyOrPartiallyContainedInRanges:@[currentMethodDefinitionRange]]];
		}
		else
		{
			// Some of the symbol occurences were found outside of method definitions;
			// consider symbol as global and highlight all occurences.
			[self highlightRanges:occurenceRanges];
		}
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