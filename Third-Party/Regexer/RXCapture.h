//
//  RXCapture.h
//  Regexer
//
//  Created by Michaël Fortin on 2014-05-03.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RXCapture : NSObject

@property (readonly) NSRange range;
@property (readonly) NSString *text;

+ (instancetype)notFoundCapture;

- (id)initWithRange:(NSRange)range text:(NSString *)text;

@end