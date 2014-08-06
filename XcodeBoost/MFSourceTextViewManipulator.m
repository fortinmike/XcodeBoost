//
//  MFSourceTextViewManipulator.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "Collector.h"
#import "MFSourceTextViewManipulator.h"
#import "XcodeBoostConstants.h"
#import "DVTKit.h"
#import "MFRangeHelper.h"
#import "NSString+XcodeBoost.h"
#import "NSColor+XcodeBoost.h"
#import "NSView+XcodeBoost.h"
#import "DVTSourceTextView+XcodeBoost.h"
#import "DVTMarkedScroller+XcodeBoost.h"
#import "MFHighlighter.h"
#import "NSString+Regexer.h"

@interface MFSourceTextViewManipulator ()

@property (readonly, unsafe_unretained) DVTSourceTextView *sourceTextView;
@property (readonly) NSTextStorage *textStorage;
@property (readonly) NSString *string;

@end

@implementation MFSourceTextViewManipulator
{
	MFHighlighter *_highlighter;
}

#pragma mark Lifetime

- (id)initWithSourceTextView:(DVTSourceTextView *)textView
{
	self = [super init];
	if (self)
	{
		_sourceTextView = textView;
		
		_highlighter = [[MFHighlighter alloc] init];
	}
	return self;
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
	
	if ([selectedLinesString xb_startsWithSubroutineDefinition])
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
		[self.textStorage insertAttributedString:[stringToInsert xb_attributedString] atIndex:rangeEnd];
		[self.sourceTextView setSelectedRange:NSMakeRange(beforeRangeEnd + [stringToInsert length], 0)];
		
		if (reindent) [self.sourceTextView indentSelection:self];
	}];
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
	[self setPasteboardString:[self.sourceTextView xb_firstSelectedLineRangeString]];
	[self deleteLines];
}

- (void)copyLines
{
	[self setPasteboardString:[self.string xb_concatenatedStringForRanges:[self.sourceTextView xb_selectedLineRanges]]];
}

- (void)pasteLinesWithReindent:(BOOL)reindent
{
	NSMutableString *pasteboardString = [[self getPasteboardString] mutableCopy];
	NSRange linesRange = [self.sourceTextView xb_firstSelectedLineRange];
	
	[self insertString:pasteboardString afterRange:linesRange reindent:reindent];
}

- (void)duplicateLines
{
	[self duplicateLines:[self.sourceTextView xb_firstSelectedLineRange]];
}

- (void)deleteLines
{
	NSRange linesRange = [self.sourceTextView xb_firstSelectedLineRange];
	[self conditionallyChangeTextInRange:linesRange replacementString:@"" operation:^
	{
		[self.textStorage deleteCharactersInRange:linesRange];
		[self.sourceTextView moveToRightEndOfLine:self];
	}];
}

#pragma mark Working With Subroutines (Methods and Functions)

- (void)selectSubroutines
{
	NSArray *subroutineDefinitionRanges = [self.string xb_subroutineDefinitionRanges];
	NSArray *rangesToSelect = [self.sourceTextView xb_rangesFullyOrPartiallyContainedInSelection:subroutineDefinitionRanges wholeLines:YES];
	
	if ([rangesToSelect count] > 0)
		[self.sourceTextView setSelectedRanges:rangesToSelect affinity:NSSelectionAffinityUpstream stillSelecting:NO];
}

