//
//  XTabBar.m
//  XTabBar
//
//  Created by XJY on 15-3-27.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XTabBar.h"
#import "XTool.h"
#import "XScrollView.h"
#import "XAnimation.h"
#import "UILabel+XLabel.h"
#import "UIColor+XColor.h"
#import "NSArray+XArray.h"
#import "XMacro.h"

@interface XTabBar() <UIScrollViewDelegate> {
    XScrollView     *   tabBarScrollView;
    UIImageView     *   tabLineImageView;
    UIView          *   separator;
    
    NSMutableArray  *   tabsArray;
    
    CGFloat textNormalColorR;
    CGFloat textNormalColorG;
    CGFloat textNormalColorB;
    
    CGFloat textSelectedColorR;
    CGFloat textSelectedColorG;
    CGFloat textSelectedColorB;
    
    CGFloat textNormalAlpha;
    CGFloat textSelectedAlpha;
}

@end

@implementation XTabBar

#define tabLineImageViewTag (initializeTag - 1)

#define buttonTag(index)    ((index) * 2 + initializeTag)
#define badgeTag(index)     ((buttonTag(index)) + 1)

#define minBadgeSize 7
#define maxBadgeSize minBadgeSize*2

#pragma mark ---------- Public ----------

#pragma mark init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self addUI];
        [self updateFrame];
    }
    return self;
}

- (instancetype)initWithTabs:(NSArray *)tabs {
    self = [self init];
    if (self) {
        [self addTabs:tabs];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame tabs:(NSArray *)tabs {
    self = [self initWithFrame:frame];
    if (self) {
        [self addTabs:tabs];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateFrame];
}

#pragma mark tab

- (void)addTabs:(NSArray *)tabs {
    if (!tabsArray) {
        tabsArray = [[NSMutableArray alloc] init];
    }
    
    if (![XTool isArrayEmpty:tabs]) {
        for (NSInteger i = 0; i < tabs.count; i ++) {
            NSString *title = [tabs x_objectAtIndex:i];
            [self addTabToScrollView:title atIndex:tabsArray.count + i];
        }
        
        [tabsArray addObjectsFromArray:tabs];
    }
    
    [self updateTabLineImageViewState];
    [self setNeedsLayout];
    [self selectTab:_currentSelectedIndex];
}

- (void)addTab:(NSString *)title {
    if (!tabsArray) {
        tabsArray = [[NSMutableArray alloc] init];
    }
    
    [self addTabToScrollView:title atIndex:tabsArray.count];
    [tabsArray x_addObject:title];
    
    [self updateTabLineImageViewState];
    [self setNeedsLayout];
    [self selectTab:_currentSelectedIndex];
}

- (void)removeAllTabs {
    [tabsArray removeAllObjects];
    _currentSelectedIndex = NSNotFound;
    [self removeAllTabsFromScrollView];
    [self updateTabLineImageViewState];
    [self setNeedsLayout];
}

- (void)removeTabAtIndex:(NSInteger)atIndex {
    if (atIndex == NSNotFound || atIndex < 0 || atIndex >= tabsArray.count) {
        return;
    }
    
    if ([XTool isArrayEmpty:tabsArray]) {
        return;
    }
    
    if (_currentSelectedIndex != NSNotFound && _currentSelectedIndex >= 0) {
        if (tabsArray.count == 1) {
            _currentSelectedIndex = NSNotFound;
        } else {
            if ((atIndex < _currentSelectedIndex) ||
                (atIndex == _currentSelectedIndex && atIndex == tabsArray.count - 1)) {
                _currentSelectedIndex -= 1;
            }
        }
    }
    
    [tabsArray x_removeObjectAtIndex:atIndex];
    
    UIButton *removeButton = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(atIndex)];
    UILabel *removeBadge = (UILabel *)[tabBarScrollView viewWithTag:badgeTag(atIndex)];
    [removeButton removeFromSuperview];
    [removeBadge removeFromSuperview];
    
    if ([XTool isArrayEmpty:tabsArray]) {
        _currentSelectedIndex = NSNotFound;
        [self setNeedsLayout];
    } else {
        for (NSInteger i = atIndex; i < tabsArray.count; i++) {
            UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(i+1)];
            UILabel *badge = (UILabel *)[tabBarScrollView viewWithTag:badgeTag(i+1)];
            [button setTag:buttonTag(i)];
            [badge setTag:badgeTag(i)];
        }
        
        [self updateTabsFrame];
        [self updateTabLineImageViewFrame:0 animated:NO];
    }
    [self updateTabLineImageViewState];
}

