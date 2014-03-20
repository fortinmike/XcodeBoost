//
//  NSObject+XcodeTextTools.h
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2013-09-25.
//  Copyright (c) 2013 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (XcodeTextTools)

- (void)xctt_setAssociatedObject:(id)object forKey:(NSString *)key;
- (void)xctt_removeAssociatedObjectForKey:(NSString *)key;
- (id)xctt_associatedObjectForKey:(NSString *)key;

@end