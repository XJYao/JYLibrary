//
//  XClassInfo.m
//  JYLibrary
//
//  Created by XJY on 16/5/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XClassInfo.h"
#import "NSArray+XArray.h"
#import "NSDictionary+XDictionary.h"

XEncodingType getEncodingType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) {
        return XEncodingTypeUnknown;
    }
    size_t length = strlen(type);
    if (length <= 0) {
        return XEncodingTypeUnknown;
    }

    XEncodingType qualifier = XEncodingTypeUnknown;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case XTypeCodeConst: {
                qualifier |= XEncodingTypeConst;
                type++;
            } break;

            case XTypeCodeIn: {
                qualifier |= XEncodingTypeIn;
                type++;
            } break;

            case XTypeCodeInout: {
                qualifier |= XEncodingTypeInout;
                type++;
            } break;

            case XTypeCodeOut: {
                qualifier |= XEncodingTypeOut;
                type++;
            } break;

            case XTypeCodeBycopy: {
                qualifier |= XEncodingTypeBycopy;
                type++;
            } break;

            case XTypeCodeByref: {
                qualifier |= XEncodingTypeByref;
                type++;
            } break;

            case XTypeCodeOneway: {
                qualifier |= XEncodingTypeOneway;
                type++;
            } break;

            default: {
                prefix = false;
            } break;
        }
    }

    length = strlen(type);
    if (length <= 0) {
        return XEncodingTypeUnknown | qualifier;
    }

    switch (*type) {
        case XTypeCodeChar:
            return XEncodingTypeChar | qualifier;
        case XTypeCodeInt:
            return XEncodingTypeInt | qualifier;
        case XTypeCodeShort:
            return XEncodingTypeShort | qualifier;
        case XTypeCodeLong:
            return XEncodingTypeLong | qualifier;
        case XTypeCodeLongLong:
            return XEncodingTypeLongLong | qualifier;
        case XTypeCodeUChar:
            return XEncodingTypeUChar | qualifier;
        case XTypeCodeUInt:
            return XEncodingTypeUInt | qualifier;
        case XTypeCodeUShort:
            return XEncodingTypeUShort | qualifier;
        case XTypeCodeULong:
            return XEncodingTypeULong | qualifier;
        case XTypeCodeULongLong:
            return XEncodingTypeULongLong | qualifier;
        case XTypeCodeFloat:
            return XEncodingTypeFloat | qualifier;
        case XTypeCodeDouble:
            return XEncodingTypeDouble | qualifier;
        case XTypeCodeLongDouble:
            return XEncodingTypeLongDouble | qualifier;
        case XTypeCodeBool:
            return XEncodingTypeBool | qualifier;
        case XTypeCodeVoid:
            return XEncodingTypeVoid | qualifier;
        case XTypeCodeString:
            return XEncodingTypeString | qualifier;
        case XTypeCodeClass:
            return XEncodingTypeClass | qualifier;
        case XTypeCodeSEL:
            return XEncodingTypeSEL | qualifier;
        case XTypeCodeBit:
            return XEncodingTypeBit | qualifier;
        case XTypeCodePointer:
            return XEncodingTypePointer | qualifier;
        case XTypeCodeArrayBegin:
            return XEncodingTypeArray | qualifier;
        case XTypeCodeStructBegin:
            return XEncodingTypeStruct | qualifier;
        case XTypeCodeUnionBegin:
            return XEncodingTypeUnion | qualifier;
        case XTypeCodeObject: {
            if (length == 2 && *(type + 1) == XTypeCodeUnknown) {
                return XEncodingTypeBlock | qualifier;
            } else {
                return XEncodingTypeObject | qualifier;
            }
        }
        default:
            return XEncodingTypeUnknown | qualifier;
    }
}


@implementation XIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) {
        return nil;
    }

    self = [super init];
    if (!self) {
        return nil;
    }

    _ivar = ivar;

    const char *name = ivar_getName(ivar);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    _offset = ivar_getOffset(ivar);

    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type = getEncodingType(typeEncoding);
    }

    return self;
}

@end


@implementation XMethodInfo

- (instancetype)initWithMethod:(Method)method {
    if (!method) {
        return nil;
    }

    self = [super init];
    if (!self) {
        return nil;
    }

    _method = method;
    _sel = method_getName(method);
    _imp = method_getImplementation(method);

    const char *name = sel_getName(_sel);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }

    const char *typeEncoding = method_getTypeEncoding(method);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    }

    char *returnType = method_copyReturnType(method);
    if (returnType) {
        _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
        free(returnType);
    }

    _numberOfArguments = method_getNumberOfArguments(method);
    if (_numberOfArguments > 0) {
        NSMutableArray *argumentTypeEncodings = [[NSMutableArray alloc] initWithCapacity:_numberOfArguments];

        for (unsigned int index = 0; index < _numberOfArguments; index++) {
            char *argumentType = method_copyArgumentType(method, index);
            NSString *argumentTypeEncoding = argumentType ? [NSString stringWithUTF8String:argumentType] : @"";
            [argumentTypeEncodings x_addObject:argumentTypeEncoding];
            if (argumentType) {
                free(argumentType);
            }
        }

        _argumentTypeEncodings = argumentTypeEncodings;
    }

    return self;
}

