//
//  RTModelUtility.m
//  Model
//
//  Created by lzhu on 7/14/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import "RTModelUtility.h"

#import <objc/runtime.h>

@interface RTPropertyInfo : NSObject

@property (strong, nonatomic) NSString *name;

@property (assign, nonatomic) NSString *type;

@end @implementation RTPropertyInfo @end


@interface RTModelUtility()

@property (strong, nonatomic) NSMutableDictionary *classInfos;

@property (strong, nonatomic) dispatch_semaphore_t semaphore;

@end

@implementation RTModelUtility

- (instancetype) init {
    self = [super init];
    if(self) {
        _classInfos = [NSMutableDictionary dictionaryWithCapacity:32];
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

+ (instancetype) utility {
    static dispatch_once_t once;
    static RTModelUtility *obj;
    dispatch_once(&once, ^{
        obj = [[RTModelUtility alloc] init];
    });
    return obj;
}

- (NSArray*) propertyNamesOfClass:(Class)klass {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    NSString *klassName = [NSString stringWithCString:class_getName(klass) encoding:NSUTF8StringEncoding];
    NSArray *ret = self.classInfos[klassName];
    if(ret == nil) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(klass, &count);
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        for(int index = 0; index < count; ++index) {
            objc_property_t property = properties[index];
            RTPropertyInfo *info = [[RTPropertyInfo alloc] init];
            info.name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            info.type = [self typeForProperty:property];
            [array addObject:info];
        }
        ret = [array copy];
        self.classInfos[klassName] = ret;
    }
    dispatch_semaphore_signal(self.semaphore);
    return ret;
}

- (NSString*) typeForProperty:(objc_property_t)property {
    unsigned int attrCount;
    objc_property_attribute_t *attrList = property_copyAttributeList(property, &attrCount);
    NSString *typeName;
    for (NSInteger jdx = 0; jdx < attrCount; ++jdx) {
        objc_property_attribute_t attr = attrList[jdx];
        NSString *name = [NSString stringWithUTF8String:attr.name];
        if([@"T" isEqualToString:name]) {
            typeName = [NSString stringWithUTF8String:attr.value];
            typeName = [typeName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
            break;
        }
    }
    free(attrList);
    return typeName;
}

+ (void) updateModel:(RTModel *)model withJSON:(NSDictionary *)json {
    NSArray *propertyInfos = [[self utility] propertyNamesOfClass:[model class]];
    for(RTPropertyInfo *info in propertyInfos) {
        id value = json[info.name];
        if(value == nil) {
            continue;
        } else if([value isKindOfClass:[NSDictionary class]]) {
            Class klass = objc_getClass([info.type UTF8String]);
            if([klass isSubclassOfClass:[RTModel class]]) {
                RTModel *subModel = [[klass alloc] init];
                [self updateModel:subModel withJSON:value];
                value = subModel;
            }
        } else if([value isKindOfClass:[NSArray class]]) {
            Class klass = [[model class] itemClassOfArrayWithKey:info.name];
            if(klass != nil && [klass isSubclassOfClass:[RTModel class]]) {
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:[value count]];
                for(NSDictionary *dict in value) {
                    RTModel *subModel = [[klass alloc] init];
                    [self updateModel:subModel withJSON:dict];
                    [array addObject:subModel];
                }
                value = array;
            }
        }
        [model setValue:value forKey:info.name];
    }
}

+ (NSDictionary*) JSONObjectWithModel:(RTModel *)model {
    NSArray *propertyInfos = [[self utility] propertyNamesOfClass:[model class]];
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:propertyInfos.count];
    for(RTPropertyInfo *info in propertyInfos) {
        id value = [model valueForKey:info.name];
        if(value == nil) {
            continue;
        }
        if([value isKindOfClass:[RTModel class]]) {
            value = [self JSONObjectWithModel:value];
        } else if([value isKindOfClass:[NSArray class]]) {
            Class klass = [[model class] itemClassOfArrayWithKey:info.name];
            if(klass != nil && [klass isSubclassOfClass:[RTModel class]]) {
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:[value count]];
                for(RTModel *item in value) {
                    [array addObject:[self JSONObjectWithModel:item]];
                }
                value = array;
            }
        }
        json[info.name] = value;
    }
    return json;
}

+ (void) decodeModel:(RTModel*)model withCoder:(NSCoder*)coder {
    NSArray *propertyInfos = [[self utility] propertyNamesOfClass:[model class]];
    for(RTPropertyInfo *info in propertyInfos) {
        id value = [coder decodeObjectForKey:info.name];
        [model setValue:value forKey:info.name];
    }
}

+ (void) encodeModel:(RTModel*)model withcoder:(NSCoder*)coder {
    NSArray *propertyInfos = [[self utility] propertyNamesOfClass:[model class]];
    for(RTPropertyInfo *info in propertyInfos) {
        id value = [model valueForKey:info.name];
        [coder encodeObject:value forKey:info.name];
    }
}

@end
