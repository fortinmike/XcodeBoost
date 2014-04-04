//
//  NSObject+XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2013-09-25.
//  Copyright (c) 2013 Michaël Fortin. All rights reserved.
//

#import "NSObject+XcodeBoost.h"
#import <objc/message.h>

@implementation NSObject (XcodeBoost)

static const char KeysStorageKey[] = "keysStorage";

- (void)xb_setAssociatedObject:(id)object forKey:(NSString *)key
{
	objc_setAssociatedObject(self, [self xb_keyForString:key], object, OBJC_ASSOCIATION_RETAIN);
}

- (void)xb_removeAssociatedObjectForKey:(NSString *)key
{
	objc_setAssociatedObject(self, [self xb_keyForString:key], nil, OBJC_ASSOCIATION_ASSIGN);
}

- (id)xb_associatedObjectForKey:(NSString *)key
{
	return objc_getAssociatedObject(self, [self xb_keyForString:key]);
}

- (void *)xb_keyForString:(NSString *)string
{
	NSMutableDictionary *keysStorage = objc_getAssociatedObject(self, &KeysStorageKey);
	
	if (keysStorage == nil)
	{
		keysStorage = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &KeysStorageKey, keysStorage, OBJC_ASSOCIATION_RETAIN);
	}
	
	NSString *existingKey = [keysStorage objectForKey:string];
	if (existingKey == nil)
	{
		existingKey = string;
		[keysStorage setObject:string forKey:string];
	}
	
	return (__bridge void *)(existingKey);
}

@end