- (void)removeTabForTitle:(NSString *)title {
    NSInteger index = [tabsArray indexOfObject:title];
    [self removeTabAtIndex:index];
}

- (void)selectTab:(NSInteger)index {
    if (index == NSNotFound || index < 0) {
        return;
    }
    [self changeTabButtonState:index changeColor:YES changeFont:YES];
    [self selectTabWithoutChangeState:index];
}

- (void)adjustToSelectedTabWithScrollView:(UIScrollView *)scrollView beginOffsetX:(CGFloat)beginOffsetX endOffsetX:(CGFloat)endOffsetX {
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    CGFloat scrollViewOffsetX = scrollView.contentOffset.x;
    
    if (scrollViewOffsetX < beginOffsetX || scrollViewOffsetX > endOffsetX) {
        return;
    }
    
    NSInteger index = scrollViewOffsetX / scrollViewWidth;
    
    if (_currentTabBarUpdateStateWay == XTabBarUpdateStateWayByDragScroll) {
        CGFloat scrollOffsetForCurrentView = scrollViewOffsetX - scrollViewWidth * index;
        NSInteger selectedTabIndex = 0;
        CGFloat offsetScale = scrollOffsetForCurrentView * 1.0 / scrollViewWidth;
        if (offsetScale >= 0.5) {
            selectedTabIndex = index + 1;
        } else {
            selectedTabIndex = index;
        }
        if (_currentSelectedIndex != NSNotFound && _currentSelectedIndex >= 0 && _currentSelectedIndex != selectedTabIndex) {
            [self changeTabButtonState:selectedTabIndex changeColor:!_colorAnimated changeFont:!_fontAnimated];
            [self selectTabWithoutChangeState:selectedTabIndex];
        }
        
        [self updateTabLineImageViewFrame:offsetScale animated:NO];
        if (_colorAnimated) {
            [self autoAdjustTabColor:offsetScale];
        }
        if (_fontAnimated) {
            [self autoAdjustFontSize:offsetScale];
        }
    }
    
    if ((_currentTabBarUpdateStateWay == XTabBarUpdateStateWayByClick ||
         _currentTabBarUpdateStateWay == XTabBarUpdateStateWayByDragScroll) &&
        scrollViewOffsetX == scrollViewWidth * index) {
        _currentTabBarUpdateStateWay = XTabBarUpdateStateWayDefault;
        if(_delegate && [_delegate respondsToSelector:@selector(pageEndScroll:title:)]) {
            [_delegate pageEndScroll:index title:[tabsArray x_objectAtIndex:index]];
        }
    }
}

- (void)updateTabBar {
    [self setNeedsLayout];
}

#pragma mark badge

- (void)setBadgeHidden:(BOOL)hidden forTitle:(NSString *)title {
    UILabel *badge = [self getBadgeForTitle:title];
    if (!badge) {
        return;
    }
    [badge setHidden:hidden];
}

- (void)setBadgeHidden:(BOOL)hidden atIndex:(NSInteger)index {
    NSString *title = [tabsArray x_objectAtIndex:index];
    [self setBadgeHidden:hidden forTitle:title];
}

- (void)setBadgeTextForTitle:(NSString *)title badgeText:(NSString *)badgeText {
    UILabel *badge = [self getBadgeForTitle:title];
    if (!badge) {
        return;
    }
    [badge setText:badgeText];
    [self updateBadgeFrame:badge];
}

- (void)setBadgeTextAtIndex:(NSInteger)index badgeText:(NSString *)badgeText {
    NSString *title = [tabsArray x_objectAtIndex:index];
    [self setBadgeTextForTitle:title badgeText:badgeText];
}

- (NSString *)getBadgeTextForTitle:(NSString *)title {
    UILabel *badge = [self getBadgeForTitle:title];
    if (!badge) {
        return @"";
    }
    return badge.text;
}

- (NSString *)getBadgeTextAtIndex:(NSInteger)index {
    NSString *title = [tabsArray x_objectAtIndex:index];
    return [self getBadgeTextForTitle:title];
}

#pragma mark ---------- Private ----------

