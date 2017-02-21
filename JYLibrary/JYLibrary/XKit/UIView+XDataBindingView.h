//
//  UIView+XDataBindingView.h
//  JYLibrary
//
//  Created by XJY on 17/2/14.
//  Copyright © 2017年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (XDataBindingView)

/**
 当数据源更新时，将进入此block。
 */
@property (nonatomic, copy) void (^x_bindingDataChangedBlock)(UIView *view, id datasource, NSString *keyPath, id oldValue, id newValue);

/**
 添加数据绑定，对象+属性
 */
- (void)x_addBindingDatasource:(id)datasource keyPath:(NSString *)keyPath;

/**
 移除数据绑定
 */
- (void)x_removeBindingDatasource:(id)datasource keyPath:(NSString *)keyPath;

/**
 移除所有数据绑定，当不再需要数据绑定时调用该方法。
 */
- (void)removeAllBinding;

@end
