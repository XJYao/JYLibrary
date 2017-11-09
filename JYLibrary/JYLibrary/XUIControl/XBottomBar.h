//
//  XBottomBar.h
//  XBottomBar
//
//  Created by XJY on 15-3-4.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XBottomBarAlignment) {
    XBottomBarAlignmentCenter = 0,
    XBottomBarAlignmentLeft
};


@interface XBottomBarModel : NSObject

@property (nonatomic, copy) NSString *text;           //default is @""
@property (nonatomic, strong) UIImage *normalImage;   //default is nil
@property (nonatomic, strong) UIImage *selectedImage; //default is nil
@property (nonatomic, strong) UIImage *disableImage;  //default is nil

@property (nonatomic, copy) NSString *normalImageUrl;   //default is nil
@property (nonatomic, copy) NSString *selectedImageUrl; //default is nil
@property (nonatomic, copy) NSString *disableImageUrl;  //default is nil

@property (nonatomic, assign) BOOL selected;       //default is NO
@property (nonatomic, copy) NSString *badgeNumber; //default is @""

@end

@protocol XBottomBarDelegate <NSObject>

@optional
- (void)bottomBarItemSelected:(XBottomBarModel *)model atIndex:(NSInteger)index;

@end


@interface XBottomBar : UIView

@property (nonatomic, weak) id<XBottomBarDelegate> delegate;
@property (nonatomic, assign) NSInteger maxItemsCountForRow; //default is 5
@property (nonatomic, assign) XBottomBarAlignment alignment;
@property (nonatomic, assign) NSInteger notChangeStateItemIndex; //default is NSNotFound
@property (nonatomic, strong) UIImage *leftArrowImage;           //default is nil
@property (nonatomic, strong) UIImage *rightArrowImage;          //default is nil
@property (nonatomic, strong) UIFont *itemFont;
@property (nonatomic, strong) UIColor *itemNormalColor;
@property (nonatomic, strong) UIColor *itemSelectedColor;
@property (nonatomic, strong) UIColor *itemDisableColor;
@property (nonatomic, assign) BOOL useNSURLConnection;

//在调用addItems之前设置以上属性!!!

/**
 添加按钮
 */
- (void)addItems:(NSArray *)itemsArray;

- (void)selectItemAtIndex:(NSInteger)atIndex;

- (void)setItemTitle:(NSString *)title atIndex:(NSInteger)index;

- (NSString *)getItemTitle:(NSInteger)index;

- (void)setItemEnableAtIndex:(NSInteger)index enable:(BOOL)enable;

- (void)setItemBadgeHiddenAtIndex:(NSInteger)index badgeHidden:(BOOL)hidden;

- (void)setItemBadgeHiddenWithTitle:(NSString *)title badgeHidden:(BOOL)hidden;

- (void)setItemBadgeTextAtIndex:(NSInteger)index badgeText:(NSString *)text;

- (void)setItemBadgeTextWithTitle:(NSString *)title badgeText:(NSString *)text;

- (NSString *)getItemBadgeTextAtIndex:(NSInteger)index;

- (NSString *)getItemBadgeTextWithTitle:(NSString *)title;

@end