#pragma mark method

#pragma mark init

- (void)initialize {
    [self setBackgroundColor:[UIColor whiteColor]];
    _delegate = nil;
    _bounces = YES;
    _showsHorizontalScrollIndicator = NO;
    _maxCountForTabsShown           = 3;
    _currentSelectedIndex           = NSNotFound;
    _currentTabBarUpdateStateWay    = XTabBarUpdateStateWayDefault;
    _separatorHeight                = 2.0f;
    
    _textNormalFont     = [UIFont systemFontOfSize:14];
    _textSelectedFont   = [UIFont systemFontOfSize:14];
    _textNormalColor    = [UIColor blackColor];
    _textSelectedColor  = [UIColor blueColor];
    _separatorColor     = [UIColor whiteColor];
    _tabLineColor       = [UIColor blueColor];
    _tabLineImage       = nil;
    _tabLineHeight      = 1.5f;
    
    _badgeBackgroundColor   = [UIColor redColor];
    _badgeTextColor         = [UIColor whiteColor];
    
    _showTabLine        = YES;
    _colorAnimated      = YES;
    _fontAnimated       = YES;
    
    _tabLineImageDuration = 0.5;
    
    tabsArray = [[NSMutableArray alloc] init];
    
    [self getColorRGB];
}

- (void)addUI {
    [self addSeparator];
    [self addTabBarScrollView];
    [self addTabLineImageView];
}

- (void)addSeparator {
    separator = [[UIView alloc] init];
    [separator setBackgroundColor:_separatorColor];
    [self addSubview:separator];
}

- (void)addTabBarScrollView {
    tabBarScrollView = [[XScrollView alloc] init];
    [tabBarScrollView setBackgroundColor:[UIColor clearColor]];
    [tabBarScrollView setBounces:_bounces];
    [tabBarScrollView setShowsHorizontalScrollIndicator:_showsHorizontalScrollIndicator];
    [tabBarScrollView setShowsVerticalScrollIndicator:NO];
    [tabBarScrollView setScrollsToTop:NO];
    [tabBarScrollView setDelaysContentTouches:NO];
    [tabBarScrollView setDelegate:self];
    [self addSubview:tabBarScrollView];
}

- (void)addTabLineImageView {
    tabLineImageView = [[UIImageView alloc] init];
    [tabLineImageView setTag:tabLineImageViewTag];
    [tabLineImageView setBackgroundColor:_tabLineColor];
    [tabLineImageView setImage:_tabLineImage];
    [tabBarScrollView addSubview:tabLineImageView];
}

- (void)addTabToScrollView:(NSString *)title atIndex:(NSInteger)atIndex {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    NSInteger buttonTag = buttonTag(atIndex);
    [button setTag:buttonTag];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:_textNormalFont];
    [button setTitleColor:_textNormalColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    [tabBarScrollView addSubview:button];
    
    UILabel *badge = [[UILabel alloc] init];
    NSInteger badgeTag = badgeTag(atIndex);
    [badge setTag:badgeTag];
    [badge setBackgroundColor:[UIColor clearColor]];
    [badge setTextColor:_badgeTextColor];
    [badge setTextAlignment:NSTextAlignmentCenter];
    [badge setFont:[UIFont fontWithName:@"Helvetica-Bold" size:8]];
    [badge.layer setBackgroundColor:[_badgeBackgroundColor CGColor]];
    [badge setHidden:YES];
    [tabBarScrollView addSubview:badge];
}

- (void)getColorRGB {
    if (_textNormalColor) {
        NSArray *normalRGB = [UIColor getRGBFromColor:_textNormalColor];
        
        if (normalRGB) {
            textNormalColorR = [[normalRGB x_objectAtIndex:0] floatValue];
            textNormalColorG = [[normalRGB x_objectAtIndex:1] floatValue];
            textNormalColorB = [[normalRGB x_objectAtIndex:2] floatValue];
        } else {
            textNormalColorR = -1;
            textNormalColorG = -1;
            textNormalColorB = -1;
        }
        
        textNormalAlpha = [UIColor getAlphaFromColor:_textNormalColor];
    }
    
    if (_textSelectedColor) {
        NSArray *selectedRGB = [UIColor getRGBFromColor:_textSelectedColor];
        
        if (selectedRGB) {
            textSelectedColorR = [[selectedRGB x_objectAtIndex:0] floatValue];
            textSelectedColorG = [[selectedRGB x_objectAtIndex:1] floatValue];
            textSelectedColorB = [[selectedRGB x_objectAtIndex:2] floatValue];
        } else {
            textSelectedColorR = -1;
            textSelectedColorG = -1;
            textSelectedColorB = -1;
        }
        
        textSelectedAlpha = [UIColor getAlphaFromColor:_textSelectedColor];
    }
}