@end


@implementation XPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) {
        return nil;
    }

    self = [super init];
    if (!self) {
        return nil;
    }

    _property = property;
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }

    _attributes = property_getAttributes(property);

    XEncodingType type = XEncodingTypeUnknown;

    unsigned int attributesCount = 0;

    objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributesCount);
    if (attributes && attributesCount > 0) {
        for (unsigned int i = 0; i < attributesCount; i++) {
            const char *attributeName = attributes[i].name;
            switch (attributeName[0]) {
                case XTypeCodeType: {
                    if (attributes[i].value) {
                        const char *attributeValue = attributes[i].value;
                        _typeEncoding = [NSString stringWithUTF8String:attributeValue];
                        type |= getEncodingType(attributeValue);
                        if ((type & 0xFF) == XEncodingTypeObject) {
                            size_t length = strlen(attributeValue);
                            if (length > 3) {
                                char name[length - 2];
                                name[length - 3] = '\0';
                                memcpy(name, attributeValue + 2, length - 3);
                                _cls = objc_getClass(name);
                            }
                        }
                    }

                } break;

                case XTypeCodeVariable: {
                    const char *attributeValue = attributes[i].value;
                    if (attributeValue) {
                        _ivarName = [NSString stringWithUTF8String:attributeValue];
                    }

                } break;

                case XTypeCodeReadonly: {
                    type |= XEncodingTypeReadonly;
                } break;

                case XTypeCodeCopy: {
                    type |= XEncodingTypeCopy;
                } break;

                case XTypeCodeRetain: {
                    type |= XEncodingTypeRetain;
                } break;

                case XTypeCodeWeak: {
                    type |= XEncodingTypeWeak;
                } break;

                case XTypeCodeNonatomic: {
                    type |= XEncodingTypeNonatomic;
                } break;

                case XTypeCodeDynamic: {
                    type |= XEncodingTypeDynamic;
                } break;

                case XTypeCodeCustomGetter: {
                    type |= XEncodingTypeCustomGetter;
                    const char *attributeValue = attributes[i].value;
                    if (attributeValue) {
                        _getter = NSSelectorFromString([NSString stringWithUTF8String:attributeValue]);
                    }
                } break;

                case XTypeCodeCustomSetter: {
                    type |= XEncodingTypeCustomSetter;
                    const char *attributeValue = attributes[i].value;
                    if (attributeValue) {
                        _setter = NSSelectorFromString([NSString stringWithUTF8String:attributeValue]);
                    }
                } break;

                default:
                    break;
            }
        }
    }
    if (attributes) {
        free(attributes);
        attributes = NULL;
    }

    _type = type;
    if (_name.length) {
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }

    return self;
}

@end


@implementation XProtocolInfo

- (instancetype)initWithProtocol:(Protocol *)protocol {
    if (!protocol) {
        return nil;
    }

    self = [super init];
    if (!self) {
        return nil;
    }

    _protocol = protocol;

    const char *name = protocol_getName(protocol);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }

    unsigned int propertyCount = 0;
    objc_property_t *propertyList = protocol_copyPropertyList(protocol, &propertyCount);
    if (propertyList && propertyCount > 0) {
        NSMutableArray *properties = [[NSMutableArray alloc] initWithCapacity:propertyCount];

        for (NSInteger i = 0; i < propertyCount; i++) {
            objc_property_t property = propertyList[i];
            XPropertyInfo *propertyInfo = [[XPropertyInfo alloc] initWithProperty:property];
            if (propertyInfo) {
                [properties x_addObject:propertyInfo];
            }
        }

        _propertyInfos = properties;
    }
    if (propertyList) {
        free(propertyList);
    }

    unsigned int protocolCount = 0;
    Protocol *__unsafe_unretained *protocolList = protocol_copyProtocolList(protocol, &protocolCount);
    if (protocolList && protocolCount > 0) {
        NSMutableArray *protocols = [[NSMutableArray alloc] initWithCapacity:protocolCount];

        for (NSInteger i = 0; i < protocolCount; i++) {
            Protocol *aProtocol = protocolList[i];
            XProtocolInfo *protocolInfo = [[XProtocolInfo alloc] initWithProtocol:aProtocol];
            if (protocolInfo) {
                [protocols x_addObject:protocolInfo];
            }
        }

        _protocolInfos = protocols;
    }
    if (protocolList) {
        free(protocolList);
    }

    return self;
}

@end


@implementation XClassInfo

