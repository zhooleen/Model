//
//  RTModel.h
//  Model
//
//  Created by lzhu on 7/14/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RTModel <NSObject, NSCoding>

-(instancetype) initWithJSON:(NSDictionary*)json;

-(NSDictionary*) JSONObject;

@end

@interface RTModel : NSObject<RTModel>

-(instancetype) initWithJSON:(NSDictionary*)json;

-(NSDictionary*) JSONObject;

+ (Class) itemClassOfArrayWithKey:(NSString*)key;

@end
