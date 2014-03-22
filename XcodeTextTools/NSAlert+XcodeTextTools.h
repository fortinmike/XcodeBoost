//
//  NSAlert+XcodeTextTools.h
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-21.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSAlert (XcodeTextTools)

+ (void)showDebugAlertWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

@end