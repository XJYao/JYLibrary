//
//  XTool.h
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XTool : NSObject

/**
 判断对象是否为空
 */
+ (BOOL)isObjectNull:(id)obj;

/**
 判断字符串是否为空
 */
+ (BOOL)isStringEmpty:(NSString *)str;

/**
 判断数组是否为空
 */
+ (BOOL)isArrayEmpty:(NSArray *)array;

/**
 判断字典是否为空
 */
+ (BOOL)isDictionaryEmpty:(NSDictionary *)dictionary;

/**
 判断Set是否为空
 */
+ (BOOL)isSetEmpty:(NSSet *)aSet;

/**
 判断IndexSet是否为空
 */
+ (BOOL)isIndexSetEmpty:(NSIndexSet *)indexSet;

/**
 判断NSData是否为空
 */
+ (BOOL)isDataEmpty:(NSData *)data;

/**
 判断NSURL是否为空
 */
+ (BOOL)isURLEmpty:(NSURL *)url;

/**
 判断类是否为空
 */
+ (BOOL)isClassNull:(Class)cls;

/**
 判断字符串是否相等
 */
+ (BOOL)isEqualFromString:(NSString *)fromString toString:(NSString *)toString;

/**
 获取当前时间
 */
+ (NSString *)getCurrentTime:(NSString *)dateFormat;

/**
 获取当前app版本
 */
+ (NSString *)getCurrentAppVersion;

/**
 检查邮箱是否合法
 */
+ (BOOL)isValidateEmail:(NSString *)email;

/**
 检查手机号是否合法
 */
+ (BOOL)isValidateMobile:(NSString *)mobileNum;

/**
 根据文字和字体获取label的大小
 */
+ (CGSize)labelSize:(NSString *)text font:(UIFont *)font;

/**
 根据文字和字体以及允许的最大大小获取label的大小
 */
+ (CGSize)labelSize:(NSString *)text font:(UIFont *)font maximumSize:(CGSize)maximumSize;

/**
 根据文字和字体以及宽度获取高度
 */
+ (CGFloat)heightForText:(NSString *)text font:(UIFont *)font width:(CGFloat)width;

/**
 根据文字,字体,宽度以及允许的最大高度获取高度
 */
+ (CGFloat)heightForText:(NSString *)text font:(UIFont *)font width:(CGFloat)width maxHeight:(CGFloat)maxHeight;

/**
 根据文字,字体,高度获取宽度
 */
+ (CGFloat)widthForText:(NSString *)text font:(UIFont *)font height:(CGFloat)height;

/**
 根据文字,字体,高度以及允许的最大宽度获取宽度
 */
+ (CGFloat)widthForText:(NSString *)text font:(UIFont *)font height:(CGFloat)height maxWidth:(CGFloat)maxWidth;

/**
 字符转字符串
 */
+ (NSString *)charToString:(char *)c;

/**
 判断app是否第一次运行
 */
+ (BOOL)appNotFirstLaunch;

/**
 获取App名称
 */
+ (NSString *)getAppName;

/**
 旋转指定角度
 */
+ (CGAffineTransform)rotationWithAngle:(CGFloat)angle;

/**
 获取屏幕分辨率
 */
+ (CGSize)getResolution;

/**
 根据分辨率选择启动图片名
 */
+ (NSString *)getLaunchImageName;

/**
 根据传入的文本, 属性名, 值来生成富文本
 */
+ (NSAttributedString *)attributeStringWithString:(NSString *)textString attributeTextRangesAndAttributeNamesAndValues:(NSValue *)rangeValue, ... NS_REQUIRES_NIL_TERMINATION;

+ (NSAttributedString *)attributeStringWithString:(NSString *)textString attributeTextsAndAttributeNamesAndValues:(NSString *)attributeText, ... NS_REQUIRES_NIL_TERMINATION;

/**
 拼接url
 */
+ (NSString *)urlWithMainUrl:(NSString *)mainUrl relativeUrl:(NSString *)relativeUrl;

/**
 获取数据中的关键字索引, NSNotFound表示不存在
 */
+ (NSInteger)getKeyIndexForData:(NSData *)data key:(NSString *)key;

/**
 从包头获取指定key的值
 */
+ (NSString *)getValueOnResponseHead:(NSData *)headData key:(NSString *)key;

/**
 从响应头获取编码
 */
+ (NSStringEncoding)getEncodingFromResponseHead:(NSData *)headData;

/**
 从Response获取编码
 */
+ (NSStringEncoding)getEncodingFromResponse:(NSHTTPURLResponse *)httpResponse;

/**
 从charset获取编码
 */
+ (NSStringEncoding)getEncodingWithCharset:(NSString *)charset;

/**
 设置是否允许锁屏
 */
+ (void)allowLockScreen:(BOOL)allow;

/**
 判断字符串是否全部由数字组成
 */
+ (BOOL)isDigit:(NSString *)string;

/**
 生成一个随机数，可输入范围（包含）
 */
+ (int)getRandomNumber:(int)from to:(int)to;

/**
 执行一个方法，传入方法名和参数
 */
+ (id)performSelectorFromString:(NSString *)aSelectorName withSender:(id)sender hasReturn:(BOOL)hasReturn;

+ (id)performSelectorFromString:(NSString *)aSelectorName withSendor:(id)sender withObject:(id)object hasReturn:(BOOL)hasReturn;

+ (id)performSelectorFromString:(NSString *)aSelectorName withSendor:(id)sender withObject:(id)object1 withObject:(id)object2 hasReturn:(BOOL)hasReturn;

/**
 执行一个方法，传入方法和参数
 */
+ (id)performSelector:(SEL)aSelector withSender:(id)sender hasReturn:(BOOL)hasReturn;

+ (id)performSelector:(SEL)aSelector withSendor:(id)sender withObject:(id)object hasReturn:(BOOL)hasReturn;

+ (id)performSelector:(SEL)aSelector withSendor:(id)sender withObject:(id)object1 withObject:(id)object2 hasReturn:(BOOL)hasReturn;

/**
 销毁对象
 */
+ (void)releaseObject:(id)anObject;

/**
 判断是否是URL
 */
+ (BOOL)isURL:(NSString *)URL;

/**
 如果URL不以http://或https://开头，则补上http://
 */
+ (NSString *)insertHTTPAtURLPrefixIfNotFound:(NSString *)URL;

@end