- (instancetype)initWithClass:(Class)cls {
    _isMeta = NO;

    if (!cls || cls == Nil) {
        return nil;
    }

    self = [super init];
    if (!self) {
        return nil;
    }

    _cls = cls;
    _superClass = class_getSuperclass(cls);
    _isMeta = class_isMetaClass(cls);

    if (_isMeta) {
        _metaClass = cls;
        _name = NSStringFromClass(cls);
    } else {
        const char *name = class_getName(cls);
        _metaClass = objc_getMetaClass(name);
        _name = [NSString stringWithUTF8String:name];
    }

    _version = class_getVersion(cls);
    _instanceSize = class_getInstanceSize(cls);

    //class method
    unsigned int classMethodsCount = 0;
    Method *classMethods = class_copyMethodList(object_getClass(cls), &classMethodsCount);

    if (classMethods && classMethodsCount > 0) {
        NSMutableDictionary *methodInfos = [[NSMutableDictionary alloc] initWithCapacity:classMethodsCount];

        for (int i = 0; i < classMethodsCount; i++) {
            XMethodInfo *methodInfo = [[XMethodInfo alloc] initWithMethod:classMethods[i]];
            if (methodInfo && methodInfo.name) {
                [methodInfos x_setObject:methodInfo forKey:methodInfo.name];
            }
        }

        _classMethodInfos = methodInfos;
    }
    if (classMethods) {
        free(classMethods);
    }

    //instance method
    unsigned int instanceMethodsCount = 0;
    Method *instanceMethods = class_copyMethodList(cls, &instanceMethodsCount);

    if (instanceMethods && instanceMethodsCount > 0) {
        NSMutableDictionary *methodInfos = [[NSMutableDictionary alloc] initWithCapacity:instanceMethodsCount];

        for (int i = 0; i < instanceMethodsCount; i++) {
            XMethodInfo *methodInfo = [[XMethodInfo alloc] initWithMethod:instanceMethods[i]];
            if (methodInfo && methodInfo.name) {
                [methodInfos x_setObject:methodInfo forKey:methodInfo.name];
            }
        }

        _instanceMethodInfos = methodInfos;
    }
    if (instanceMethods) {
        free(instanceMethods);
    }

    //property
    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertiesCount);

    if (properties && propertiesCount > 0) {
        NSMutableDictionary *propertyInfos = [[NSMutableDictionary alloc] initWithCapacity:propertiesCount];

        for (int i = 0; i < propertiesCount; i++) {
            XPropertyInfo *propertyInfo = [[XPropertyInfo alloc] initWithProperty:properties[i]];
            if (propertyInfo && propertyInfo.name) {
                [propertyInfos x_setObject:propertyInfo forKey:propertyInfo.name];
            }
        }

        _propertyInfos = propertyInfos;
    }
    if (properties) {
        free(properties);
    }

    //ivar
    unsigned int ivarsCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarsCount);

    if (ivars && ivarsCount > 0) {
        NSMutableDictionary *ivarInfos = [[NSMutableDictionary alloc] initWithCapacity:ivarsCount];

        for (int i = 0; i < ivarsCount; i++) {
            XIvarInfo *ivarInfo = [[XIvarInfo alloc] initWithIvar:ivars[i]];
            if (ivarInfo && ivarInfo.name) {
                [ivarInfos x_setObject:ivarInfo forKey:ivarInfo.name];
            }
        }

        _ivarInfos = ivarInfos;
    }
    if (ivars) {
        free(ivars);
    }

    //protocols
    unsigned int protocolsCount = 0;
    Protocol *__unsafe_unretained *protocols = class_copyProtocolList(cls, &protocolsCount);

    if (protocols && protocolsCount > 0) {
        NSMutableDictionary *protocolInfos = [[NSMutableDictionary alloc] initWithCapacity:protocolsCount];

        for (int i = 0; i < protocolsCount; i++) {
            XProtocolInfo *protocolInfo = [[XProtocolInfo alloc] initWithProtocol:protocols[i]];
            if (protocolInfo && protocolInfo.name) {
                [protocolInfos x_setObject:protocolInfo forKey:protocolInfo.name];
            }
        }

        _protocolInfos = protocolInfos;
    }
    if (protocols) {
        free(protocols);
    }

    if (!_classMethodInfos) {
        _classMethodInfos = @{};
    }
    if (!_instanceMethodInfos) {
        _instanceMethodInfos = @{};
    }
    if (!_propertyInfos) {
        _propertyInfos = @{};
    }
    if (!_ivarInfos) {
        _ivarInfos = @{};
    }
    if (!_protocolInfos) {
        _protocolInfos = @{};
    }

    _superClassInfo = [[XClassInfo alloc] initWithClass:_superClass];

    return self;
}

@end


@implementation XObjectInfo

- (instancetype)initWithObject:(id)object {
    _isClass = NO;

    if (!object) {
        return nil;
    }

    self = [super init];
    if (!self) {
        return nil;
    }

    _object = object;
    _isClass = object_isClass(object);
    if (_isClass) {
        _cls = object;
    } else {
        _cls = object_getClass(object);
    }
    _classInfo = [[XClassInfo alloc] initWithClass:_cls];

    return self;
}

@end
