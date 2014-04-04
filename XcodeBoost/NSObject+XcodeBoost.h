//
//  NSObject+XcodeBoost.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2013-09-25.
//  Copyright (c) 2013 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (XcodeBoost)

- (void)xb_setAssociatedObject:(id)object forKey:(NSString *)key;
- (void)xb_removeAssociatedObjectForKey:(NSString *)key;
- (id)xb_associatedObjectForKey:(NSString *)key;

@end