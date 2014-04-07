//
//  MFIDEHelper.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-07.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IDEKit.h>

@interface MFIDEHelper : NSObject

+ (IDEEditor *)currentEditor;
+ (DVTSourceTextView *)currentSourceTextView;
+ (NSString *)currentFile;

@end