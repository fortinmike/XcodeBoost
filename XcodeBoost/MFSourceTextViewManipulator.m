//
//  MFSourceTextViewManipulator.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFSourceTextViewManipulator.h"
#import "DVTKit.h"
#import "MFRangeHelper.h"
#import "NSArray+XcodeBoost.h"
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
	
	if ([selectedLinesString xb_startsWithMethodDefinition])
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

#pragma mark Highlighting Helpers

- (void)highlightRanges:(NSArray *)ranges
{
	NSColor *highlightColor = [_highlighter pushHighlightColor];
	DVTMarkedScroller *scroller = self.scroller;
	
	for (NSValue *range in ranges)
	{
		NSRange highlightRange = [range rangeValue];
		
		[self.textStorage addAttribute:NSBackgroundColorAttributeName value:highlightColor range:highlightRange];
		
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

#pragma mark Working With Methods

- (void)selectMethods
{
	NSArray *methodDefinitionRanges = [self.string xb_subroutineDefinitionRanges];
	NSArray *rangesToSelect = [self.sourceTextView xb_rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES];
	
	if ([rangesToSelect count] > 0)
		[self.sourceTextView setSelectedRanges:rangesToSelect affinity:NSSelectionAffinityUpstream stillSelecting:NO];
}

- (void)selectMethodSignatures
{
	NSArray *methodDefinitionRanges = [self.string xb_subroutineDefinitionRanges];
	NSArray *selectedMethodDefinitionRanges = [self.sourceTextView xb_rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES];
	NSArray *methodSignatureRanges = [self.string xb_subroutineSignatureRanges];
	
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
	NSArray *methodDefinitionRanges = [self.string xb_subroutineDefinitionRanges];
	NSArray *selectedMethodDefinitionRanges = [self.sourceTextView xb_rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES];
	
	NSRange overarchingRange = [MFRangeHelper unionRangeWithRanges:selectedMethodDefinitionRanges];
	if (overarchingRange.location == NSNotFound) return;
	
	NSString *overarchingString = [[self.textStorage string] substringWithRange:overarchingRange];
	NSString *methodDeclarations = [overarchingString xb_extractSubroutineDeclarations];
	
	[self setPasteboardString:methodDeclarations];
}

- (void)duplicateMethods
{
	NSArray *methodDefinitionRanges = [self.string xb_subroutineDefinitionRanges];
	NSArray *selectedMethodDefinitionRanges = [self.sourceTextView xb_rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES];
	NSArray *selectedMethodDefinitionLineRanges = [self.string xb_lineRangesForRanges:selectedMethodDefinitionRanges];
	
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
		NSArray *stringRanges = [self.string xb_rangesOfString:string];
		
		[self highlightRanges:stringRanges];
	}
}

- (void)highlightSelectedSymbols
{
	NSArray *symbolRanges = [self.string xb_symbolRanges];
	NSArray *selectedSymbolRanges = [self.sourceTextView xb_rangesFullyOrPartiallyContainedInSelection:symbolRanges wholeLines:NO];
	NSArray *methodDefinitionRanges = [self.string xb_subroutineDefinitionRanges];
	
	for (NSValue *selectedSymbolRange in selectedSymbolRanges)
	{
		NSString *symbolString = [self.string substringWithRange:[selectedSymbolRange rangeValue]];
		NSArray *occurenceRanges = [self.string xb_rangesOfSymbol:symbolString];
		
		// Basic scope-checking
		
		NSArray *symbolsInMethodDefinitions = [MFRangeHelper ranges:occurenceRanges fullyOrPartiallyContainedInRanges:methodDefinitionRanges];
		if ([symbolsInMethodDefinitions count] == [occurenceRanges count])
		{
			// All symbol occurences were found in method definitions; consider symbol as local
			NSValue *currentMethodDefinitionRange = [[self.sourceTextView xb_rangesFullyOrPartiallyContainedInSelection:methodDefinitionRanges wholeLines:YES] firstObject];
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
	[self highlightRanges:[self.string rx_rangesForMatchesWithPattern:pattern options:options]];
}

- (void)removeMostRecentlyAddedHighlight
{
	NSColor *highlightColorToRemove = [_highlighter popHighlightColor];
	if (!highlightColorToRemove) return;
	
	[self.scroller xb_removeMarksWithColor:highlightColorToRemove];
	
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
	
	[self.scroller xb_removeAllMarks];
	
	[textStorage enumerateAttribute:NSBackgroundColorAttributeName inRange:documentRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop)
	{
		[textStorage removeAttribute:NSBackgroundColorAttributeName range:range];
	}];
	
	[_highlighter popAllHighlightColors];
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