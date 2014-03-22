//
//  MFTextViewManipulator.m
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-20.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFTextViewManipulator.h"
#import "NSArray+XcodeTextTools.h"
#import "NSString+XcodeTextTools.h"
#import "NSColor+XcodeTextTools.h"
#import "NSAlert+XcodeTextTools.h"
#import "DVTKit.h"

@interface MFTextViewManipulator ()

@property (readonly, unsafe_unretained) DVTSourceTextView *sourceTextView;
@property (readonly) NSTextStorage *textStorage;

@end

@implementation MFTextViewManipulator
{
	NSUInteger _highlightCount;
	NSArray *_highlightColors;
}

#pragma mark Lifetime

- (id)initWithTextView:(DVTSourceTextView *)textView
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
	_highlightColors = @[[NSColor greenColor], [NSColor orangeColor], [NSColor blueColor],
						 [NSColor redColor], [NSColor purpleColor], [NSColor yellowColor],
						 [NSColor brownColor]];
}

#pragma mark Implementation

- (NSRange)selectedLinesRange
{
	NSValue *selectedRange = [[self.sourceTextView selectedRanges] firstObject];
	if (!selectedRange) return NSMakeRange(NSNotFound, 0);
	
	return [[self.sourceTextView string] lineRangeForRange:[selectedRange rangeValue]];
}

- (NSString *)selectedLinesString
{
	NSRange linesRange = [self selectedLinesRange];
	NSString *sourceString = [[self.textStorage attributedSubstringFromRange:linesRange] string];
	NSString *trimmedString = [sourceString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	return trimmedString;
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

#pragma mark Line Manipulation

- (void)cutLines
{
	[self copyLines];
	[self deleteLines];
}

- (void)copyLines
{
	NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
	[generalPasteboard declareTypes:@[NSPasteboardTypeString] owner:nil];
	[generalPasteboard setString:[self selectedLinesString] forType:NSPasteboardTypeString];
}

- (void)pasteLinesWithReindent:(BOOL)reindent
{
	NSMutableString *string = [[[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString] mutableCopy];
		
	NSRange linesRange = [self selectedLinesRange];
	NSString *selectedLinesString = [self selectedLinesString];
	NSString *trimmedSourceString = [selectedLinesString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	BOOL emptyLine = [trimmedSourceString isEqualToString:@""];
	
	if (!emptyLine && ![string hasSuffix:@"\n"]) [string appendString:@"\n"];
	[self insertString:string afterLinesInRange:linesRange onSameLine:emptyLine reindent:reindent];
}

- (void)pasteMethodDeclarations
{
	NSString *selectedLinesString = [self selectedLinesString];
	NSString *methodDeclarations = [selectedLinesString xctt_extractMethodDeclarations];
	[self insertString:methodDeclarations afterLinesInRange:[self selectedLinesRange] onSameLine:NO reindent:YES];
}

- (void)duplicateLines
{
	NSRange linesRange = [self selectedLinesRange];
	NSString *selectedLinesString = [[self.textStorage attributedSubstringFromRange:linesRange] string];
	
	NSMutableString *insertedString = [[NSMutableString alloc] init];
	
	if ([selectedLinesString xctt_matchesMethodDefinition])
		[insertedString appendString:@"\n"];
	
	[insertedString appendString:selectedLinesString];
	
	[self insertString:insertedString afterLinesInRange:linesRange onSameLine:NO reindent:NO];
}

- (void)deleteLines
{
	NSRange linesRange = [self selectedLinesRange];
	[self conditionallyChangeTextInRange:linesRange replacementString:@"" operation:^
	{
		[self.textStorage deleteCharactersInRange:linesRange];
		[self.sourceTextView moveToRightEndOfLine:self];
	}];
}

- (void)insertString:(NSString *)insertedString afterLinesInRange:(NSRange)linesRange onSameLine:(BOOL)onSameLine reindent:(BOOL)reindent
{
	NSUInteger insertedStringLength = [insertedString length];
	NSRange sourceRange = NSMakeRange(linesRange.location + linesRange.length, 0);
	NSUInteger sourceRangeEnd = sourceRange.location + sourceRange.length - (onSameLine ? 1 : 0);
	NSRange insertedStringRange = NSMakeRange(sourceRangeEnd, insertedStringLength);
	
	[self conditionallyChangeTextInRange:NSMakeRange(sourceRangeEnd, 0) replacementString:insertedString operation:^
	{
		[self.textStorage insertAttributedString:[insertedString xctt_attributedString] atIndex:sourceRangeEnd];
		[self.sourceTextView setSelectedRange:insertedStringRange];
		
		if (reindent) [self.sourceTextView indentSelection:self];
	}];
}

#pragma mark Highlighting

- (void)highlightSelection
{
	NSArray *selectedRanges = [self.sourceTextView selectedRanges];
	
	for (NSValue *selectedRange in selectedRanges)
	{
		NSString *selection = [[self.sourceTextView string] substringWithRange:[selectedRange rangeValue]];
		NSArray *selectionRanges = [[self.textStorage string] xctt_rangesOfString:selection];
		NSColor *highlightColor = _highlightCount < [_highlightColors count] ? _highlightColors[_highlightCount] : [NSColor xctt_randomColor];
		
		for (NSValue *selectionRange in selectionRanges)
		{
			NSRange range = [selectionRange rangeValue];
			[self.textStorage addAttribute:NSBackgroundColorAttributeName value:highlightColor range:range];
		}
		
		_highlightCount++;
	}
}

- (void)removeHighlighting
{
	NSTextStorage *textStorage = self.textStorage;
	NSRange documentRange = NSMakeRange(0, [[textStorage string] length]);
	
	[textStorage enumerateAttribute:NSBackgroundColorAttributeName inRange:documentRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop)
	{
		[textStorage removeAttribute:NSBackgroundColorAttributeName range:range];
	}];
	
	_highlightCount = 0;
}

#pragma mark Selection

- (void)expandSelection
{
	// TODO: Expand selection by considering [] and {}
	// TODO: Handle the case where the selection contains [ (for example).
	// [[NSAlert alertWithMessage^^^Text:[NSStri^^^ng stringWithFormat:@"No text storage! TV: %@", _textView] defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
	// Should select [NSAlert ... ] because the matching [ from the left of the selection is the one that closes NSAlert.
	
	[[NSAlert alertWithMessageText:@"Expand Selection" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
}

#pragma mark Accessor Overrides

- (NSTextStorage *)textStorage
{
	return [self.sourceTextView textStorage];
}

@end