- (void)selectTabWithoutChangeState:(NSInteger)index {
    if (index == NSNotFound || index < 0) {
        return;
    }
    
    [self adjustTabToCenter:index];
    
    _currentSelectedIndex = index;
    
    [self updateTabLineImageViewState];
    [self updateTabsFrame];
}

- (void)autoAdjustTabColor:(CGFloat)offsetScale {
    if (_currentSelectedIndex == NSNotFound || _currentSelectedIndex < 0) {
        return;
    }
    
    UIView *currentView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex)];
    if (!currentView || ![currentView isKindOfClass:[UIButton class]]) {
        return;
    }
    
    if (textNormalColorR < 0 || textNormalColorG < 0 || textNormalColorB < 0 || textNormalAlpha < 0 ||
        textSelectedColorR < 0 || textSelectedColorG < 0 || textSelectedColorB < 0 || textSelectedAlpha < 0) {
        return;
    }
    
    CGFloat recoverNewR = textSelectedColorR + (textNormalColorR - textSelectedColorR) * offsetScale;
    CGFloat recoverNewG = textSelectedColorG + (textNormalColorG - textSelectedColorG) * offsetScale;
    CGFloat recoverNewB = textSelectedColorB + (textNormalColorB - textSelectedColorB) * offsetScale;
    CGFloat recoverNewAlpha = textSelectedAlpha + (textNormalAlpha - textSelectedAlpha) * offsetScale;
    UIColor *recoverNewColor = [UIColor colorWithRed:recoverNewR green:recoverNewG blue:recoverNewB alpha:recoverNewAlpha];
    
    CGFloat selectNewR = textNormalColorR + (textSelectedColorR - textNormalColorR) * offsetScale;
    CGFloat selectNewG = textNormalColorG + (textSelectedColorG - textNormalColorG) * offsetScale;
    CGFloat selectNewB = textNormalColorB + (textSelectedColorB - textNormalColorB) * offsetScale;
    CGFloat selectNewAlpha = textNormalAlpha + (textSelectedAlpha - textNormalAlpha) * offsetScale;
    UIColor *selectNewColor = [UIColor colorWithRed:selectNewR green:selectNewG blue:selectNewB alpha:selectNewAlpha];
    
    UIButton *currentButton = (UIButton *)currentView;
    
    if (offsetScale < 0.5) {
        UIView *lastView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex + 1)];
        if (!lastView || ![lastView isKindOfClass:[UIButton class]]) {
            return;
        }
        UIButton *lastButton = (UIButton *)lastView;
        
        [currentButton setTitleColor:recoverNewColor forState:UIControlStateNormal];
        [lastButton setTitleColor:selectNewColor forState:UIControlStateNormal];
    } else {
        UIView *lastView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex - 1)];
        if (!lastView || ![lastView isKindOfClass:[UIButton class]]) {
            return;
        }
        UIButton *lastButton = (UIButton *)lastView;
        
        [currentButton setTitleColor:selectNewColor forState:UIControlStateNormal];
        [lastButton setTitleColor:recoverNewColor forState:UIControlStateNormal];
    }
}

