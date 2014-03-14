//
//  NSArray+XcodeTextTools.h
//  XcodeTextTools
//
//  Created by Michaël Fortin on 2014-03-14.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^BoolObjectBlock)(id object);

@interface NSArray (XcodeTextTools)

- (instancetype)xctt_where:(BoolObjectBlock)condition; // Returns objects that match the specified condition

@end