//
//  RTTestModel.m
//  Model
//
//  Created by lzhu on 7/14/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import "RTTestModel.h"

@implementation RTTestModel1

@end

@implementation RTTestModel2

+ (Class) itemClassOfArrayWithKey:(NSString *)key {
    if([key isEqualToString:@"RTTestModel1"])
        return [RTTestModel1 class];
    return nil;
}

@end



void TestModel1() {
    NSDictionary *json = @{@"title":@"You are so nice!",
                           @"subtitle":@"You are so good!"};
    RTTestModel1 *model1 = [[RTTestModel1 alloc] initWithJSON:json];
    
    id data = [NSKeyedArchiver archivedDataWithRootObject:model1];
    
    RTTestModel2 *model3 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSDictionary *json2 = [model3 JSONObject];
    
    NSLog(@"%@", json2);
}


void TestModel2() {
    NSDictionary *json1 = @{@"title":@"You are so nice!",
                           @"subtitle":@"You are so good!"};
    NSArray *jsonArray = @[json1, json1, json1];
    
    NSDictionary *json = @{@"title":@"You are so nice!",
                           @"subtitle":@"You are so good!",
                           @"model":json1,
                           @"models":jsonArray};
    
    RTTestModel2 *model2 = [[RTTestModel2 alloc] initWithJSON:json];
    
    id data = [NSKeyedArchiver archivedDataWithRootObject:model2];
    
    RTTestModel2 *model3 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSDictionary *json2 = [model3 JSONObject];
    NSLog(@"%@", json2);
    
}
