//
//  XTabBar.h
//  XTabBar
//
//  Created by XJY on 15-3-27.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XTabBarUpdateStateWay) {
    XTabBarUpdateStateWayDefault,    //setting when initialize or animation end
    XTabBarUpdateStateWayByClick,    //setting when run selectButton click event
    XTabBarUpdateStateWayByDragScroll//setting when run scrollViewWillBeginDragging
};

@protocol XTabBarDelegate <NSObject>

@optional
- (void)selectTab:(NSString *)title atIndex:(NSInteger)index;
- (void)pageEndScroll:(NSInteger)index title:(NSString *)title;

@end

@interface XTabBar : UIView

#pragma mark property

@property (nonatomic, weak) id <XTabBarDelegate> delegate;    //default is nil.

@property (nonatomic, assign) BOOL      bounces;                                    //default is YES
@property (nonatomic, assign) BOOL      showsHorizontalScrollIndicator;             //default is NO
@property (nonatomic, assign) NSInteger maxCountForTabsShown;                       //default is 3
@property (nonatomic, assign) NSInteger currentSelectedIndex;                       //default is 0
@property (nonatomic, assign) XTabBarUpdateStateWay currentTabBarUpdateStateWay;    //default is XTabBarUpdateStateWayDefault

@property (nonatomic, assign) CGFloat       separatorHeight;        //default is 2.0f
@property (nonatomic, strong) UIColor   *   separatorColor;         //default is white
@property (nonatomic, strong) UIFont    *   textNormalFont;         //default is systemFontOfSize 14
@property (nonatomic, strong) UIFont    *   textSelectedFont;       //default is systemFontOfSize 14
@property (nonatomic, strong) UIColor   *   textNormalColor;        //default is black
@property (nonatomic, strong) UIColor   *   textSelectedColor;      //default is blue
@property (nonatomic, strong) UIColor   *   tabLineColor;           //default is blue
@property (nonatomic, strong) UIImage   *   tabLineImage;           //default is nil
@property (nonatomic, assign) CGFloat       tabLineHeight;          //default is 1.5f
@property (nonatomic, strong) UIColor   *   badgeBackgroundColor;   //default is red
@property (nonatomic, strong) UIColor   *   badgeTextColor;         //default is white

@property (nonatomic, assign)   BOOL    showTabLine;        //default is YES
@property (nonatomic, assign)   BOOL    colorAnimated;      //default is YES
@property (nonatomic, assign)   BOOL    fontAnimated;       //default is YES

@property (nonatomic, assign)   double  tabLineImageDuration;//default is 0.5

#pragma mark method

- (instancetype)initWithTabs:(NSArray *)tabs;

- (instancetype)initWithFrame:(CGRect)frame tabs:(NSArray *)tabs;

- (void)addTabs:(NSArray *)tabs;

- (void)addTab:(NSString *)title;

- (void)removeAllTabs;

- (void)removeTabAtIndex:(NSInteger)atIndex;

- (void)removeTabForTitle:(NSString *)title;

- (void)selectTab:(NSInteger)index;

/**
 必须在didscroll方法里调用,翻页完成后会执行pageEndScroll代理
 */
- (void)adjustToSelectedTabWithScrollView:(UIScrollView *)scrollView beginOffsetX:(CGFloat)beginOffsetX endOffsetX:(CGFloat)endOffsetX;

- (void)updateTabBar;

- (void)setBadgeHidden:(BOOL)hidden forTitle:(NSString *)title;

- (void)setBadgeHidden:(BOOL)hidden atIndex:(NSInteger)index;

- (void)setBadgeTextForTitle:(NSString *)title badgeText:(NSString *)badgeText;

- (void)setBadgeTextAtIndex:(NSInteger)index badgeText:(NSString *)badgeText;

- (NSString *)getBadgeTextForTitle:(NSString *)title;

- (NSString *)getBadgeTextAtIndex:(NSInteger)index;

@end

