//
//  NSObject+XModelParser.m
//  JYLibrary
//
//  Created by XJY on 16/10/11.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "NSObject+XModelParser.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "XTool.h"
#import "XClass.h"
#import "NSArray+XArray.h"
#import "NSDictionary+XDictionary.h"

@implementation NSObject (XModelParser)

+ (id)x_modelFromDictionary:(NSDictionary *)dictionary {
    if ([XTool isObjectNull:dictionary]) {
        return nil;
    }
    id object = [self x_objectInstance];
    BOOL success = [object x_setValueFromDictionary:dictionary];
    return success ? object : nil;
}

+ (id)x_modelFromJson:(id)json {
    if ([XTool isObjectNull:json]) {
        return nil;
    }
    id object = [self x_objectInstance];
    BOOL success = [object x_setValueFromJson:json];
    return success ? object : nil;
}

+ (id)x_modelsFromCollection:(id)collection {
    if ([XTool isObjectNull:collection]) {
        return nil;
    }
    Class cls;
    if ([collection isKindOfClass:NSArrayClass()]) {
        cls = NSMutableArrayClass();
    } else if ([collection isKindOfClass:NSSetClass()]) {
        cls = NSMutableSetClass();
    } else {
        return nil;
    }
    
    id models = [[cls alloc] init];
    
    if ([collection count] == 0) {
        return models;
    }
    
    for (id sub in collection) {
        if ([XTool isObjectNull:sub]) {
            continue;
        }
        
        id value = nil;
        if ([sub isKindOfClass:NSDictionaryClass()]) {
            value = [self x_modelFromDictionary:sub];
        } else if ([sub isKindOfClass:NSStringClass()] || [sub isKindOfClass:NSDataClass()]) {
            value = [self x_modelFromJson:sub];
        } else if ([sub isKindOfClass:NSArrayClass()] || [sub isKindOfClass:NSSetClass()]) {
            value = [self x_modelsFromCollection:sub];
        }
        if (![XTool isObjectNull:value]) {
            [models addObject:value];
        }
    }
    return models;
}

+ (NSDictionary *)x_dictionaryFromModel:(id)model {
    return [model x_toDictionary];
}

+ (NSArray<NSDictionary *> *)x_dictionariesFromModels:(NSArray *)models {
    if ([XTool isObjectNull:models]) {
        return nil;
    }
    if (models.count == 0) {
        return @[];
    }
    
    NSMutableArray *dictionaries = [NSMutableArray arrayWithCapacity:models.count];
    for (id model in models) {
        NSDictionary *dictionary = [model x_toDictionary];
        if (![XTool isObjectNull:dictionary]) {
            [dictionaries x_addObject:dictionary];
        }
    }
    return dictionaries;
}

+ (BOOL)x_copyValueFrom:(id)from to:(id)to {
    return [from x_copyValueTo:to];
}

+ (BOOL)x_isEqualFrom:(id)from to:(id)to {
    BOOL isFromNull = [XTool isObjectNull:from];
    BOOL isToNull = [XTool isObjectNull:to];
    
    if (isFromNull && isToNull) {
        return YES;
    } else if (isFromNull == (!isToNull)) {
        return NO;
    }
    
    return [from x_isEqualTo:to];
}

- (BOOL)x_setValueFromDictionary:(NSDictionary *)dictionary {
    return [NSObject x_setValueTo:self valueForName:dictionary typeForName:nil isCopy:NO];
}

- (BOOL)x_setValueFromJson:(id)json {
    BOOL isJsonNull = NO;
    if ([XTool isObjectNull:json]) {
        isJsonNull = YES;
    }
    
    if (!isJsonNull && [json isKindOfClass:NSStringClass()]) {
        id jsonObject = nil;
        if (![XTool isStringEmpty:json]) {
            NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
            NSError *jsonError = nil;
            jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonError];
        }
        return [self x_setValueFromDictionary:jsonObject];
        
    } else if (!isJsonNull && [json isKindOfClass:NSDataClass()]) {
        id jsonObject = nil;
        if (((NSData *)json).length > 0) {
            NSError *jsonError = nil;
            jsonObject = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:&jsonError];
        }
        
        return [self x_setValueFromDictionary:jsonObject];
    } else {
        
        return [self x_setValueFromDictionary:json];
    }
}

