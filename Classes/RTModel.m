//
//  RTModel.m
//  Model
//
//  Created by lzhu on 7/14/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import "RTModel.h"
#import "RTModelUtility.h"

@implementation RTModel

- (instancetype) initWithJSON:(NSDictionary *)json {
    self = [super init];
    if(self) {
        [RTModelUtility updateModel:self withJSON:json];
    }
    return self;
}

- (NSDictionary*) JSONObject {
    return [RTModelUtility JSONObjectWithModel:self];
}

+ (Class) itemClassOfArrayWithKey:(NSString *)key {
    return nil;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        [RTModelUtility decodeModel:self withCoder:aDecoder];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [RTModelUtility encodeModel:self withcoder:aCoder];
}
@end
