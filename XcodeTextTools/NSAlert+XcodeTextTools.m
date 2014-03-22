//
//  NSAlert+XcodeTextTools.m
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-21.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "NSAlert+XcodeTextTools.h"

@implementation NSAlert (XcodeTextTools)

+ (void)showDebugAlertWithFormat:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	
	NSAlert *alert = [NSAlert alertWithMessageText:@"Debug" defaultButton:@"OK" alternateButton:nil
									   otherButton:nil informativeTextWithFormat:message];
	
	[alert runModal];
}

@end