- (NSDictionary *)x_toDictionary {
    NSDictionary *valueForName = nil;
    
    BOOL getSuccess = [NSObject x_getValueForName:&valueForName typeForName:NULL from:self];
    if (!getSuccess) {
        return nil;
    }
    if (!valueForName) {
        return nil;
    }
    
    NSMutableDictionary *multableValueForName = [valueForName mutableCopy];
    
    //get property name do not convert to dictionary
    if ([[self class] instancesRespondToSelector:@selector(XModelParserModelPropertyNameDoNotConvertToDictionary)]) {
        NSArray *propertyNames = [(id)self XModelParserModelPropertyNameDoNotConvertToDictionary];
        for (NSString *name in propertyNames) {
            [multableValueForName removeObjectForKey:name];
        }
    }
    
    //get mapper
    if ([[self class] instancesRespondToSelector:@selector(XModelParserModelPropertyNameMapper)]) {
        NSDictionary *propertyNameMapper = [(id)self XModelParserModelPropertyNameMapper];
        
        for (NSString *key in propertyNameMapper.allKeys) {
            id value = [multableValueForName objectForKey:key];
            
            NSString *mapperName = [propertyNameMapper objectForKey:key];
            if (![XTool isObjectNull:value] && ![XTool isStringEmpty:mapperName]) {
                [multableValueForName removeObjectForKey:key];
                [multableValueForName x_setObject:value forKey:mapperName];
            }
        }
    }
    
    return multableValueForName;
}

- (BOOL)x_clearValue {
    return [self x_setValueFromDictionary:nil];
}

- (BOOL)x_copyValueTo:(id)model {
    
    NSDictionary *valueForName = nil;
    NSDictionary *typeForName = nil;
    
    BOOL getSuccess = [NSObject x_getValueForName:&valueForName typeForName:&typeForName from:self];
    if (!getSuccess) {
        return NO;
    }
    
    return [NSObject x_setValueTo:model valueForName:valueForName typeForName:typeForName isCopy:YES];
}

