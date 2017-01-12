//
//  XClassInfo.h
//  JYLibrary
//
//  Created by XJY on 16/5/16.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

//#define _C_ATOM     '%'
//#define _C_VECTOR   '!'

typedef enum : char {
    XTypeCodeUnknown        =   _C_UNDEF,       //unknown type
    XTypeCodeChar           =   _C_CHR,         //char / int8 / BOOL
    XTypeCodeInt            =   _C_INT,         //int32
    XTypeCodeShort          =   _C_SHT,         //short / int16
    XTypeCodeLong           =   _C_LNG,         //long / is treated as a 32-bit quantity on 64-bit programs.
    XTypeCodeLongLong       =   _C_LNG_LNG,     //long long / int64
    XTypeCodeUChar          =   _C_UCHR,        //unsigned char / unsigned int8
    XTypeCodeUInt           =   _C_UINT,        //unsigned int
    XTypeCodeUShort         =   _C_USHT,        //unsigned short / unsigned int16
    XTypeCodeULong          =   _C_ULNG,        //unsigned long
    XTypeCodeULongLong      =   _C_ULNG_LNG,    //unsigned long long / unsigned int64
    XTypeCodeFloat          =   _C_FLT,         //float
    XTypeCodeDouble         =   _C_DBL,         //double
    XTypeCodeLongDouble     =   'D',            //long double
    XTypeCodeBool           =   _C_BOOL,        //a C++ bool or a C99 _Bool
    XTypeCodeVoid           =   _C_VOID,        //void
    XTypeCodeString         =   _C_CHARPTR,     //a character string (char *)
    XTypeCodeObject         =   _C_ID,          //an object (whether statically typed or typed id)
    XTypeCodeClass          =   _C_CLASS,       //class
    XTypeCodeSEL            =   _C_SEL,         //SEL
    XTypeCodeBit            =   _C_BFLD,        //bit num
    XTypeCodePointer        =   _C_PTR,         //pointer
    XTypeCodeArrayBegin     =   _C_ARY_B,       //array begin
    XTypeCodeArrayEnd       =   _C_ARY_E,       //array end
    XTypeCodeStructBegin    =   _C_STRUCT_B,    //struct begin
    XTypeCodeStructEnd      =   _C_STRUCT_E,    //struct end
    XTypeCodeUnionBegin     =   _C_UNION_B,     //union begin
    XTypeCodeUnionEnd       =   _C_UNION_E,     //union end
    
    XTypeCodeType           =   'T',            //type
    XTypeCodeVariable       =   'V',            //Instance variable
    
    XTypeCodeConst          =   _C_CONST,       //const
    XTypeCodeIn             =   'n',            //in
    XTypeCodeInout          =   'N',            //inout
    XTypeCodeOut            =   'o',            //out
    XTypeCodeBycopy         =   'O',            //bycopy
    XTypeCodeByref          =   'R',            //byref
    XTypeCodeOneway         =   'V',            //oneway
    
    XTypeCodeReadonly       =   'R',            //readonly
    XTypeCodeCopy           =   'C',            //copy
    XTypeCodeRetain         =   '&',            //retain
    XTypeCodeNonatomic      =   'N',            //nonatomic
    XTypeCodeCustomGetter   =   'G',            //getter G<name>
    XTypeCodeCustomSetter   =   'S',            //setter S<name>
    XTypeCodeDynamic        =   'D',            //@dynamic
    XTypeCodeWeak           =   'W',            //weak
}XTypeCode;