- (void)autoAdjustFontSize:(CGFloat)offsetScale {
    if (_currentSelectedIndex == NSNotFound || _currentSelectedIndex < 0) {
        return;
    }
    
    if (!_textNormalFont || !_textSelectedFont) {
        return;
    }
    
    UIView *currentView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex)];
    if (!currentView || ![currentView isKindOfClass:[UIButton class]]) {
        return;
    }
    
    CGFloat recoverNewFontSize = _textSelectedFont.pointSize + (_textNormalFont.pointSize - _textSelectedFont.pointSize) * offsetScale;
    CGFloat selectNewFontSize = _textNormalFont.pointSize + (_textSelectedFont.pointSize - _textNormalFont.pointSize) * offsetScale;
    
    UIButton *currentButton = (UIButton *)currentView;
    
    if (offsetScale < 0.5) {
        UIView *lastView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex + 1)];
        if (!lastView || ![lastView isKindOfClass:[UIButton class]]) {
            return;
        }
        UIButton *lastButton = (UIButton *)lastView;
        
        [currentButton.titleLabel setFont:[UIFont fontWithName:_textSelectedFont.fontName size:recoverNewFontSize]];
        [lastButton.titleLabel setFont:[UIFont fontWithName:_textNormalFont.fontName size:selectNewFontSize]];
    } else {
        UIView *lastView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex - 1)];
        if (!lastView || ![lastView isKindOfClass:[UIButton class]]) {
            return;
        }
        UIButton *lastButton = (UIButton *)lastView;
        
        [currentButton.titleLabel setFont:[UIFont fontWithName:_textSelectedFont.fontName size:selectNewFontSize]];
        [lastButton.titleLabel setFont:[UIFont fontWithName:_textNormalFont.fontName size:recoverNewFontSize]];
    }
}

#pragma mark layout

- (void)updateFrame {
    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        return;
    }
    
    [self updateSeparatorFrame];
    [self updateTabBarScrollViewFrame];
    [self updateTabsFrame];
    [self updateTabLineImageViewFrame:0 animated:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}

- (void)updateSeparatorFrame {
    CGFloat separatorWidth = self.frame.size.width;
    CGFloat separatorX = 0;
    CGFloat separatorY = self.frame.size.height - _separatorHeight;
    
    CGRect separatorFrame = CGRectMake(separatorX, separatorY, separatorWidth, _separatorHeight);
    if (!CGRectEqualToRect(separator.frame, separatorFrame)) {
        [separator setFrame:separatorFrame];
    }
}

- (void)updateTabBarScrollViewFrame {
    CGFloat tabBarScrollViewWidth = self.frame.size.width;
    CGFloat tabBarScrollViewHeight = self.frame.size.height - separator.frame.size.height;
    CGFloat tabBarScrollViewX = 0;
    CGFloat tabBarScrollViewY = 0;
    
    CGRect tabBarScrollViewFrame = CGRectMake(tabBarScrollViewX, tabBarScrollViewY, tabBarScrollViewWidth, tabBarScrollViewHeight);
    if (!CGRectEqualToRect(tabBarScrollView.frame, tabBarScrollViewFrame)) {
        [tabBarScrollView setFrame:tabBarScrollViewFrame];
    }
}

- (void)updateTabLineImageViewFrame:(CGFloat)offsetScale animated:(BOOL)animated {
    if (_currentSelectedIndex == NSNotFound || _currentSelectedIndex < 0) {
        [self updateTabLineImageViewState];
        return;
    }
    
    if (!_showTabLine) {
        return;
    }
    
    UIView *currentView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex)];
    if (!currentView || ![currentView isKindOfClass:[UIButton class]]) {
        return;
    }
    
    CGFloat tabLineImageViewWidth = 0;
    CGFloat tabLineImageViewX = 0;
    CGFloat tabLineImageViewY = tabBarScrollView.frame.size.height - _tabLineHeight;
    
    UIButton *currentButton = (UIButton *)currentView;
    CGFloat currentButtonWidth = currentButton.frame.size.width;
    if (offsetScale < 0.5) {
        UIView *lastView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex + 1)];
        if (lastView && [lastView isKindOfClass:[UIButton class]]) {
            UIButton *lastButton = (UIButton *)lastView;
            CGFloat WidthDifference = lastButton.frame.size.width - currentButtonWidth;
            tabLineImageViewWidth = currentButtonWidth + WidthDifference * offsetScale;
        } else {
            tabLineImageViewWidth = currentButtonWidth;
        }
        tabLineImageViewX = currentButton.frame.origin.x + currentButtonWidth * offsetScale;
    } else {
        UIView *lastView = [tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex - 1)];
        if (lastView && [lastView isKindOfClass:[UIButton class]]) {
            UIButton *lastButton = (UIButton *)lastView;
            CGFloat lastButtonWidth = lastButton.frame.size.width;
            CGFloat WidthDifference = currentButtonWidth - lastButtonWidth;
            tabLineImageViewWidth = lastButtonWidth + WidthDifference * offsetScale;
            tabLineImageViewX = lastButton.frame.origin.x + lastButtonWidth * offsetScale;
        } else {
            return;
        }
    }
    
    if (animated && _tabLineImageDuration > 0) {
        [XAnimation beginAnimation:_tabLineImageDuration executingBlock:^{
            CGRect tabLineImageViewFrame = CGRectMake(tabLineImageViewX, tabLineImageViewY, tabLineImageViewWidth, _tabLineHeight);
            if (!CGRectEqualToRect(tabLineImageView.frame, tabLineImageViewFrame)) {
                [tabLineImageView setFrame:tabLineImageViewFrame];
            }
        }];
    } else {
        CGRect tabLineImageViewFrame = CGRectMake(tabLineImageViewX, tabLineImageViewY, tabLineImageViewWidth, _tabLineHeight);
        if (!CGRectEqualToRect(tabLineImageView.frame, tabLineImageViewFrame)) {
            [tabLineImageView setFrame:tabLineImageViewFrame];
        }
    }
}

