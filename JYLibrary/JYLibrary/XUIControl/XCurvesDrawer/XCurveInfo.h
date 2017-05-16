//
//  XCurveInfo.h
//  XCurvesDrawer
//
//  Created by XJY on 16/5/25.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface XCurveInfo : NSObject

@property (nonatomic, strong) NSMutableArray<NSValue *> *points;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) BOOL allowModify;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, strong) NSDate *modificationDate;

- (BOOL)isEqualTo:(XCurveInfo *)aCurve;

@end
