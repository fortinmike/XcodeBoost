//
//  CollectorBlockTypes.h
//  Collector
//
//  Created by Michaël Fortin on 2014-05-12.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#ifndef Collector_CollectorBlockTypes_h
#define Collector_CollectorBlockTypes_h

typedef void (^CollectorOperationBlock)(id object);
typedef BOOL (^CollectorConditionBlock)(id object);
typedef id (^CollectorValueBlock)(id object);
typedef NSNumber * (^CollectorNumberBlock)(id object);

#endif