- (void)updateTabsFrame {
    CGFloat tabBarScrollViewContentWidth = 0;
    
    if (![XTool isArrayEmpty:tabsArray]) {
        CGFloat halfOffsetBetweenTabs = [self calculateHalfOffsetBetweenTabs];
        
        CGFloat buttonWidth = 0;
        CGFloat buttonHeight = tabBarScrollView.frame.size.height - tabLineImageView.frame.size.height;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        for (NSInteger i = 0; i < tabsArray.count; i ++) {
            UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(i)];
            UILabel *badge = (UILabel *)[tabBarScrollView viewWithTag:badgeTag(i)];
            
            buttonWidth = [button.titleLabel labelSize].width + halfOffsetBetweenTabs * 2;
            
            CGRect buttonFrame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
            if (!CGRectEqualToRect(button.frame, buttonFrame)) {
                [button setFrame:buttonFrame];
            }
            
            CGFloat offset = 4;
            CGFloat badgeWidth = 0;
            
            if ([XTool isStringEmpty:badge.text]) {
                badgeWidth = minBadgeSize;
            } else {
                badgeWidth = maxBadgeSize;
            }
            CGFloat badgeHeight = badgeWidth;
            
            CGFloat badgeX = buttonX + buttonWidth - badgeWidth - offset;
            CGFloat badgeY = buttonY + offset;
            
            CGRect badgeFrame = CGRectMake(badgeX, badgeY, badgeWidth, badgeHeight);
            if (!CGRectEqualToRect(badge.frame, badgeFrame)) {
                [badge setFrame:badgeFrame];
            }
            
            CGFloat badgeCornerRadius = badgeWidth / 2.0;
            if (badge.layer.cornerRadius != badgeCornerRadius) {
                [badge.layer setCornerRadius:badgeCornerRadius];
            }
            
            buttonX = buttonX + buttonWidth;
            tabBarScrollViewContentWidth = buttonX;
        }
    }
    [tabBarScrollView setContentSize:CGSizeMake(tabBarScrollViewContentWidth, tabBarScrollView.frame.size.height)];
}

- (void)updateBadgeFrame:(UILabel *)badge {
    CGRect badgeFrame = badge.frame;
    
    CGFloat badgeRight = badgeFrame.origin.x + badgeFrame.size.width;
    
    if ([XTool isStringEmpty:badge.text]) {
        badgeFrame.size.width = minBadgeSize;
        badgeFrame.size.height = minBadgeSize;
    } else {
        badgeFrame.size.width = maxBadgeSize;
        badgeFrame.size.height = maxBadgeSize;
    }
    
    badgeFrame.origin.x = badgeRight - badgeFrame.size.width;
    
    if (!CGRectEqualToRect(badge.frame, badgeFrame)) {
        [badge setFrame:badgeFrame];
    }
    CGFloat badgeCornerRadius = badgeFrame.size.width / 2.0;
    if (badge.layer.cornerRadius != badgeCornerRadius) {
        [badge.layer setCornerRadius:badgeCornerRadius];
    }
}