- (void)selectSubroutineSignatures
{
	NSArray *subroutineDefinitionRanges = [self.string xb_subroutineDefinitionRanges];
	NSArray *selectedSubroutineDefinitionRanges = [self.sourceTextView xb_rangesFullyOrPartiallyContainedInSelection:subroutineDefinitionRanges wholeLines:YES];
	NSArray *subroutineSignatureRanges = [self.string xb_subroutineSignatureRanges];
	
	NSMutableArray *rangesToSelect = [NSMutableArray array];
	for (NSValue *subroutineSignatureRange in subroutineSignatureRanges)
	{
		for (NSValue *selectedSubroutineDefinitionRange in selectedSubroutineDefinitionRanges)
		{
			if (NSIntersectionRange([subroutineSignatureRange rangeValue], [selectedSubroutineDefinitionRange rangeValue]).length != 0)
				[rangesToSelect addObject:subroutineSignatureRange];
		}
	}
	
	if ([rangesToSelect count] > 0)
		[self.sourceTextView setSelectedRanges:rangesToSelect affinity:NSSelectionAffinityUpstream stillSelecting:NO];
}

- (void)copySubroutineDeclarations
{
	NSArray *subroutineDefinitionRanges = [self.string xb_subroutineDefinitionRanges];
	NSArray *selectedSubroutineDefinitionRanges = [self.sourceTextView xb_rangesFullyOrPartiallyContainedInSelection:subroutineDefinitionRanges wholeLines:YES];
	
	NSRange overarchingRange = [MFRangeHelper unionRangeWithRanges:selectedSubroutineDefinitionRanges];
	if (overarchingRange.location == NSNotFound) return;
	
	NSString *overarchingString = [[self.textStorage string] substringWithRange:overarchingRange];
	NSString *subroutineDeclarations = [overarchingString xb_extractSubroutineDeclarations];
	
	[self setPasteboardString:subroutineDeclarations];
}

- (void)duplicateSubroutines
{
	NSArray *subroutineDefinitionRanges = [self.string xb_subroutineDefinitionRanges];
	NSArray *selectedSubroutineDefinitionRanges = [self.sourceTextView xb_rangesFullyOrPartiallyContainedInSelection:subroutineDefinitionRanges wholeLines:YES];
	NSArray *selectedSubroutineDefinitionLineRanges = [self.string xb_lineRangesForRanges:selectedSubroutineDefinitionRanges];
	
	if ([selectedSubroutineDefinitionLineRanges count] == 0) return;
	
	NSRange unionRange = [selectedSubroutineDefinitionLineRanges[0] rangeValue];
	for (NSValue *range in selectedSubroutineDefinitionLineRanges)
		unionRange = NSUnionRange(unionRange, [range rangeValue]);
	
	[self duplicateLines:unionRange];
}

#pragma mark Highlighting

- (void)highlightSelectedStrings
{
	[self.textStorage beginEditing];
	
	for (NSValue *range in [self.sourceTextView selectedRanges])
	{
		NSString *string = [self.string substringWithRange:[range rangeValue]];
		NSArray *stringRanges = [self.string xb_rangesOfString:string];
		
		[self highlightRanges:stringRanges];
	}
	
	[self.textStorage endEditing];
}

- (void)highlightSelectedSymbols
{
	NSArray *subroutineDefinitionRanges = [self.string xb_subroutineDefinitionRanges];
	NSArray *symbols = [self.string xb_symbols];
	NSArray *symbolsInSelection = [symbols ct_where:^BOOL(MFSymbol *symbol)
	{
		return [self.sourceTextView xb_rangeIsFullyOrPartiallyContainedInSelection:[symbol matchRange] wholeLines:NO];
	}];
	
	[self.textStorage beginEditing];
	
	for (MFSymbol *symbol in symbolsInSelection)
	{
		NSArray *symbolOccurenceRanges = [self.string xb_rangesOfSymbol:symbol];
		
		// Basic scope-checking
		
		NSArray *symbolsInSubroutineDefinitions = [MFRangeHelper ranges:symbolOccurenceRanges fullyOrPartiallyContainedInRanges:subroutineDefinitionRanges];
		
		BOOL isFoundInGlobalScope = ([symbolsInSubroutineDefinitions count] != [symbolOccurenceRanges count]);
		BOOL isField = [symbol type] == MFSymbolTypeField;
		BOOL isPropertyAccess = [symbol type] == MFSymbolTypePropertyAccess;
		
		if (isFoundInGlobalScope || isField || isPropertyAccess)
		{
			// Some of the symbol occurences were found outside of subroutine definitions;
			// consider symbol as global and highlight all occurences.
			[self highlightRanges:symbolOccurenceRanges];
		}
		else
		{
			// Else consider symbol as local
			NSValue *currentSubroutineDefinitionRange = [[self.sourceTextView xb_rangesFullyOrPartiallyContainedInSelection:subroutineDefinitionRanges wholeLines:YES] firstObject];
			if (!currentSubroutineDefinitionRange) continue;
			
			[self highlightRanges:[MFRangeHelper ranges:symbolOccurenceRanges fullyOrPartiallyContainedInRanges:@[currentSubroutineDefinitionRange]]];
		}
	}
	
	[self.textStorage endEditing];
}