- (BOOL)x_isEqualTo:(id)model {
    if ([XTool isObjectNull:model]) {
        return NO;
    }
    if (model == self) {
        return YES;
    }
    
    if ([self isKindOfClass:NSNumberClass()] &&
        [model isKindOfClass:NSNumberClass()]) {
        
        if (![model isEqualToNumber:(id)self]) {
            return NO;
        }
        return [model compare:(id)self] == NSOrderedSame;
        
    } else if ([self isKindOfClass:NSStringClass()] &&
               [model isKindOfClass:NSStringClass()]) {
        
        return [model isEqualToString:(id)self];
        
    } else if ([self isKindOfClass:NSAttributedStringClass()] &&
               [model isKindOfClass:NSAttributedStringClass()]) {
        
        return [model isEqualToAttributedString:(id)self];
        
    } else if (([self isKindOfClass:NSArrayClass()] &&
                [model isKindOfClass:NSArrayClass()]) ||
               ([self isKindOfClass:NSSetClass()] &&
                [model isKindOfClass:NSSetClass()])) {
                   
                   if ([model count] != [(id)self count]) {
                       return NO;
                   }
                   for (id obj1 in model) {
                       BOOL foundSame = NO;
                       for (id obj2 in (id)self) {
                           if ([obj1 x_isEqualTo:obj2]) {
                               foundSame = YES;
                               break;
                           }
                       }
                       if (!foundSame) {
                           return NO;
                       }
                   }
                   
                   return YES;
                   
               } else if ([self isKindOfClass:NSDictionaryClass()] &&
                          [model isKindOfClass:NSDictionaryClass()]) {
                   if ([model count] != [(id)self count]) {
                       return NO;
                   }
                   for (NSString *key in [model allKeys]) {
                       id valueForSelf = [(id)self objectForKey:key];
                       id valueForModel = [model objectForKey:key];
                       
                       BOOL isValueForSelfNull = [XTool isObjectNull:valueForSelf];
                       BOOL isValueForModelNull = [XTool isObjectNull:valueForModel];
                       
                       if (isValueForSelfNull && isValueForModelNull) {
                           continue;
                       } else if (isValueForSelfNull == (!isValueForModelNull)) {
                           return NO;
                       }
                       if ([valueForSelf x_isEqualTo:valueForModel]) {
                           continue;
                       }
                       return NO;
                   }
                   return YES;
               }
    
    if (![self isKindOfClass:[model class]]) {
        return NO;
    }
    
    NSDictionary *valueForNameForSelf = nil;
    NSDictionary *typeForNameForSelf = nil;
    
    BOOL getSelfSuccess = [NSObject x_getValueForName:&valueForNameForSelf typeForName:&typeForNameForSelf from:self];
    if (!getSelfSuccess) {
        return NO;
    }
    
    NSDictionary *valueForNameForOther = nil;
    NSDictionary *typeForNameForOther = nil;
    
    BOOL getOtherSuccess = [NSObject x_getValueForName:&valueForNameForOther typeForName:&typeForNameForOther from:model];
    if (!getOtherSuccess) {
        return NO;
    }
    
    NSArray *propertyNamesForJudgeTheValueIsEqual = nil;
    if ([[model class] instancesRespondToSelector:@selector(XModelParserModelPropertyNamesForJudgeTheValueIsEqual)]) {
        propertyNamesForJudgeTheValueIsEqual = [(id)model XModelParserModelPropertyNamesForJudgeTheValueIsEqual];
        
        if (![XTool isArrayEmpty:propertyNamesForJudgeTheValueIsEqual]) {
            NSMutableDictionary *newValueForNameForSelf = [NSMutableDictionary dictionary];
            NSMutableDictionary *newValueForNameForOther = [NSMutableDictionary dictionary];
            
            for (NSString *name in propertyNamesForJudgeTheValueIsEqual) {
                if ([XTool isStringEmpty:name]) {
                    continue;
                }
                
                id valueForSelf = [valueForNameForSelf objectForKey:name];
                id valueForOther = [valueForNameForOther objectForKey:name];
                
                if (![XTool isObjectNull:valueForSelf]) {
                    [newValueForNameForSelf x_setObject:valueForSelf forKey:name];
                }
                if (![XTool isObjectNull:valueForOther]) {
                    [newValueForNameForOther x_setObject:valueForOther forKey:name];
                }
            }
            
            valueForNameForSelf = newValueForNameForSelf;
            valueForNameForOther = newValueForNameForOther;
        }
    }
    
    if (valueForNameForSelf.count != valueForNameForOther.count) {
        return NO;
    }
    
    NSMutableSet *namesSet = [NSMutableSet setWithArray:valueForNameForSelf.allKeys];
    [namesSet addObjectsFromArray:valueForNameForOther.allKeys];
    
    for (NSString *name in namesSet) {
        
        id valueForSelf = [valueForNameForSelf objectForKey:name];
        id valueForOther = [valueForNameForOther objectForKey:name];
        
        BOOL isValueForSelfNull = [XTool isObjectNull:valueForSelf];
        BOOL isValueForOtherNull = [XTool isObjectNull:valueForOther];
        
        if (isValueForSelfNull && isValueForOtherNull) {
            continue;
        } else if (isValueForSelfNull == (!isValueForOtherNull)) {
            return NO;
        }
        
        if ([valueForSelf x_isEqualTo:valueForOther]) {
            continue;
        }
        return NO;
    }
    
    return YES;
}

#pragma mark - help

+ (id)x_objectInstance {
    Class cls = [self class];
    id object = [[cls alloc] init];
    return object;
}

NSString *XModelParser_SettingName(NSString *gettingName) {
    NSString *setName = nil;
    if (gettingName.length == 1) {
        setName = [@"set" stringByAppendingString:[gettingName uppercaseString]];
    } else {
        setName = [[[gettingName substringToIndex:1] uppercaseString] stringByAppendingString:[gettingName substringFromIndex:1]];
        setName = [@"set" stringByAppendingString:setName];
    }
    setName = [setName stringByAppendingString:@":"];
    return setName;
}

