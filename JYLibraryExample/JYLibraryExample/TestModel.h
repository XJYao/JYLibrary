//
//  TestModel.h
//  JYLibraryExample
//
//  Created by XJY on 16/10/11.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SubTestModel;

@interface TestModel : NSObject

@property (nonatomic, strong) id unknownObj;
@property (nonatomic, strong) SubTestModel *subTestModel;
@property (nonatomic, strong) NSArray *arr;
@property (nonatomic, strong) NSArray<SubTestModel *> *subTestModelArr;
@property (nonatomic, strong) NSMutableArray *mutableArr;
@property (nonatomic, strong) NSDictionary *dic;
@property (nonatomic, strong) NSMutableDictionary *mutableDic;
@property (nonatomic, strong) NSSet *set;
@property (nonatomic, strong) NSMutableSet *mutableSet;
@property (nonatomic, strong) NSCountedSet *countedSet;
@property (nonatomic, copy, readonly) NSString *str;
@property (nonatomic, copy) NSMutableString *mutableStr;
@property (nonatomic, copy) NSAttributedString *attributedStr;
@property (nonatomic, copy) NSMutableAttributedString *mutableAttributedStr;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, assign) int cInt;
@property (nonatomic, assign) unsigned int cUInt;
@property (nonatomic, assign) short cShort;
@property (nonatomic, assign) unsigned short cUShort;
@property (nonatomic, assign) long cLong;
@property (nonatomic, assign) unsigned long cULong;
@property (nonatomic, assign) long long cLongLong;
@property (nonatomic, assign) unsigned long long cULongLong;
@property (nonatomic, assign) char cChar;
@property (nonatomic, assign) BOOL ocBOOL;
@property (nonatomic, assign) bool cbool;
@property (nonatomic, assign) float cFloat;
@property (nonatomic, assign) double cDouble;
@property (nonatomic, assign) long double cLongDouble;
@property (nonatomic, assign) CGFloat cCGFloat;
@property (nonatomic, assign) NSInteger cInteger;
@property (nonatomic, assign) NSUInteger cUInteger;

@property (nonatomic, copy, setter=setCustomName:) NSString *name;
@property (nonatomic, copy, getter=getCustomName) NSString *home;

@end

@interface SubTestModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *age;

@end