typedef NS_OPTIONS(NSUInteger, XEncodingType) {
    XEncodingTypeUnknown    =   0,
    XEncodingTypeChar,
    XEncodingTypeInt,
    XEncodingTypeShort,
    XEncodingTypeLong,
    XEncodingTypeLongLong,
    XEncodingTypeUChar,
    XEncodingTypeUInt,
    XEncodingTypeUShort,
    XEncodingTypeULong,
    XEncodingTypeULongLong,
    XEncodingTypeFloat,
    XEncodingTypeDouble,
    XEncodingTypeLongDouble,
    XEncodingTypeBool,
    XEncodingTypeVoid,
    XEncodingTypeString,
    XEncodingTypeObject,
    XEncodingTypeClass,
    XEncodingTypeSEL,
    XEncodingTypeArray,
    XEncodingTypeStruct,
    XEncodingTypeUnion,
    XEncodingTypeBit,
    XEncodingTypePointer,
    XEncodingTypeBlock,
    
    XEncodingTypeConst  = 1 << 8,
    XEncodingTypeIn     = 1 << 9,
    XEncodingTypeInout  = 1 << 10,
    XEncodingTypeOut    = 1 << 11,
    XEncodingTypeBycopy = 1 << 12,
    XEncodingTypeByref  = 1 << 13,
    XEncodingTypeOneway = 1 << 14,
    
    XEncodingTypeReadonly       = 1 << 16,
    XEncodingTypeCopy           = 1 << 17,
    XEncodingTypeRetain         = 1 << 18,
    XEncodingTypeWeak           = 1 << 19,
    XEncodingTypeNonatomic      = 1 << 20,
    XEncodingTypeDynamic        = 1 << 21,
    XEncodingTypeCustomGetter   = 1 << 22,
    XEncodingTypeCustomSetter   = 1 << 23,
};

//Ivar
@interface XIvarInfo : NSObject

@property (nonatomic, assign, readonly) Ivar ivar;
@property (nonatomic, copy, readonly)   NSString *name;
@property (nonatomic, assign, readonly) ptrdiff_t offset;
@property (nonatomic, copy, readonly)   NSString *typeEncoding;
@property (nonatomic, assign, readonly) XEncodingType type;

- (instancetype)initWithIvar:(Ivar)ivar;

@end

//Method
@interface XMethodInfo : NSObject

@property (nonatomic, assign, readonly) Method method;
@property (nonatomic, copy, readonly)   NSString *name;
@property (nonatomic, assign, readonly) SEL sel;
@property (nonatomic, assign, readonly) IMP imp;
@property (nonatomic, copy, readonly)   NSString *typeEncoding;
@property (nonatomic, copy, readonly)   NSString *returnTypeEncoding;
@property (nonatomic, assign, readonly) unsigned int numberOfArguments;
@property (nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings;

- (instancetype)initWithMethod:(Method)method;

@end

//Property
@interface XPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property;
@property (nonatomic, copy, readonly)   NSString *name;
@property (nonatomic, assign, readonly) XEncodingType type;
@property (nonatomic, copy, readonly)   NSString *typeEncoding;
@property (nonatomic, strong, readonly) NSString *ivarName;
@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, assign, readonly) SEL getter;
@property (nonatomic, assign, readonly) SEL setter;
@property (nonatomic, readonly)         const char *attributes;

- (instancetype)initWithProperty:(objc_property_t)property;

@end

//Protocol
@interface XProtocolInfo : NSObject

@property (nonatomic, assign, readonly) Protocol *protocol;
@property (nonatomic, copy, readonly)   NSString *name;
@property (nonatomic, strong, readonly) NSArray<XPropertyInfo *> *propertyInfos;
@property (nonatomic, strong, readonly) NSArray<XProtocolInfo *> *protocolInfos;

- (instancetype)initWithProtocol:(Protocol *)protocol;

@end

//Class
@interface XClassInfo : NSObject

@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, assign, readonly) Class superClass;
@property (nonatomic, assign, readonly) BOOL isMeta;
@property (nonatomic, assign, readonly) Class metaClass;
@property (nonatomic, copy, readonly)   NSString *name;
@property (nonatomic, assign, readonly) int version;
@property (nonatomic, assign, readonly) size_t instanceSize;
@property (nonatomic, strong, readonly) XClassInfo *superClassInfo;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, XIvarInfo *> *ivarInfos;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, XMethodInfo *> *methodInfos;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, XPropertyInfo *> *propertyInfos;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, XProtocolInfo *> *protocolInfos;

- (instancetype)initWithClass:(Class)cls;

@end

//Object
@interface XObjectInfo : NSObject

@property (nonatomic, strong, readonly) id object;
@property (nonatomic, assign, readonly) BOOL isClass;
@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, strong, readonly) XClassInfo *classInfo;

- (instancetype)initWithObject:(id)object;

@end