+ (BOOL)x_setValueTo:(id)model valueForName:(NSDictionary *)valueForName typeForName:(NSDictionary *)typeForName isCopy:(BOOL)isCopy {
    
    if ([XTool isObjectNull:model]) {
        return NO;
    }
    
    if ([XTool isObjectNull:valueForName]) {
        valueForName = nil;
    } else {
        if (![valueForName isKindOfClass:NSDictionaryClass()]) {
            return NO;
        }
    }
    
    Class cls = [model class];
    
    //get mapper
    NSDictionary *propertyNameMapper = nil;
    if (!isCopy && [cls instancesRespondToSelector:@selector(XModelParserModelPropertyNameMapper)]) {
        propertyNameMapper = [(id)model XModelParserModelPropertyNameMapper];
    }
    
    //get container class mapper
    NSDictionary *propertyContainerClassMapper = nil;
    if (!isCopy && [cls instancesRespondToSelector:@selector(XModelParserModelPropertyContainerClassMapper)]) {
        propertyContainerClassMapper = [(id)model XModelParserModelPropertyContainerClassMapper];
    }
    
    //get readonly and custom setter
    NSMutableSet *propertyReadonly = [NSMutableSet set];
    NSMutableDictionary *propertyCustomSetterMapper = [NSMutableDictionary dictionary];
    
    //get default value
    NSDictionary *propertyDefaultValue = nil;
    if ([cls instancesRespondToSelector:@selector(XModelParserModelPropertyDefaultValue)]) {
        propertyDefaultValue = [(id)model XModelParserModelPropertyDefaultValue];
    }
    BOOL hasDefaultValue = ![XTool isDictionaryEmpty:propertyDefaultValue];
    
    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertiesCount);
    
    for (int i = 0; i < propertiesCount; i ++) {
        
        objc_property_t property = properties[i];
        
        unsigned int attributesCount = 0;
        objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributesCount);
        
        for (unsigned int j = 0; j < attributesCount; j ++) {
            const char *attributeName = attributes[j].name;
            switch (attributeName[0]) {
                case 'R': {//readonly
                    const char *attributeValue = attributes[j].value;
                    if (attributeValue) {
                        const char *c_propertyName = property_getName(property);
                        NSString *propertyName = [NSString stringWithUTF8String:c_propertyName];
                        
                        if (![XTool isStringEmpty:propertyName]) {
                            [propertyReadonly addObject:propertyName];
                        }
                    }
                } break;
                    
                case 'S': {//custom setter
                    const char *attributeValue = attributes[j].value;
                    if (attributeValue) {
                        const char *c_propertyName = property_getName(property);
                        NSString *propertyName = [NSString stringWithUTF8String:c_propertyName];
                        NSString *customSetterName = [NSString stringWithUTF8String:attributeValue];
                        
                        if (![XTool isStringEmpty:customSetterName] && ![XTool isStringEmpty:propertyName]) {
                            [propertyCustomSetterMapper setObject:customSetterName forKey:propertyName];
                        }
                    }
                } break;
                    
                default:
                    break;
            }
        }
        
        if (attributes) {
            free(attributes);
            attributes = NULL;
        }
    }
    if (properties) {
        free(properties);
        properties = NULL;
    }
    
    //set value
    unsigned int ivarsCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarsCount);
    
    for (unsigned int i = 0; i < ivarsCount; i ++) {
        Ivar ivar = ivars[i];
        if (!ivar) {
            continue;
        }
        
        //name
        const char *c_name = ivar_getName(ivar);
        if (!c_name) {
            continue;
        }
        NSString *name = [NSString stringWithUTF8String:c_name];
        name = [name substringFromIndex:1];
        if ([XTool isStringEmpty:name]) {
            continue;
        }
        
        if ([propertyReadonly containsObject:name]) {
            continue;
        }
        
        //custom tranform
        BOOL customTranform = NO;
        if (!isCopy && [cls instancesRespondToSelector:@selector(XModelParserModelPropertyCustomTransform:value:)]) {
            customTranform = [(id)model XModelParserModelPropertyCustomTransform:name value:valueForName];
        }
        if (customTranform) {
            continue;
        }
        
        //type
        const char *c_type = ivar_getTypeEncoding(ivar);
        if (!c_type) {
            continue;
        }
        NSString *type = [NSString stringWithUTF8String:c_type];
        if ([XTool isStringEmpty:type]) {
            continue;
        }
        
        if (isCopy) {
            NSString *realType = [typeForName objectForKey:name];
            if (![XTool isEqualFromString:realType toString:type]) {
                continue;
            }
        }
        
        //mapper
        NSString *mapperName = name;
        if (!isCopy) {
            NSString *mapper = [propertyNameMapper objectForKey:name];
            if (![XTool isStringEmpty:mapper]) {
                mapperName = mapper;
            }
        }
        
        //value
        id value = [valueForName objectForKey:mapperName];
        if ([XTool isObjectNull:value]) {
            value = nil;
        }
        
        //setter
        NSString *setterName = [propertyCustomSetterMapper objectForKey:name];
        if ([XTool isStringEmpty:setterName]) {
            setterName = XModelParser_SettingName(name);
        }
        SEL setter = NSSelectorFromString(setterName);
        
        switch (*c_type) {
            case _C_ID: {
                
                id newValue = nil;
                
                if (value) {
                    if (isCopy) {
                        
                        newValue = value;
                        
                    } else {
                        
                        if ([type isEqualToString:@"@\"NSMutableString\""] ||
                            [type isEqualToString:@"@\"NSAttributedString\""] ||
                            [type isEqualToString:@"@\"NSMutableAttributedString\""] ||
                            [type isEqualToString:@"@\"NSURL\""]) {
                            
                            newValue = [NSString stringWithFormat:@"%@", value];
                            
                            NSString *className = [type substringWithRange:NSMakeRange(2, type.length - 3)];
                            newValue = [[NSClassFromString(className) alloc] initWithString:newValue];
                            
                        } else if ([type isEqualToString:@"@\"NSArray\""] ||
                                   [type isEqualToString:@"@\"NSMutableArray\""] ||
                                   [type isEqualToString:@"@\"NSSet\""] ||
                                   [type isEqualToString:@"@\"NSMutableSet\""] ||
                                   [type isEqualToString:@"@\"NSCountedSet\""]) {
                            
                            if ([value isKindOfClass:NSArrayClass()] && ([value count] > 0)) {
                                
                                NSString *className = [type substringWithRange:NSMakeRange(2, type.length - 3)];
                                Class propertyClass = NSClassFromString(className);
                                
                                NSString *subClassName = [propertyContainerClassMapper objectForKey:name];
                                
                                if ([XTool isStringEmpty:subClassName]) {
                                    
                                    newValue = [[propertyClass alloc] initWithArray:value];
                                    
                                } else {
                                    
                                    Class subClass = NSClassFromString(subClassName);
                                    
                                    NSMutableArray *newValueArray = [NSMutableArray array];
                                    
                                    for (id subValue in (NSArray *)value) {
                                        if ([XTool isObjectNull:subValue]) {
                                            continue;
                                        }
                                        if ([subValue isKindOfClass:NSDictionaryClass()]) {
                                            
                                            id subObject = [[subClass alloc] init];
                                            [subObject x_setValueFromDictionary:subValue];
                                            [newValueArray addObject:subObject];
                                        } else {
                                            [newValueArray addObject:subValue];
                                        }
                                    }
                                    
                                    newValue = [[propertyClass alloc] initWithArray:newValueArray];
                                    
                                }
                            }
                            
                        } else {
                            
                            if ([type isEqualToString:@"@"] ||
                                [type isEqualToString:@"@\"NSNumber\""] ||
                                [type isEqualToString:@"@\"NSDictionary\""] ||
                                [type isEqualToString:@"@\"NSMutableDictionary\""]) {
                                
                                newValue = value;
                                
                            } else if ([type isEqualToString:@"@\"NSString\""]) {
                                
                                newValue = [NSString stringWithFormat:@"%@", value];
                                
                            } else {
                                NSString *className = [type substringWithRange:NSMakeRange(2, type.length - 3)];
                                
                                id subModel = [[NSClassFromString(className) alloc] init];
                                [subModel x_setValueFromDictionary:value];
                                
                                newValue = subModel;
                            }
                        }
                    }
                    
                } else if (hasDefaultValue) {
                    
                    newValue = [propertyDefaultValue objectForKey:name];
                    if ([XTool isObjectNull:newValue]) {
                        newValue = nil;
                    }
                }
                
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, setter, newValue);
                
            } break;
                
            case _C_CHR: {//char / int8 / BOOL
                
                char charValue = 0;
                if (value && [value isKindOfClass:NSNumberClass()]) {
                    charValue = [value charValue];
                } else if (value && [value isKindOfClass:NSStringClass()]) {
                    charValue = (char)[value intValue];
                } else if (hasDefaultValue) {
                    
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(charValue)]) {
                        charValue = [defaultValue charValue];
                    } else if ([defaultValue respondsToSelector:@selector(intValue)]) {
                        charValue = (char)[defaultValue intValue];
                    }
                }
                
                ((void (*)(id, SEL, char))(void *) objc_msgSend)((id)model, setter, charValue);
                
            } break;
                
            case _C_INT: {//int32
                
                int intValue = 0;
                if (value && ([value isKindOfClass:NSNumberClass()] || [value isKindOfClass:NSStringClass()])) {
                    intValue = [value intValue];
                } else if (hasDefaultValue) {
                    
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(intValue)]) {
                        intValue = [defaultValue intValue];
                    }
                }
                ((void (*)(id, SEL, int))(void *) objc_msgSend)((id)model, setter, intValue);
                
            } break;
                
            case _C_SHT: {//short / int16
                
                short shortValue = 0;
                if (value && [value isKindOfClass:NSNumberClass()]) {
                    shortValue = [value shortValue];
                } else if (value && [value isKindOfClass:NSStringClass()]) {
                    shortValue = (short)[value intValue];
                } else if (hasDefaultValue) {
                    
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(shortValue)]) {
                        shortValue = [defaultValue shortValue];
                    } else if ([defaultValue respondsToSelector:@selector(intValue)]) {
                        shortValue = (short)[defaultValue intValue];
                    }
                }
                ((void (*)(id, SEL, short))(void *) objc_msgSend)((id)model, setter, shortValue);
                
            } break;
                
            case _C_LNG: {//long
                
                long longValue = 0;
                if (value && [value isKindOfClass:NSNumberClass()]) {
                    longValue = [value longValue];
                } else if (value && [value isKindOfClass:NSStringClass()]) {
                    longValue = (long)[value longLongValue];
                } else if (hasDefaultValue) {
                    
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(longValue)]) {
                        longValue = [defaultValue longValue];
                    } else if ([defaultValue respondsToSelector:@selector(longLongValue)]) {
                        longValue = (long)[defaultValue longLongValue];
                    }
                }
                ((void (*)(id, SEL, long))(void *) objc_msgSend)((id)model, setter, longValue);
                
            } break;
                
            case _C_LNG_LNG: {//long long / int64
                
                long long longLongValue = 0;
                if (value && ([value isKindOfClass:NSNumberClass()] || [value isKindOfClass:NSStringClass()])) {
                    longLongValue = [value longLongValue];
                } else if (hasDefaultValue) {
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(longLongValue)]) {
                        longLongValue = [defaultValue longLongValue];
                    }
                }
                ((void (*)(id, SEL, long long))(void *) objc_msgSend)((id)model, setter, longLongValue);
                
            } break;
                
            case _C_UCHR: {//unsigned char / unsigned int8
                
                unsigned char uCharValue = 0;
                if (value && [value isKindOfClass:NSNumberClass()]) {
                    uCharValue = [value unsignedCharValue];
                } else if (value && [value isKindOfClass:NSStringClass()]) {
                    uCharValue = (unsigned char)[value intValue];
                } else if (hasDefaultValue) {
                    
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(unsignedCharValue)]) {
                        uCharValue = [defaultValue unsignedCharValue];
                    } else if ([defaultValue respondsToSelector:@selector(intValue)]) {
                        uCharValue = (unsigned char)[defaultValue intValue];
                    }
                }
                ((void (*)(id, SEL, unsigned char))(void *) objc_msgSend)((id)model, setter, uCharValue);
                
            } break;
                
            case _C_UINT: {//unsigned int
                
                unsigned int uIntValue = 0;
                if (value && [value isKindOfClass:NSNumberClass()]) {
                    uIntValue = [value unsignedIntValue];
                } else if (value && [value isKindOfClass:NSStringClass()]) {
                    uIntValue = (unsigned int)[value intValue];
                } else if (hasDefaultValue) {
                    
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(unsignedIntValue)]) {
                        uIntValue = [defaultValue unsignedIntValue];
                    } else if ([defaultValue respondsToSelector:@selector(intValue)]) {
                        uIntValue = (unsigned int)[defaultValue intValue];
                    }
                }
                ((void (*)(id, SEL, unsigned int))(void *) objc_msgSend)((id)model, setter, uIntValue);
                
            } break;
                
            case _C_USHT: {//unsigned short / unsigned int16
                
                unsigned short uShortValue = 0;
                if (value && [value isKindOfClass:NSNumberClass()]) {
                    uShortValue = [value unsignedShortValue];
                } else if (value && [value isKindOfClass:NSStringClass()]) {
                    uShortValue = (unsigned short)[value intValue];
                } else if (hasDefaultValue) {
                    
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(unsignedShortValue)]) {
                        uShortValue = [defaultValue unsignedShortValue];
                    } else if ([defaultValue respondsToSelector:@selector(intValue)]) {
                        uShortValue = (unsigned short)[defaultValue intValue];
                    }
                }
                ((void (*)(id, SEL, unsigned short))(void *) objc_msgSend)((id)model, setter, uShortValue);
                
            } break;
                
            case _C_ULNG: {//unsigned long
                
                unsigned long uLongValue = 0;
                if (value && [value isKindOfClass:NSNumberClass()]) {
                    uLongValue = [value unsignedLongValue];
                } else if (value && [value isKindOfClass:NSStringClass()]) {
                    uLongValue = (unsigned long)[value longLongValue];
                } else if (hasDefaultValue) {
                    
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(unsignedLongValue)]) {
                        uLongValue = [defaultValue unsignedLongValue];
                    } else if ([defaultValue respondsToSelector:@selector(longLongValue)]) {
                        uLongValue = (unsigned long)[defaultValue longLongValue];
                    }
                }
                ((void (*)(id, SEL, unsigned long))(void *) objc_msgSend)((id)model, setter, uLongValue);
                
            } break;
                
            case _C_ULNG_LNG: {//unsigned long long / unsigned int64
                
                unsigned long long uLongLongValue = 0;
                if (value && [value isKindOfClass:NSNumberClass()]) {
                    uLongLongValue = [value unsignedLongLongValue];
                } else if (value && [value isKindOfClass:NSStringClass()]) {
                    uLongLongValue = (unsigned long long)[value longLongValue];
                } else if (hasDefaultValue) {
                    
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(unsignedLongLongValue)]) {
                        uLongLongValue = [defaultValue unsignedLongLongValue];
                    } else if ([defaultValue respondsToSelector:@selector(longLongValue)]) {
                        uLongLongValue = (unsigned long long)[defaultValue longLongValue];
                    }
                }
                ((void (*)(id, SEL, unsigned long long))(void *) objc_msgSend)((id)model, setter, uLongLongValue);
                
            } break;
                
            case _C_FLT: {//float
                
                float floatValue = 0;
                if (value && ([value isKindOfClass:NSNumberClass()] || [value isKindOfClass:NSStringClass()])) {
                    floatValue = [value floatValue];
                } else if (hasDefaultValue) {
                    
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(floatValue)]) {
                        floatValue = [defaultValue floatValue];
                    }
                }
                ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)model, setter, floatValue);
                
            } break;
                
            case _C_DBL: {//double
                
                double doubleValue = 0;
                if (value && ([value isKindOfClass:NSNumberClass()] || [value isKindOfClass:NSStringClass()])) {
                    doubleValue = [value doubleValue];
                } else if (hasDefaultValue) {
                    
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(doubleValue)]) {
                        doubleValue = [defaultValue doubleValue];
                    }
                }
                ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)model, setter, doubleValue);
                
            } break;
                
            case 'D': {//long double
                
                long double longDoubleValue = 0;
                if (value && ([value isKindOfClass:NSNumberClass()] || [value isKindOfClass:NSStringClass()])) {
                    longDoubleValue = (long double)[value doubleValue];
                } else if (hasDefaultValue) {
                    
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(doubleValue)]) {
                        longDoubleValue = (long double)[defaultValue doubleValue];
                    }
                }
                ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)model, setter, longDoubleValue);
                
            } break;
                
            case _C_BOOL: {//a C++ bool or a C99 _Bool
                
                BOOL boolValue = NO;
                if (value && ([value isKindOfClass:NSNumberClass()] || [value isKindOfClass:NSStringClass()])) {
                    boolValue = [value boolValue];
                } else if (hasDefaultValue) {
                    
                    id defaultValue = [propertyDefaultValue objectForKey:name];
                    if ([defaultValue respondsToSelector:@selector(boolValue)]) {
                        boolValue = [defaultValue boolValue];
                    }
                }
                ((void (*)(id, SEL, BOOL))(void *) objc_msgSend)((id)model, setter, boolValue);
                
            } break;
                
            default:
                break;
        }
    }
    
    if (ivars) {
        free(ivars);
        ivars = NULL;
    }
    
    return YES;
}

