//
//  RTTestModel.h
//  Model
//
//  Created by lzhu on 7/14/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTModelUtility.h"

#define RTImmutableProperty @property (strong, nonatomic, readonly)

@interface RTTestModel1 : RTModel

RTImmutableProperty NSString *title;

RTImmutableProperty NSString *subtitle;

@end


@interface RTTestModel2 : RTModel

RTImmutableProperty NSString *title;

RTImmutableProperty NSString *subtitle;

RTImmutableProperty RTTestModel1 *model;

RTImmutableProperty NSArray *models; //RTTestModel1

@end


@protocol RTXXXModel <RTModel>

RTImmutableProperty NSString *title;

RTImmutableProperty NSString *subtitle;

@end

FOUNDATION_EXTERN void TestModel1();

FOUNDATION_EXTERN void TestModel2();

FOUNDATION_EXTERN void TestModelProtocol();
