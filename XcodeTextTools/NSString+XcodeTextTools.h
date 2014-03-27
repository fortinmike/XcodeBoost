//
//  NSString+XcodeTextTools.h
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-19.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSString (XcodeTextTools)

#pragma mark Creating Instances

- (NSAttributedString *)xctt_attributedString;

#pragma mark Checks

- (BOOL)xctt_containsOnlyWhitespace;

#pragma mark Ranges

- (NSRange)xctt_range;
- (NSArray *)xctt_rangesOfString:(NSString *)string;
- (NSArray *)xctt_rangesOfRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options;

#pragma mark Code Patterns

- (BOOL)xctt_startsWithMethodDefinition;
- (NSString *)xctt_extractMethodDeclarations;
- (NSArray *)xctt_methodDefinitionRanges;
- (NSArray *)xctt_methodSignatureRanges;

@end