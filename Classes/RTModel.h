//
//  RTModel.h
//  Model
//
//  Created by lzhu on 7/14/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTModel : NSObject<NSCoding>

-(instancetype) initWithJSON:(NSDictionary*)json;

-(NSDictionary*) JSONObject;

+ (Class) itemClassOfArrayWithKey:(NSString*)key;

@end
