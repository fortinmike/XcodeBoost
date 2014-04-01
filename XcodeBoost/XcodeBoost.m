//
//  XcodeBoost.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-03-14.
//    Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "XcodeBoost.h"
#import "MFPluginController.h"

static MFPluginController *_pluginController;

@implementation XcodeBoost

+ (void)pluginDidLoad:(NSBundle *)pluginBundle
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"])
	{
		dispatch_once(&onceToken, ^
		{
			_pluginController = [[MFPluginController alloc] initWithPluginBundle:pluginBundle];
		});
    }
}

@end