//
//  NSObject+XModelParser.h
//  JYLibrary
//
//  Created by XJY on 16/10/11.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XModelParser <NSObject>

@optional
/**
 属性名映射
 */
- (NSDictionary<NSString *, //属性名
                NSString *> //映射名
       *)XModelParserModelPropertyNameMapper;

/**
 数组、集合里的元素类名映射
 */
- (NSDictionary<NSString *, //属性名
                NSString *> //元素类名
       *)XModelParserModelPropertyContainerClassMapper;

/**
 自定义转换属性
 return: YES 手动转换， NO 自动转换
 */
- (BOOL)XModelParserModelPropertyCustomTransform:(NSString *)propertyName value:(id)value;

/**
 默认值
 */
- (NSDictionary<NSString *, //属性名
                id>         //默认值
       *)XModelParserModelPropertyDefaultValue;

/**
 不参与转换成字典的属性名
 */
- (NSArray<NSString *> *)XModelParserModelPropertyNameDoNotConvertToDictionary;

/**
 要参与判断值是否相等的字段，不实现该方法则默认全部判断。
 */
- (NSArray<NSString *> *)XModelParserModelPropertyNamesForJudgeTheValueIsEqual;

@end


@interface NSObject (XModelParser)

/**
 传入字典返回model实例，失败返回nil.
 */
+ (id)x_modelFromDictionary:(NSDictionary *)dictionary;

/**
 传入json返回model实例，支持NSString、NSData，失败返回nil.
 */
+ (id)x_modelFromJson:(id)json;

/**
 传入集合返回model实例，支持NSArray、NSSet，失败返回nil.
 */
+ (id)x_modelsFromCollection:(id)collection;

/**
 指定model转换成字典
 */
+ (NSDictionary *)x_dictionaryFromModel:(id)model;

/**
 指定model数组转换成字典数组
 */
+ (NSArray<NSDictionary *> *)x_dictionariesFromModels:(NSArray *)models;

/**
 从model1拷贝值到model2，仅拷贝相同名称相同类型的属性，忽略readonly
 返回：YES：成功；NO：失败
 */
+ (BOOL)x_copyValueFrom:(id)from to:(id)to;

/**
 比较两个model的属性值是否相等
 */
+ (BOOL)x_isEqualFrom:(id)from to:(id)to;

/**
 传入字典，model自动赋值.
 返回：YES：成功；NO：失败
 */
- (BOOL)x_setValueFromDictionary:(NSDictionary *)dictionary;

/**
 传入json给model自动赋值，支持NSString、NSData.
 返回：YES：成功；NO：失败
 */
- (BOOL)x_setValueFromJson:(id)json;

/**
 转换成字典
 */
- (NSDictionary *)x_toDictionary;

/**
 清空值，如果有默认值则置为默认
 返回：YES：成功；NO：失败
 */
- (BOOL)x_clearValue;

/**
 浅拷贝值到指定model，仅拷贝相同名称相同类型的属性，忽略readonly
 返回：YES：成功；NO：失败
 */
- (BOOL)x_copyValueTo:(id)model;

/**
 判断与指定model的属性值是否相等
 */
- (BOOL)x_isEqualTo:(id)model;

@end
