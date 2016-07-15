//
//  RTModelUtility.h
//  Model
//
//  Created by lzhu on 7/14/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "RTModel.h"

@interface RTModelUtility : NSObject

+ (void) updateModel:(RTModel*)model withJSON:(NSDictionary*)json;

+ (NSDictionary*) JSONObjectWithModel:(RTModel*)model;

+ (void) decodeModel:(RTModel*)model withCoder:(NSCoder*)coder;

+ (void) encodeModel:(RTModel*)model withcoder:(NSCoder*)coder;

/**
 return the subclass of RTModel
 */
+ (Class) generateClassForProtocol:(Protocol*)protocol;

@end
