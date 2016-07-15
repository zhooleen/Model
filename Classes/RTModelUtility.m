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
        free(properties);
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

static void RTModelSetter(id self, SEL cmd, id value) {
    NSString *name = NSStringFromSelector(cmd);
    name = [NSString stringWithFormat:@"%@%@", [[name substringWithRange:(NSRange){3,1}] lowercaseString], [name substringWithRange:(NSRange){4, name.length-5}]];
    Ivar var = class_getInstanceVariable([self class], [name UTF8String]);
    object_setIvar(self, var, value);
}

static id RTModelGetter(id self, SEL cmd) {
    NSString *name = [NSString stringWithFormat:@"%@", NSStringFromSelector(cmd)];
    Ivar var = class_getInstanceVariable([self class], [name UTF8String]);
    if(var) {
        return object_getIvar(self, var);
    } else {
        return nil;
    }
}

- (Class) generateClassForProtocol:(Protocol*)protocol {
    if(!protocol_conformsToProtocol(protocol, @protocol(RTModel))) {
        return nil;
    }
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
    Class klass = objc_getClass(protocol_getName(protocol));
    if(klass) {
        dispatch_semaphore_signal(self.semaphore);
        return klass;
    }
    
    klass = objc_allocateClassPair([RTModel class], protocol_getName(protocol), 0);
    NSAssert(klass != nil, @"");
    unsigned int count = 0;
    objc_property_t *properties = protocol_copyPropertyList(protocol, &count);
    for(int i = 0; i < count; ++i) {
        objc_property_t property = properties[i];
        unsigned int attrCount = 0;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
        const char *propertyName = property_getName(property);
        BOOL success = class_addProperty(klass, propertyName, attrs, attrCount);
        if(success) {
            NSUInteger size;
            NSUInteger alignment;
            NSGetSizeAndAlignment("*", &size, &alignment);
            success = class_addIvar(klass, propertyName, size, alignment, "*");
            if(success) {
                NSString *name = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
                SEL getterSel = NSSelectorFromString(name);
                class_addMethod(klass, getterSel, (IMP)RTModelGetter, "@@:");
                NSString *capital = [NSString stringWithFormat:@"set%@:", [name capitalizedString]];
                SEL setterSel = NSSelectorFromString(capital);
                class_addMethod(klass, setterSel, (IMP)RTModelSetter, "v@:@");
            } else {
                printf("Add var %s failed.\n", propertyName);
            }
        }
        free(attrs);
    }
    free(properties);
    objc_registerClassPair(klass);
    dispatch_semaphore_signal(self.semaphore);
    return klass;
}

+ (Class) generateClassForProtocol:(Protocol*)protocol {
    return [[RTModelUtility utility] generateClassForProtocol:protocol];
}

@end
