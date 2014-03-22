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

#pragma mark Ranges

- (NSRange)xctt_range;
- (NSArray *)xctt_rangesOfString:(NSString *)string;

#pragma mark Code Patterns

- (BOOL)xctt_startsWithMethodDefinition;
- (NSString *)xctt_extractMethodDeclarations;

@end