//calculate half of offset between tabs for datas
- (CGFloat)calculateHalfOffsetBetweenTabs {
    CGFloat halfOffsetBetweenTabs = 0;
    CGFloat minHalfOffsetBetweenTabs = _textNormalFont.pointSize;
    CGFloat totalTitlesWidth = 0;
    CGFloat totalTabsWidth = 0;
    NSInteger index = 0;
    for (NSString *title in tabsArray) {
        CGSize labelSize;
        if (index == _currentSelectedIndex) {
            labelSize = [XTool labelSize:title font:_textSelectedFont];
        } else {
            labelSize = [XTool labelSize:title font:_textNormalFont];
        }
        totalTitlesWidth += labelSize.width;
        totalTabsWidth += (labelSize.width + minHalfOffsetBetweenTabs * 2);
        index++;
    }
    if (totalTabsWidth < tabBarScrollView.frame.size.width) {
        if (![XTool isArrayEmpty:tabsArray]) {
            if (tabsArray.count > _maxCountForTabsShown) {
                halfOffsetBetweenTabs = (tabBarScrollView.frame.size.width - totalTitlesWidth) * 1.0 / (_maxCountForTabsShown * 2);
            } else {
                halfOffsetBetweenTabs = (tabBarScrollView.frame.size.width - totalTitlesWidth) * 1.0 / (tabsArray.count * 2);
            }
        }
    } else {
        halfOffsetBetweenTabs = minHalfOffsetBetweenTabs;
    }
    return halfOffsetBetweenTabs;
}

- (void)updateTabLineImageViewState {
    if (!_showTabLine ||
        [XTool isArrayEmpty:tabsArray] ||
        _currentSelectedIndex == NSNotFound || _currentSelectedIndex < 0) {
        [tabLineImageView setHidden:YES];
    } else {
        [tabLineImageView setHidden:NO];
    }
}

//auto adjust selected tab to screen center
- (void)adjustTabToCenter:(NSInteger)index {
    if (index == NSNotFound || index < 0) {
        return;
    }
    
    UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(index)];
    CGFloat offsetBetweenButtonAndSuperLeft = (tabBarScrollView.frame.size.width - button.frame.size.width) / 2.0;
    CGFloat scrollViewContentOffsetX = button.frame.origin.x - offsetBetweenButtonAndSuperLeft;
    
    if (scrollViewContentOffsetX < 0) {
        scrollViewContentOffsetX = 0;
    } else if (scrollViewContentOffsetX > (tabBarScrollView.contentSize.width - tabBarScrollView.frame.size.width)) {
        scrollViewContentOffsetX = tabBarScrollView.contentSize.width - tabBarScrollView.frame.size.width;
    }
    
    CGPoint contentOffset = tabBarScrollView.contentOffset;
    contentOffset.x = scrollViewContentOffsetX;
    [tabBarScrollView setContentOffset:contentOffset animated:YES];
}

- (void)changeTabButtonState:(NSInteger)index changeColor:(BOOL)changeColor changeFont:(BOOL)changeFont {
    if (_currentSelectedIndex != NSNotFound && _currentSelectedIndex >= 0) {
        UIButton *currentButton = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex)];
        if (changeColor) {
            [currentButton setTitleColor:_textNormalColor forState:UIControlStateNormal];
        }
        if (changeFont) {
            [currentButton.titleLabel setFont:_textNormalFont];
        }
    }
    
    if (index != NSNotFound && index >= 0) {
        UIButton *selectedButton = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(index)];
        if (changeColor) {
            [selectedButton setTitleColor:_textSelectedColor forState:UIControlStateNormal];
        }
        if (changeFont) {
            [selectedButton.titleLabel setFont:_textSelectedFont];
        }
    }
}

- (void)removeAllTabsFromScrollView {
    for (UIView *subView in tabBarScrollView.subviews) {
        if (subView.tag != tabLineImageViewTag) {
            [subView removeFromSuperview];
        }
    }
}

#pragma mark badge

- (UILabel *)getBadgeForTitle:(NSString *)title {
    for (UIView *subView in tabBarScrollView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            if ([button.titleLabel.text isEqualToString:title]) {
                NSInteger badgeTag = button.tag + 1;
                UILabel *badge = (UILabel *)[tabBarScrollView viewWithTag:badgeTag];
                return badge;
            }
        }
    }
    return nil;
}

#pragma mark property

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    [tabBarScrollView setBounces:bounces];
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator {
    _showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
    [tabBarScrollView setShowsHorizontalScrollIndicator:_showsHorizontalScrollIndicator];
}

