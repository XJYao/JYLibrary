//
//  XMacro.h
//  JYLibrary
//
//  Created by XJY on 16/7/30.
//  Copyright © 2016年 XJY. All rights reserved.
//

#ifndef XMacro_h
#define XMacro_h

#import <sys/time.h>
#import <objc/runtime.h>

/**
 调试输出
 */
#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#define NSLogMethod() NSLog(@"%s", __func__)
#else
#define NSLog(...)
#define NSLogMethod()
#endif

/**
 断言
 */
#ifdef DEBUG
#define XAssert(condition, desc) NSAssert(condition, desc)
#else
#define XAssert(condition, desc)
#endif

/**
 强制内联
 */
#define x_force_inline __inline__ __attribute__((always_inline))

/**
 用关联对象实现属性的setter和getter方法
 */
#define X_InsertObjectSetterAndGetterByAssociated(_binder_, _getter_, _setter_, _type_)      \
    -(void)_setter_ : (_type_)object {                                                       \
        [_binder_ willChangeValueForKey:@ #_getter_];                                        \
        objc_setAssociatedObject(_binder_, _cmd, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
        [_binder_ didChangeValueForKey:@ #_getter_];                                         \
    }                                                                                        \
    -(_type_)_getter_ {                                                                      \
        return objc_getAssociatedObject(_binder_, @selector(_setter_:));                     \
    }

#define X_InsertTypeSetterAndGetterByAssociated(_binder_, _getter_, _setter_, _type_)       \
    -(void)_setter_ : (_type_)object {                                                      \
        [_binder_ willChangeValueForKey:@ #_getter_];                                       \
        NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)];              \
        objc_setAssociatedObject(_binder_, _cmd, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
        [_binder_ didChangeValueForKey:@ #_getter_];                                        \
    }                                                                                       \
    -(_type_)_getter_ {                                                                     \
        _type_ cValue;                                                                      \
        NSValue *value = objc_getAssociatedObject(_binder_, @selector(_setter_:));          \
        [value getValue:&cValue];                                                           \
        return cValue;                                                                      \
    }

/**
 状态栏高度,根据系统版本决定.IOS7及以上,状态栏高度为20,否则为0
 */
#define statusBarHeight 20.0f
#define statusBarOriginY ((floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) ? ([UIApplication sharedApplication].isStatusBarHidden ? 0.0f : statusBarHeight) : 0.0f) //因为是宏替换,而且?的优先级比较低,因此需要加个括号保证?先执行
#define navigationBarHeight 44

/**
 tag的起始值
 */
#define initializeTag 1000

/**
 字体
 */
#define systemFontWithSize(fontSize) [UIFont systemFontOfSize:fontSize]
#define systemBoldFontWithSize(fontSize) [UIFont boldSystemFontOfSize:fontSize]

#define helveticaFontWithSize(fontSize) [UIFont fontWithName:@"Helvetica" size:fontSize]
#define helveticaBoldFontWithSize(fontSize) [UIFont fontWithName:@"Helvetica-Bold" size:fontSize]
#define helveticaObliqueFontWithSize(fontSize) [UIFont fontWithName:@"Helvetica-Oblique" size:fontSize]
#define helveticaBoldObliqueFontWithSize(fontSize) [UIFont fontWithName:@"Helvetica-BoldOblique" size:fontSize]

/**
 获取不定参数
 */
#define x_getMutableParams(firstParam, array)                                                              \
    {                                                                                                      \
        if (!array) {                                                                                      \
            array = [[NSMutableArray alloc] init];                                                         \
        }                                                                                                  \
        va_list objectsList;                                                                               \
        va_start(objectsList, firstParam);                                                                 \
        {                                                                                                  \
            for (id otherObject = firstParam; otherObject != nil; otherObject = va_arg(objectsList, id)) { \
                [array addObject:otherObject];                                                             \
            }                                                                                              \
        }                                                                                                  \
        va_end(objectsList);                                                                               \
    }

/**
 忽略performSelector警告
 */
#define SuppressPerformSelectorLeakWarning(Stuff)                           \
    _Pragma("clang diagnostic push")                                        \
        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
            Stuff;                                                          \
    _Pragma("clang diagnostic pop")

/**
 代码执行时间检测
 */
#ifdef DEBUG
static inline void XBenchmark(void (^block)(void), void (^complete)(double ms)) {
    struct timeval t0, t1;
    gettimeofday(&t0, NULL);
    block();
    gettimeofday(&t1, NULL);
    double ms = (double)(t1.tv_sec - t0.tv_sec) * 1e3 + (double)(t1.tv_usec - t0.tv_usec) * 1e-3;
    complete(ms);
}

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));
#endif

/**
 方法交换
 */
static inline void x_exchangeSelector(Class theClass, SEL firstSelector, SEL secondSelector) {
    Method firstMethod = class_getInstanceMethod(theClass, firstSelector);
    Method secondMethod = class_getInstanceMethod(theClass, secondSelector);
    method_exchangeImplementations(firstMethod, secondMethod);
}

static inline void x_exchangeSelectorFromDifferentClasses(Class theClass1, SEL selector1, Class theClass2, SEL selector2) {
    Method firstMethod = class_getInstanceMethod(theClass1, selector1);
    Method secondMethod = class_getInstanceMethod(theClass2, selector2);
    method_exchangeImplementations(firstMethod, secondMethod);
}

#define x_singleInstance()                         \
    +(instancetype)manager {                       \
        static id manager = nil;                   \
        static dispatch_once_t onceToken;          \
        dispatch_once(&onceToken, ^{               \
            manager = [[[self class] alloc] init]; \
        });                                        \
        return manager;                            \
    }

#endif /* XMacro_h */
