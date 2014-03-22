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

@interface MFTextViewManipulator ()

@property (readonly, unsafe_unretained) NSTextView *textView;
@property (readonly) NSTextStorage *textStorage;

@end

@implementation MFTextViewManipulator
{
	NSUInteger _highlightCount;
	NSArray *_highlightColors;
}

#pragma mark Lifetime

- (id)initWithTextView:(NSTextView *)textView
{
	self = [super init];
	if (self)
	{
		_textView = textView;
		
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

- (NSRange)selectedLineRange
{
	NSValue *selectedRange = [[self.textView selectedRanges] firstObject];
	if (!selectedRange) return NSMakeRange(NSNotFound, 0);
	
	return [[self.textView string] lineRangeForRange:[selectedRange rangeValue]];
}

- (void)conditionallyChangeTextInRange:(NSRange)range replacementString:(NSString *)replacementString operation:(Block)operation
{
	if (range.location == NSNotFound) return;
	
	// Preserves undo/redo behavior!
	if ([self.textView shouldChangeTextInRange:range replacementString:replacementString])
	{
		operation();
		[self.textView didChangeText];
	}
}

#pragma mark Line Manipulation

- (void)cutLine
{
	[[NSAlert alertWithMessageText:@"Cut Line" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
}

- (void)copyLine
{
	[[NSAlert alertWithMessageText:@"Copy Line" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
}

- (void)pasteLine
{
	[[NSAlert alertWithMessageText:@"Paste Line" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
}

- (void)duplicateLine
{
	NSRange lineRange = [self selectedLineRange];
	NSAttributedString *lineString = [self.textStorage attributedSubstringFromRange:lineRange];
	NSRange actualRange = NSMakeRange(lineRange.location + lineRange.length, 0);
	NSRange editedRange = NSMakeRange(lineRange.location + lineRange.length - 1, 0);
	[self conditionallyChangeTextInRange:editedRange replacementString:[lineString string] operation:^
	{
		[self.textStorage insertAttributedString:lineString atIndex:actualRange.location];
		[self.textView moveDown:self];
		[self.textView moveToRightEndOfLine:self];
	}];
}

- (void)deleteLine
{
	NSRange lineRange = [self selectedLineRange];
	[self conditionallyChangeTextInRange:lineRange replacementString:@"" operation:^
	{
		[self.textStorage deleteCharactersInRange:lineRange];
		[self.textView moveToRightEndOfLine:self];
	}];
}

#pragma mark Highlighting

- (void)highlightSelection
{
	NSArray *selectedRanges = [self.textView selectedRanges];
	
	for (NSValue *selectedRange in selectedRanges)
	{
		NSString *selection = [[self.textView string] substringWithRange:[selectedRange rangeValue]];
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
	return [self.textView textStorage];
}

@end