- (void)setMaxCountForTabsShown:(NSInteger)maxCountForTabsShown {
    _maxCountForTabsShown = maxCountForTabsShown;
    [self setNeedsLayout];
}

- (void)setCurrentSelectedIndex:(NSInteger)currentSelectedIndex {
    if (currentSelectedIndex == NSNotFound || currentSelectedIndex < 0) {
        return;
    }
    _currentSelectedIndex = currentSelectedIndex;
    [self selectTab:_currentSelectedIndex];
    [self updateTabLineImageViewFrame:0 animated:NO];
}

- (void)setSeparatorHeight:(CGFloat)separatorHeight {
    _separatorHeight = separatorHeight;
    [self setNeedsLayout];
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    [separator setBackgroundColor:separatorColor];
}

- (void)setTextNormalFont:(UIFont *)textNormalFont {
    _textNormalFont = textNormalFont;
    if (![XTool isArrayEmpty:tabsArray]) {
        for (NSInteger i = 0; i < tabsArray.count; i ++) {
            UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(i)];
            if (i != _currentSelectedIndex) {
                [button.titleLabel setFont:_textNormalFont];
            }
        }
    }
}

- (void)setTextSelectedFont:(UIFont *)textSelectedFont {
    _textSelectedFont = textSelectedFont;
    if (_currentSelectedIndex == NSNotFound || _currentSelectedIndex < 0) {
        return;
    }
    if (![XTool isArrayEmpty:tabsArray]) {
        UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex)];
        [button.titleLabel setFont:_textSelectedFont];
    }
}

- (void)setTextNormalColor:(UIColor *)textNormalColor {
    _textNormalColor = textNormalColor;
    
    [self getColorRGB];
    
    if (![XTool isArrayEmpty:tabsArray]) {
        for (NSInteger i = 0; i < tabsArray.count; i ++) {
            UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(i)];
            if (i != _currentSelectedIndex) {
                [button setTitleColor:_textNormalColor forState:UIControlStateNormal];
            }
        }
    }
}

- (void)setTextSelectedColor:(UIColor *)textSelectedColor {
    _textSelectedColor = textSelectedColor;
    
    [self getColorRGB];
    
    if (_currentSelectedIndex == NSNotFound || _currentSelectedIndex < 0) {
        return;
    }
    if (![XTool isArrayEmpty:tabsArray]) {
        UIButton *button = (UIButton *)[tabBarScrollView viewWithTag:buttonTag(_currentSelectedIndex)];
        [button setTitleColor:_textSelectedColor forState:UIControlStateNormal];
    }
}

- (void)setTabLineColor:(UIColor *)tabLineColor {
    _tabLineColor = tabLineColor;
    [tabLineImageView setBackgroundColor:_tabLineColor];
}

- (void)setTabLineImage:(UIImage *)tabLineImage {
    _tabLineImage = tabLineImage;
    [tabLineImageView setImage:tabLineImage];
}

- (void)setTabLineHeight:(CGFloat)tabLineHeight {
    _tabLineHeight = tabLineHeight;
    [self setNeedsLayout];
}

- (void)setBadgeBackgroundColor:(UIColor *)badgeBackgroundColor {
    _badgeBackgroundColor = badgeBackgroundColor;
    for (NSString *title in tabsArray) {
        UILabel *badge = [self getBadgeForTitle:title];
        [badge.layer setBackgroundColor:[_badgeBackgroundColor CGColor]];
    }
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor {
    _badgeTextColor = badgeTextColor;
    for (NSString *title in tabsArray) {
        UILabel *badge = [self getBadgeForTitle:title];
        [badge setTextColor:_badgeTextColor];
    }
}

- (void)setShowTabLine:(BOOL)showTabLine {
    _showTabLine = showTabLine;
    [self updateTabLineImageViewState];
    [self updateTabLineImageViewFrame:0 animated:NO];
}

#pragma mark TabBarEvent Method

- (void)selectButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger index = (button.tag - initializeTag) / 2;
    _currentTabBarUpdateStateWay = XTabBarUpdateStateWayByClick;
    if (_currentSelectedIndex != index) {
        [self selectTab:index];
        [self updateTabLineImageViewFrame:0 animated:YES];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(selectTab:atIndex:)]) {
        [_delegate selectTab:button.titleLabel.text atIndex:index];
    }
}

@end
