//
//  MFSymbol.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-05-26.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFSymbol.h"

@implementation MFSymbol

- (id)init
{
    self = [super init];
    if (self)
    {
        _type = MFSymbolTypeUnknown;
    }
    return self;
}

@end