+ (BOOL)x_getValueForName:(NSDictionary **)valueForName typeForName:(NSDictionary **)typeForName from:(id)model {
    if ([XTool isObjectNull:model]) {
        return NO;
    }
    
    Class cls = [model class];
    
    //get custom getter
    NSMutableDictionary *propertyCustomGetterMapper = [NSMutableDictionary dictionary];
    
    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertiesCount);
    
    for (int i = 0; i < propertiesCount; i ++) {
        
        objc_property_t property = properties[i];
        
        unsigned int attributesCount = 0;
        objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributesCount);
        
        for (unsigned int j = 0; j < attributesCount; j ++) {
            const char *attributeName = attributes[j].name;
            switch (attributeName[0]) {
                case 'G': {//custom getter
                    const char *attributeValue = attributes[j].value;
                    if (attributeValue) {
                        const char *c_propertyName = property_getName(property);
                        NSString *propertyName = [NSString stringWithUTF8String:c_propertyName];
                        NSString *customGetterName = [NSString stringWithUTF8String:attributeValue];
                        
                        if (![XTool isStringEmpty:customGetterName] && ![XTool isStringEmpty:propertyName]) {
                            [propertyCustomGetterMapper setObject:customGetterName forKey:propertyName];
                        }
                    }
                } break;
                    
                default:
                    break;
            }
        }
        
        if (attributes) {
            free(attributes);
            attributes = NULL;
        }
    }
    if (properties) {
        free(properties);
        properties = NULL;
    }
    
    //get value and type for property name
    NSMutableDictionary *valueForNameDictionary = nil;
    if (valueForName) {
        if (*valueForName) {
            valueForNameDictionary = [(*valueForName) mutableCopy];
        } else {
            valueForNameDictionary = [NSMutableDictionary dictionary];
        }
        *valueForName = valueForNameDictionary;
    } else {
        valueForNameDictionary = [NSMutableDictionary dictionary];
    }
    
    NSMutableDictionary *typeForNameDictionary = nil;
    if (typeForName) {
        if (*typeForName) {
            typeForNameDictionary = [(*typeForName) mutableCopy];
        } else {
            typeForNameDictionary = [NSMutableDictionary dictionary];
        }
        *typeForName = typeForNameDictionary;
    } else {
        typeForNameDictionary = [NSMutableDictionary dictionary];
    }
    
    unsigned int ivarsCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarsCount);
    for (unsigned int i = 0; i < ivarsCount; i ++) {
        Ivar ivar = ivars[i];
        if (!ivar) {
            continue;
        }
        
        //name
        const char *c_Name = ivar_getName(ivar);
        if (!c_Name) {
            continue;
        }
        NSString *name = [NSString stringWithUTF8String:c_Name];
        name= [name substringFromIndex:1];
        if ([XTool isStringEmpty:name]) {
            continue;
        }
        
        //type
        const char *c_Type = ivar_getTypeEncoding(ivar);
        if (!c_Type) {
            continue;
        }
        NSString *type = [NSString stringWithUTF8String:c_Type];
        if ([XTool isStringEmpty:type]) {
            continue;
        }
        
        [typeForNameDictionary setObject:type forKey:name];
        
        //getter
        NSString *getterName = [propertyCustomGetterMapper objectForKey:name];
        if ([XTool isStringEmpty:getterName]) {
            getterName = name;
        }
        SEL getter = NSSelectorFromString(getterName);
        
        switch (*c_Type) {
            case _C_ID: {
                id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                if (value) {
                    [valueForNameDictionary setObject:value forKey:name];
                }
            } break;
                
            case _C_CHR: {//char / int8 / BOOL
                char value = ((char (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
                
            case _C_INT: {//int32
                int value = ((int (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
                
            case _C_SHT: {//short / int16
                short value = ((short (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
                
            case _C_LNG: {//long
                long value = ((long (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
                
            case _C_LNG_LNG: {//long long / int64
                long long value = ((long long (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
                
            case _C_UCHR: {//unsigned char / unsigned int8
                unsigned char value = ((unsigned char (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
                
            case _C_UINT: {//unsigned int
                unsigned int value = ((unsigned int (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
                
            case _C_USHT: {//unsigned short / unsigned int16
                unsigned short value = ((unsigned short (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
                
            case _C_ULNG: {//unsigned long
                unsigned long value = ((unsigned long (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
                
            case _C_ULNG_LNG: {//unsigned long long / unsigned int64
                unsigned long long value = ((unsigned long long (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
                
            case _C_FLT: {//float
                float value = ((float (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
                
            case _C_DBL: {//double
                double value = ((double (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
                
            case 'D': {//long double
                double value = ((double (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
                
            case _C_BOOL:{//a C++ bool or a C99 _Bool
                BOOL value = ((BOOL (*)(id, SEL))(void *) objc_msgSend)((id)model, getter);
                [valueForNameDictionary setObject:@(value) forKey:name];
            } break;
        }
    }
    
    return YES;
}

@end
