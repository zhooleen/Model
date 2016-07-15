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

- (void) rt_setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"%@", key);
}

+ (void) load {
    SEL sel1 = @selector(setValue:forUndefinedKey:);
    SEL sel2 = @selector(rt_setValue:forUndefinedKey:);
    
    Method m1 = class_getInstanceMethod([self class], sel1);
    Method m2 = class_getInstanceMethod([self class], sel2);
    
    IMP imp1 = class_getMethodImplementation([self class], sel1);
    IMP imp2 = class_getMethodImplementation([self class], sel2);
    
    class_replaceMethod([self class], sel1, imp2, method_getTypeEncoding(m1));
    class_replaceMethod([self class], sel2, imp1, method_getTypeEncoding(m2));
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
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([RTTestModel2 class], &count);
    printf("-------- Property ----------\n");
    for(int index = 0; index < count; ++index) {
        objc_property_t property = properties[index];
        printf("%s\n", property_getName(property));
    }
    
    printf("\n-------- Var ----------\n");
    unsigned int varCount = 0;
    Ivar *vars = class_copyIvarList([RTTestModel2 class], &varCount);
    for(int index = 0; index < varCount; ++index) {
        Ivar var = vars[index];
        printf("%s\n", ivar_getName(var));
    }
    
    printf("\n-------- Method ----------\n");
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList([RTTestModel2 class], &methodCount);
    for(int index = 0; index < methodCount; ++index) {
        Method m = methods[index];
        printf("%s\n", sel_getName(method_getName(m)));
    }
    
    id data = [NSKeyedArchiver archivedDataWithRootObject:model2];
    
    RTTestModel2 *model3 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSDictionary *json2 = [model3 JSONObject];
    NSLog(@"%@", json2);
    
}

void TestModelProtocol() {
    NSDictionary *json1 = @{@"title":@"You are so nice!",
                            @"subtitle":@"You are so good!"};
    
    Class klass = [RTModelUtility generateClassForProtocol:@protocol(RTXXXModel)];
    
    Ivar var1 = class_getInstanceVariable(klass, "subtitle");
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(klass, &count);
    printf("-------- Property ----------\n");
    for(int index = 0; index < count; ++index) {
        objc_property_t property = properties[index];
        printf("%s\n", property_getName(property));
    }
    
    printf("\n-------- Var ----------\n");
    unsigned int varCount = 0;
    Ivar *vars = class_copyIvarList(klass, &varCount);
    for(int index = 0; index < varCount; ++index) {
        Ivar var = vars[index];
        printf("%s\n", ivar_getName(var));
    }
    
    printf("\n-------- Method ----------\n");
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(klass, &methodCount);
    for(int index = 0; index < methodCount; ++index) {
        Method m = methods[index];
        printf("%s\n", sel_getName(method_getName(m)));
    }
    
    id<RTXXXModel> model = [[klass alloc] initWithJSON:json1];
    
    NSDictionary *json2 = [model JSONObject];
    
    NSLog(@"%@", json2);
}
