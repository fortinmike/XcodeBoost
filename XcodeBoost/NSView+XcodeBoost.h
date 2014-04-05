//
//  NSView+XcodeBoost.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-04.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (XcodeBoost)

- (NSView *)ancestorOfKind:(Class)kind;
- (NSArray *)descendantsOfKind:(Class)kind;

@end