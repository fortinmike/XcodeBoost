//
//  MFSymbol.h
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-05-26.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MFSymbolType)
{
	MFSymbolTypeUnknown,
	MFSymbolTypeStringLiteral,
	MFSymbolTypeNumberLiteral,
	MFSymbolTypeSelector,
    MFSymbolTypeField,
    MFSymbolTypePropertyAccess
};

@interface MFSymbol : NSObject

@property (assign) MFSymbolType type;

@property (assign) NSRange range;
@property (copy) NSString *text;

@property (assign) NSRange matchRange;
@property (copy) NSString *matchText;

- (id)initWithType:(MFSymbolType)type matchRange:(NSRange)matchRange matchText:(NSString *)matchText;

@end