- (void)highlightRegexMatchesWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options
{
	[self.textStorage beginEditing];
	
	[self highlightRanges:[self.string rx_rangesForMatchesWithPattern:pattern options:options]];
	
	[self.textStorage endEditing];
}

- (void)removeMostRecentlyAddedHighlight
{
	NSColor *highlightColorToRemove = [_highlighter popHighlightColor];
	if (!highlightColorToRemove) return;
	
	[self.scroller xb_removeMarksWithColor:highlightColorToRemove];
	
	NSTextStorage *textStorage = self.textStorage;
	NSRange documentRange = NSMakeRange(0, [[textStorage string] length]);
	
	[textStorage beginEditing];
	
	[textStorage enumerateAttribute:XBHighlightColorAttributeName inRange:documentRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop)
	{
		if ([value isEqual:highlightColorToRemove])
			[textStorage removeAttribute:XBHighlightColorAttributeName range:range];
	}];
	
	[textStorage endEditing];
}

- (void)removeAllHighlighting
{
	NSRange documentRange = NSMakeRange(0, [[self.textStorage string] length]);
	
	[self.textStorage beginEditing];
	[self.textStorage removeAttribute:XBHighlightColorAttributeName range:documentRange];
	[self.textStorage endEditing];
	
	[self.scroller xb_removeAllMarks];
	[_highlighter popAllHighlightColors];
}

#pragma mark Highlighting Core

- (void)highlightRanges:(NSArray *)ranges
{
	NSColor *highlightColor = [_highlighter pushHighlightColor];
	DVTMarkedScroller *scroller = self.scroller;
	
	for (NSValue *range in ranges)
	{
		NSRange highlightRange = [range rangeValue];
		
		[self highlightRange:highlightRange withColor:highlightColor];
		
		// Add a color mark to the scroller
		NSLayoutManager *layoutManager = [self.sourceTextView layoutManager];
		NSRange glyphRange = [layoutManager glyphRangeForCharacterRange:highlightRange actualCharacterRange:NULL];
		NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphRange.location effectiveRange:NULL];
		CGFloat rangeRatio = lineRect.origin.y / [self.sourceTextView bounds].size.height;
		[scroller xb_addMarkWithColor:highlightColor atRatio:rangeRatio];
		
		// Sometimes when the window is not key (such as when a panel is opened in front of it)
		// the text view won't update to show the newly added highlighting.
		[self.sourceTextView setNeedsDisplay:YES];
	}
}

- (void)highlightRange:(NSRange)range withColor:(NSColor *)color
{
	[self.textStorage addAttribute:XBHighlightColorAttributeName value:color range:range];
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

- (DVTMarkedScroller *)scroller
{
	NSScrollView *scrollView = (NSScrollView *)[self.sourceTextView ancestorOfKind:[NSScrollView class]];
	DVTMarkedScroller *scroller = (DVTMarkedScroller *)[[scrollView descendantsOfKind:[DVTMarkedScroller class]] firstObject];
	
	return scroller;
}

@end