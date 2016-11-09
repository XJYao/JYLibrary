//
//  XPickerView.h
//  JYLibrary
//
//  Created by XJY on 15/11/9.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPickerView;

@protocol XPickerViewDelegate <NSObject>

@optional
- (void)cancelPicker:(XPickerView *)pickerView;

- (void)selectPicker:(XPickerView *)pickerView withTitle:(NSString *)title atIndex:(NSInteger)atIndex;

@end

@interface XPickerView : UIView

@property (nonatomic, weak) id <XPickerViewDelegate> delegate;

@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSString *selectButtonTitle;

- (instancetype)initWithTitles:(NSArray *)titles onView:(UIView *)view;

- (void)setFrameWithX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width;

- (void)reloadData:(NSArray *)titles;

- (CGFloat)getPickerViewHeight;

- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;

- (void)selectRow:(NSInteger)row animated:(BOOL)animated;

@end
