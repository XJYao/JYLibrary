//
//  XCurveInfo.m
//  XCurvesDrawer
//
//  Created by XJY on 16/5/25.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XCurveInfo.h"
#import "UIColor+XColor.h"
#import "XTool.h"
#import "NSArray+XArray.h"


@implementation XCurveInfo

- (instancetype)init {
    self = [super init];

    if (self) {
        _points = [NSMutableArray arrayWithCapacity:0];
        _color = nil;
        _width = 0;
        _allowModify = YES;
        _user = nil;
        _createDate = nil;
        _modificationDate = nil;
    }

    return self;
}

- (BOOL)isEqualTo:(XCurveInfo *)aCurve {
    if (!aCurve) {
        return NO;
    }
    if (self == aCurve) {
        return YES;
    }
    if (self.width != aCurve.width || self.allowModify != aCurve.allowModify) {
        return NO;
    }
    if (![XTool isEqualFromString:self.user toString:aCurve.user]) {
        return NO;
    }
    if (![self.createDate isEqualToDate:aCurve.createDate]) {
        return NO;
    }
    if (![self.modificationDate isEqualToDate:aCurve.modificationDate]) {
        return NO;
    }
    if ((self.points && !aCurve.points) || (!self.points && aCurve.points)) {
        return NO;
    }
    if (self.points && aCurve.points) {
        if (self.points.count != aCurve.points.count) {
            return NO;
        }
        for (NSInteger i = 0; i < self.points.count; i++) {
            CGPoint selfPoint = [[self.points x_objectAtIndex:i] CGPointValue];
            CGPoint aCurvePoint = [[aCurve.points x_objectAtIndex:i] CGPointValue];
            if (selfPoint.x != aCurvePoint.x ||
                selfPoint.y != aCurvePoint.y) {
                return NO;
            }
        }
    }
    if (self.color != aCurve.color) {
        NSArray *selfColorInfo = [UIColor getRGBFromColor:self.color];
        NSArray *aCurveColorInfo = [UIColor getRGBFromColor:aCurve.color];

        if ((selfColorInfo && !aCurveColorInfo) || (!selfColorInfo && aCurveColorInfo)) {
            return NO;
        }

        if (selfColorInfo && aCurveColorInfo) {
            if (selfColorInfo.count != aCurveColorInfo.count) {
                return NO;
            }
            for (NSInteger i = 0; i < selfColorInfo.count; i++) {
                CGFloat selfValue = [[selfColorInfo x_objectAtIndex:i] floatValue];
                CGFloat toCurveValue = [[aCurveColorInfo x_objectAtIndex:i] floatValue];
                if (selfValue != toCurveValue) {
                    return NO;
                }
            }
        }
    }
    return YES;
}

@end
