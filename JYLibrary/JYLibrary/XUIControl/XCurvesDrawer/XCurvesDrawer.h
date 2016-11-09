//
//  XCurvesDrawer.h
//  XCurvesDrawer
//
//  Created by XJY on 16/5/25.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XCurveInfo;
@class XCurvesDrawer;

@protocol XCurvesDrawerDelegate <NSObject>

@optional
/**
 开始点击
 */
- (void)curvesDrawerBeginSelectCurve:(XCurvesDrawer *)drawer;

/**
 选中曲线
 param:aCurve 被选中的曲线；isCancel 是否是取消选择
 */
- (void)curvesDrawer:(XCurvesDrawer *)drawer selectedCurve:(XCurveInfo *)aCurve isCancel:(BOOL)isCancel;

/**
 点击结束
 */
- (void)curvesDrawerEndSelectCurve:(XCurvesDrawer *)drawer;

@end

@interface XCurvesDrawer : UIView

@property (nonatomic, weak) id <XCurvesDrawerDelegate> delegate;

@property (nonatomic, copy)   NSString *user;
@property (nonatomic, strong) UIColor *drawerColor;                    //默认颜色，默认黑色
@property (nonatomic, assign) CGFloat drawerWidth;                     //默认线条宽度，默认1
@property (nonatomic, strong, readonly) NSArray<XCurveInfo *> *curves;  //所有曲线
@property (nonatomic, strong, readonly) NSArray<XCurveInfo *> *selectedCurves;//被选中的曲线
@property (nonatomic, assign, readonly) BOOL hasChanged;                //当前有增加或修改或删除曲线

//drawerEnabled 和 curvesSelectionEnabled总是相反的！
@property (nonatomic, assign) BOOL drawerEnabled;           //画图开关
@property (nonatomic, assign) BOOL curvesSelectionEnabled;  //选择曲线开关

/**
 初始化时传入初始曲线
 */
- (instancetype)initWithCurves:(NSArray<XCurveInfo *> *)curves;

/**
 添加曲线
 */
- (void)addCurve:(XCurveInfo *)aCurve;

/**
 添加多条曲线
 */
- (void)addCurvesFromArray:(NSArray<XCurveInfo *> *)curves;

/**
 替换曲线
 */
- (BOOL)replaceCurve:(XCurveInfo *)target withCurve:(XCurveInfo *)replacement;

 /**
  替换多条曲线
  */
- (BOOL)replaceCurves:(NSArray<XCurveInfo *> *)targets withCurves:(NSArray<XCurveInfo *> *)replacements;

 /**
  替换所有的曲线
  */
- (BOOL)replaceAllCurves:(NSArray<XCurveInfo *> *)replacements;

/**
 检测是否能继续撤销
 */
- (BOOL)checkCanUndo;

/**
 检查是否能继续恢复
 */
- (BOOL)checkCanRecovery;

/**
 撤销
 返回YES表示成功
 返回NO表示不可再继续撤销
 */
- (BOOL)undo;

/**
 恢复
 返回YES表示成功
 返回NO表示不可再继续恢复
 */
- (BOOL)recovery;

/**
 生成图片
 */
- (UIImage *)generateImage;

/**
 清空曲线，除了不允许修改的曲线
 */
- (void)clearAllCurves;

/**
 清空画布，包括不允许修改的曲线
 */
- (void)clearCanvas;

/**
 删除指定曲线
 返回YES表示成功
 返回NO表示传入的参数为空或者曲线不允许删除
 */
- (BOOL)removeCurve:(XCurveInfo *)aCurve;

/**
 删除指定多条曲线
 返回YES表示成功
 返回NO表示传入的参数为空或者传入的所有曲线都不允许删除
 */
- (BOOL)removeCurves:(NSArray<XCurveInfo *> *)curves;

/**
 取消选中
 返回YES表示成功
 返回NO表示传入的参数为空或者该曲线并没有被选中
 */
- (BOOL)cancelSelectedCurve:(XCurveInfo *)aCurve;

/**
 取消选中
 */
- (void)cancelSelectedCurves;

/**
 绘图
 */
- (void)draw;

/**
 根据两点计算矩形区域
 offset: 在原始的rect基础上宽高都增加offset单位长度
 */
- (CGRect)rectForFirstPoint:(CGPoint)firstPoint secondPoint:(CGPoint)secondPoint offset:(CGFloat)offset;

@end
