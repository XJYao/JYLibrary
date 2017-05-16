//
//  XClass.m
//  JYLibrary
//
//  Created by XJY on 16/11/9.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XClass.h"


@implementation XClass

Class NSObjectClass() {
    static Class _NSObjectClass;
    if (!_NSObjectClass || _NSObjectClass == Nil) {
        _NSObjectClass = [NSObject class];
    }
    return _NSObjectClass;
}

Class NSStringClass() {
    static Class _NSStringClass;
    if (!_NSStringClass || _NSStringClass == Nil) {
        _NSStringClass = [NSString class];
    }
    return _NSStringClass;
}

Class NSMutableStringClass() {
    static Class _NSMutableStringClass;
    if (!_NSMutableStringClass || _NSMutableStringClass == Nil) {
        _NSMutableStringClass = [NSMutableString class];
    }
    return _NSMutableStringClass;
}

Class NSAttributedStringClass() {
    static Class _NSAttributedStringClass;
    if (!_NSAttributedStringClass || _NSAttributedStringClass == Nil) {
        _NSAttributedStringClass = [NSAttributedString class];
    }
    return _NSAttributedStringClass;
}

Class NSArrayClass() {
    static Class _NSArrayClass;
    if (!_NSArrayClass || _NSArrayClass == Nil) {
        _NSArrayClass = [NSArray class];
    }
    return _NSArrayClass;
}

Class NSMutableArrayClass() {
    static Class _NSMutableArrayClass;
    if (!_NSMutableArrayClass || _NSMutableArrayClass == Nil) {
        _NSMutableArrayClass = [NSMutableArray class];
    }
    return _NSMutableArrayClass;
}

Class NSDictionaryClass() {
    static Class _NSDictionaryClass;
    if (!_NSDictionaryClass || _NSDictionaryClass == Nil) {
        _NSDictionaryClass = [NSDictionary class];
    }
    return _NSDictionaryClass;
}

Class NSMutableDictionaryClass() {
    static Class _NSMutableDictionaryClass;
    if (!_NSMutableDictionaryClass || _NSMutableDictionaryClass == Nil) {
        _NSMutableDictionaryClass = [NSMutableDictionary class];
    }
    return _NSMutableDictionaryClass;
}

Class NSSetClass() {
    static Class _NSSetClass;
    if (!_NSSetClass || _NSSetClass == Nil) {
        _NSSetClass = [NSSet class];
    }
    return _NSSetClass;
}

Class NSMutableSetClass() {
    static Class _NSMutableSetClass;
    if (!_NSMutableSetClass || _NSMutableSetClass == Nil) {
        _NSMutableSetClass = [NSMutableSet class];
    }
    return _NSMutableSetClass;
}

Class NSCountedSetClass() {
    static Class _NSCountedSetClass;
    if (!_NSCountedSetClass || _NSCountedSetClass == Nil) {
        _NSCountedSetClass = [NSCountedSet class];
    }
    return _NSCountedSetClass;
}

Class NSDataClass() {
    static Class _NSDataClass;
    if (!_NSDataClass || _NSDataClass == Nil) {
        _NSDataClass = [NSData class];
    }
    return _NSDataClass;
}

Class NSValueClass() {
    static Class _NSValueClass;
    if (!_NSValueClass || _NSValueClass == Nil) {
        _NSValueClass = [NSValue class];
    }
    return _NSValueClass;
}

Class NSNumberClass() {
    static Class _NSNumberClass;
    if (!_NSNumberClass || _NSNumberClass == Nil) {
        _NSNumberClass = [NSNumber class];
    }
    return _NSNumberClass;
}

@end
