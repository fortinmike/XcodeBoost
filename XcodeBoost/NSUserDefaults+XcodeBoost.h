//
//  NSUserDefaults+XcodeBoost.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-05-25.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSUserDefaults (XcodeBoost)

- (NSColor *)xb_colorForKey:(NSString *)key;
- (void)xb_setColor:(NSColor *)color forKey:(NSString *)key;

@end