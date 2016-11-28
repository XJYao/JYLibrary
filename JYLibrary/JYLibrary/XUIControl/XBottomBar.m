//
//  XBottomBar.m
//  XBottomBar
//
//  Created by XJY on 15-3-4.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XBottomBar.h"
#import "XScrollView.h"
#import "XTool.h"
#import "UILabel+XLabel.h"
#import "UIImageView+XWebImageView.h"

@implementation XBottomBarModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _text = @"";
        _normalImage = nil;
        _selectedImage = nil;
        _disableImage = nil;
        _normalImageUrl = nil;
        _selectedImageUrl = nil;
        _disableImageUrl = nil;
        _selected = NO;
        _badgeNumber = @"";
    }
    return self;
}

@end

@interface XBottomBar () <UIScrollViewDelegate> {
    XScrollView *bottomBarScrollView;
    UIView *separator;
    UIImageView *leftArrowImageView;
    UIImageView *rightArrowImageView;
    
    NSMutableArray *itemsArray;
}

@end

@implementation XBottomBar

#pragma mark public Method

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self addSeparator];
        [self addScrollView];
        [self addArrow];
        
        if (!CGRectEqualToRect(frame, CGRectZero)) {
            [self updateFrame];
        }
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateFrame];
}

- (void)addItems:(NSArray *)items {

    [itemsArray removeAllObjects];
    [itemsArray addObjectsFromArray:items];

    //移除scrollview中当前所有的子控件,否则会叠加
    for (UIView *view in bottomBarScrollView.subviews) {
        [view removeFromSuperview];
    }

    [self setLeftArrowHidden:YES RightArrowHidden:(itemsArray.count <= _maxItemsCountForRow)];

    NSInteger selectedIndex = NSNotFound;
    
    for (int i = 0; i < itemsArray.count; i++) {
        NSInteger tag = i + initializeTag;
        XBottomBarModel *bottomBarModel = [itemsArray x_objectAtIndex:i];
        
        if (bottomBarModel.selected) {
            selectedIndex = i;
        }

        UIView *itemView = [[UIView alloc] init];
        [itemView setUserInteractionEnabled:YES];
        [itemView setBackgroundColor:[UIColor clearColor]];
        [itemView setTag:tag];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClickEvent:)];
        [itemView addGestureRecognizer:tapGesture];
        [bottomBarScrollView addSubview:itemView];
        
        UIImageView *itemImageView = [[UIImageView alloc] init];
        [itemImageView setBackgroundColor:[UIColor clearColor]];
        [itemImageView setTag:(tag+itemsArray.count)];
        [itemImageView.imageManager setUseNSURLConnection:_useNSURLConnection];
        [itemView addSubview:itemImageView];
        [self setImage:itemImageView image:bottomBarModel.normalImage imageUrl:bottomBarModel.normalImageUrl];
        if (![XTool isStringEmpty:bottomBarModel.selectedImageUrl]) {
            [itemImageView.imageManager downloadImageWithURLString:bottomBarModel.selectedImageUrl progress:nil completion:nil];
        }
        if (![XTool isStringEmpty:bottomBarModel.disableImageUrl]) {
            [itemImageView.imageManager downloadImageWithURLString:bottomBarModel.disableImageUrl progress:nil completion:nil];
        }
        
        UILabel *itemLabel = [[UILabel alloc] init];
        [itemLabel setBackgroundColor:[UIColor clearColor]];
        [itemLabel setText:bottomBarModel.text];
        [itemLabel setFont:_itemFont];
        [itemLabel setTextColor:_itemNormalColor];
        [itemLabel setTextAlignment:NSTextAlignmentCenter];
        [itemLabel setTag:(tag+itemsArray.count*2)];
        [itemView addSubview:itemLabel];
        
        UILabel *badge = [[UILabel alloc] init];
        [badge setBackgroundColor:[UIColor clearColor]];
        [badge setText:@""];
        [badge setTextAlignment:NSTextAlignmentCenter];
        [badge setTextColor:[UIColor whiteColor]];
        [badge setFont:systemBoldFontWithSize(8)];
        [badge setHidden:YES];
        [badge setTag:(tag+itemsArray.count*3)];
        [badge.layer setMasksToBounds:YES];
        [badge.layer setBackgroundColor:[UIColor redColor].CGColor];
        [itemView addSubview:badge];
     
        if (![XTool isStringEmpty:bottomBarModel.badgeNumber] && ![bottomBarModel.badgeNumber isEqualToString:@"0"]) {
            [self setItemBadgeTextAtIndex:i badgeText:bottomBarModel.badgeNumber];
        }
    }
    
    [self updateFrame];
    
    if (selectedIndex != NSNotFound && selectedIndex >= 0) {
        [self selectItemAtIndexWithoutDelegate:selectedIndex];
    }
}

- (void)selectItemAtIndexWithoutDelegate:(NSInteger)atIndex {
    XBottomBarModel *bottomBarModel = [itemsArray x_objectAtIndex:atIndex];
    if (atIndex != _notChangeStateItemIndex) {
        if (bottomBarModel.selected) {
            //已选择该Item
        } else {
            
            for (NSInteger i = 0; i < itemsArray.count; i++) {
                XBottomBarModel *model = [itemsArray x_objectAtIndex:i];
                if (model.selected) {
                    UIView *selectedView = [bottomBarScrollView viewWithTag:i+initializeTag];
                    [self setItemState:selectedView isSelected:NO];
                }
            }
        }
        UIView *itemView = [bottomBarScrollView viewWithTag:atIndex + initializeTag];
        [self setItemState:itemView isSelected:YES];
    } else {
        //不要改变状态的Item
    }
}

- (void)selectItemAtIndex:(NSInteger)atIndex {
    [self selectItemAtIndexWithoutDelegate:atIndex];
    if(_delegate && [_delegate respondsToSelector:@selector(bottomBarItemSelected:atIndex:)]) {
        [_delegate bottomBarItemSelected:[itemsArray x_objectAtIndex:atIndex] atIndex:atIndex];
    }
}

- (NSString *)getItemTitle:(NSInteger)index {
    XBottomBarModel *bottomBarModel = [itemsArray x_objectAtIndex:index];
    NSString *itemTitle = bottomBarModel.text;
    return itemTitle;
}

- (void)setItemTitle:(NSString *)title atIndex:(NSInteger)index {
    XBottomBarModel *bottomBarModel = [itemsArray x_objectAtIndex:index];
    [bottomBarModel setText:title];
    
    UIView *itemView = [bottomBarScrollView viewWithTag:index + initializeTag];
    UILabel *itemLabel = (UILabel *)[itemView viewWithTag:(itemView.tag + itemsArray.count*2)];
    [itemLabel setText:title];
    [self updateItemsFrame];
}

- (void)setItemEnableAtIndex:(NSInteger)index enable:(BOOL)enable {
    XBottomBarModel *bottomBarModel = [itemsArray x_objectAtIndex:index];
    UIView *itemView = [bottomBarScrollView viewWithTag:index + initializeTag];
    UIImageView *itemImageView = (UIImageView *)[itemView viewWithTag:(itemView.tag + itemsArray.count)];
    UILabel *itemLabel = (UILabel *)[itemView viewWithTag:(itemView.tag + itemsArray.count*2)];
    [itemView setUserInteractionEnabled:enable];
    
    if (enable) {
        if (bottomBarModel.selected) {
            [self setImage:itemImageView image:bottomBarModel.selectedImage imageUrl:bottomBarModel.selectedImageUrl];
            if (itemLabel.textColor != _itemSelectedColor) {
                [itemLabel setTextColor:_itemSelectedColor];
            }
        } else {
            [self setImage:itemImageView image:bottomBarModel.normalImage imageUrl:bottomBarModel.normalImageUrl];
            if (itemLabel.textColor != _itemNormalColor) {
                [itemLabel setTextColor:_itemNormalColor];
            }
        }
    } else {
        [self setImage:itemImageView image:bottomBarModel.disableImage imageUrl:bottomBarModel.disableImageUrl];
        if (itemLabel.textColor != _itemDisableColor) {
            [itemLabel setTextColor:_itemDisableColor];
        }
    }
}

- (void)setItemBadgeHiddenAtIndex:(NSInteger)index badgeHidden:(BOOL)hidden {
    NSInteger tag = index + initializeTag;
    UIView *itemView = [bottomBarScrollView viewWithTag:tag];
    UILabel *badge = (UILabel *)[itemView viewWithTag:(tag + itemsArray.count*3)];
    if (hidden) {
        [badge setText:@""];
    }
    [badge setHidden:hidden];
    [self setItemBadgeFrame:badge];
}

- (void)setItemBadgeHiddenWithTitle:(NSString *)title badgeHidden:(BOOL)hidden {
    for (UIView *itemView in bottomBarScrollView.subviews) {
        NSString *itemTitle = [self getItemTitle:itemView.tag - initializeTag];
        if([itemTitle isEqualToString:title]) {
            [self setItemBadgeHiddenAtIndex:itemView.tag - initializeTag badgeHidden:hidden];
            return;
        }
    }
}

- (void)setItemBadgeTextAtIndex:(NSInteger)index badgeText:(NSString *)text {
    NSInteger tag = index + initializeTag;
    UIView *itemView = [bottomBarScrollView viewWithTag:tag];
    UILabel *badge = (UILabel *)[itemView viewWithTag:(tag + itemsArray.count*3)];
    [badge setText:text];
    [badge setHidden:NO];
    [self setItemBadgeFrame:badge];
}

- (void)setItemBadgeTextWithTitle:(NSString *)title badgeText:(NSString *)text {
    for (UIView *itemView in bottomBarScrollView.subviews) {
        NSString *itemTitle = [self getItemTitle:itemView.tag - initializeTag];
        if([itemTitle isEqualToString:title]) {
            [self setItemBadgeTextAtIndex:itemView.tag - initializeTag badgeText:text];
            return;
        }
    }
}

- (NSString *)getItemBadgeTextAtIndex:(NSInteger)index {
    NSInteger tag = index + initializeTag;
    UIView *itemView = [bottomBarScrollView viewWithTag:tag];
    UILabel *badge = (UILabel *)[itemView viewWithTag:(tag + itemsArray.count*3)];
    return badge.text;
}

- (NSString *)getItemBadgeTextWithTitle:(NSString *)title {
    NSString *itemBadgeText = @"";
    for (UIView *itemView in bottomBarScrollView.subviews) {
        NSString *itemTitle = [self getItemTitle:itemView.tag - initializeTag];
        if([itemTitle isEqualToString:title]) {
            itemBadgeText = [self getItemBadgeTextAtIndex:itemView.tag - initializeTag];
            break;
        }
    }
    return itemBadgeText;
}

#pragma mark private Method

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}

- (void)initialize {
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setAlpha:1.0f];
    
    itemsArray = [[NSMutableArray alloc] init];
    _maxItemsCountForRow = 5;
    _alignment = XBottomBarAlignmentLeft;
    _notChangeStateItemIndex = NSNotFound;
    _leftArrowImage = nil;
    _rightArrowImage = nil;
    _itemFont = systemFontWithSize(13);
    _itemNormalColor = [UIColor blackColor];
    _itemSelectedColor = [UIColor blueColor];
    _itemDisableColor = [UIColor lightGrayColor];
    _useNSURLConnection = NO;
    
}

- (void)addSeparator {
    separator = [[UIView alloc] init];
    [separator setBackgroundColor:[UIColor colorWithRed:221.0/255 green:221.0/255 blue:221.0/255 alpha:1]];
    [self addSubview:separator];
}

- (void)addScrollView {
    bottomBarScrollView = [[XScrollView alloc] init];
    [bottomBarScrollView setBackgroundColor:[UIColor clearColor]];
    [bottomBarScrollView setPagingEnabled:NO];
    [bottomBarScrollView setBounces:YES];
    [bottomBarScrollView setDelegate:self];
    [bottomBarScrollView setShowsHorizontalScrollIndicator:NO];
    [bottomBarScrollView setShowsVerticalScrollIndicator:NO];
    [bottomBarScrollView setDelaysContentTouches:NO];
    [self addSubview:bottomBarScrollView];
}

- (void)addArrow {
    leftArrowImageView = [[UIImageView alloc] init];
    [leftArrowImageView setImage:_leftArrowImage];
    [self addSubview:leftArrowImageView];

    rightArrowImageView = [[UIImageView alloc] init];
    [rightArrowImageView setImage:_rightArrowImage];
    [self addSubview:rightArrowImageView];
    
    [self setLeftArrowHidden:YES RightArrowHidden:YES];
}

- (void)setImage:(UIImageView *)imageView image:(UIImage *)image imageUrl:(NSString *)imageUrl {
    if ([XTool isStringEmpty:imageUrl]) {
        if (imageView.image != image) {
            [imageView setImage:image];
        }
    } else {
        
        __weak typeof(self) weak_self = self;
        
        [imageView x_setImageWithURLString:imageUrl placeholderImage:image progress:nil completion:^(BOOL success, UIImage *webImage, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weak_self updateItemsFrame];
            });
        }];
    }
}

- (void)updateFrame {
    CGFloat arrowImageViewWidth = 10;
    CGFloat separatorHeight = 0.5;
    [separator setFrame:CGRectMake(0, 0, self.frame.size.width, separatorHeight)];
    [bottomBarScrollView setFrame:CGRectMake(0, separatorHeight, self.frame.size.width, self.frame.size.height - separatorHeight)];
    
    CGFloat leftArrowImageViewWidth = 0;
    CGFloat leftArrowImageViewHeight = 0;
    CGFloat leftArrowImageViewX = 0;
    CGFloat leftArrowImageViewY = 0;
    
    if (leftArrowImageView.image) {
        CGFloat leftArrowImageScale = leftArrowImageView.image.size.width * 1.0 / leftArrowImageView.image.size.height;
        
        leftArrowImageViewWidth = arrowImageViewWidth;
        leftArrowImageViewHeight = leftArrowImageViewWidth * 1.0 / leftArrowImageScale;
        if (leftArrowImageViewHeight > self.frame.size.height - separatorHeight) {
            leftArrowImageViewHeight = self.frame.size.height - separatorHeight;
        }
        leftArrowImageViewX = 0;
        leftArrowImageViewY = separatorHeight + (self.frame.size.height - separatorHeight - leftArrowImageViewHeight) / 2.0;
    }
    [leftArrowImageView setFrame:CGRectMake(leftArrowImageViewX, leftArrowImageViewY, leftArrowImageViewWidth, leftArrowImageViewHeight)];
    
    CGFloat rightArrowImageViewWidth = 0;
    CGFloat rightArrowImageViewHeight = 0;
    CGFloat rightArrowImageViewX = 0;
    CGFloat rightArrowImageViewY = 0;
    
    if (rightArrowImageView.image) {
        CGFloat rightArrowImageScale = rightArrowImageView.image.size.width * 1.0 / rightArrowImageView.image.size.height;
        
        rightArrowImageViewWidth = arrowImageViewWidth;
        rightArrowImageViewHeight = rightArrowImageViewWidth * 1.0 / rightArrowImageScale;
        if (rightArrowImageViewHeight > self.frame.size.height - separatorHeight) {
            rightArrowImageViewHeight = self.frame.size.height - separatorHeight;
        }
        rightArrowImageViewX = self.frame.size.width - rightArrowImageViewWidth;
        rightArrowImageViewY = separatorHeight + (self.frame.size.height - separatorHeight - rightArrowImageViewHeight) / 2.0;
    }
    [rightArrowImageView setFrame:CGRectMake(rightArrowImageViewX, rightArrowImageViewY, rightArrowImageViewWidth, rightArrowImageViewHeight)];
    
    [self updateItemsFrame];
}

- (void)updateItemsFrame {
    if ([XTool isArrayEmpty:itemsArray]) {
        return;
    }
    
    CGFloat itemViewWidth = 0;
    CGFloat itemViewHeight = bottomBarScrollView.frame.size.height;
    CGFloat itemViewX = 0;
    CGFloat itemViewY = 0;
    
    if (itemsArray.count < _maxItemsCountForRow && _alignment == XBottomBarAlignmentCenter) {
        itemViewWidth = bottomBarScrollView.frame.size.width * 1.0 / itemsArray.count;
    } else {
        itemViewWidth = bottomBarScrollView.frame.size.width * 1.0 / _maxItemsCountForRow;
    }
    
    [bottomBarScrollView setContentSize:CGSizeMake(itemViewWidth * itemsArray.count, bottomBarScrollView.frame.size.height)];
    
    for (NSInteger i = 0; i < itemsArray.count; i++) {
        UIView *itemView = [bottomBarScrollView viewWithTag:i + initializeTag];
        UIImageView *itemImageView = [itemView viewWithTag:itemView.tag + itemsArray.count];
        UILabel *itemLabel = [itemView viewWithTag:itemView.tag + itemsArray.count * 2];
        UILabel *badge = [itemView viewWithTag:itemView.tag + itemsArray.count * 3];
        
        itemViewX = itemViewWidth * i;
        
        CGFloat offset = 3;
        CGFloat scale = 0;
        if (itemImageView.image) {
            scale = itemImageView.image.size.width * 1.0 / itemImageView.image.size.height;
        }
        
        CGFloat itemImageViewHeight = (scale == 0 ? 0 : (itemViewHeight - offset * 3) * 2 / 3.0);
        
        if (itemImageViewHeight < 0) {
            itemImageViewHeight = 0;
        }
        
        CGFloat itemImageViewWidth = itemImageViewHeight * scale;
        if (itemImageViewWidth > (itemViewWidth - offset * 2)) {
            itemImageViewWidth = (itemViewWidth - offset * 2);
        }
        
        if (itemImageViewWidth < 0) {
            itemImageViewWidth = 0;
        }
        
        CGFloat itemImageViewX = (itemViewWidth - itemImageViewWidth) / 2.0;
        CGFloat itemImageViewY = 0;
        
        CGSize itemLabelSize = [itemLabel labelSize];
        CGFloat itemLabelWidth = itemLabelSize.width;
        CGFloat itemLabelHeight = itemLabelSize.height;
        CGFloat itemLabelX = (itemViewWidth - itemLabelWidth) / 2.0;
        CGFloat itemLabelY = 0;
        
        itemImageViewY = (scale == 0 ? 0 : (itemViewHeight - itemImageViewHeight - offset - itemLabelHeight) / 2.0);
        itemLabelY = (scale == 0 ? (itemViewHeight - itemLabelHeight) / 2.0 : itemImageViewY + itemImageViewHeight + offset);
        
        [itemView setFrame:CGRectMake(itemViewX, itemViewY, itemViewWidth, itemViewHeight)];
        [itemImageView setFrame:CGRectMake(itemImageViewX, itemImageViewY, itemImageViewWidth, itemImageViewHeight)];
        [itemLabel setFrame:CGRectMake(itemLabelX, itemLabelY, itemLabelWidth, itemLabelHeight)];
        
        [self setItemBadgeFrame:badge];
    }
}

- (void)setItemBadgeFrame:(UILabel *)badge {
    NSInteger itemViewTag = badge.tag - itemsArray.count*3;
    UIView *itemView = [bottomBarScrollView viewWithTag:itemViewTag];
    CGFloat itemViewWidth = itemView.frame.size.width;
    
    CGSize badgeSize = [badge labelSize];
    CGFloat badgeWidth = badgeSize.width + 5;
    CGFloat badgeHeight = badgeSize.height + 4;
    if (badgeWidth < badgeHeight) {
        badgeWidth = badgeHeight;
    }
    CGFloat badgeX = itemViewWidth - badgeWidth;
    CGFloat badgeY = 0;
    [badge setFrame:CGRectMake(badgeX, badgeY, badgeWidth, badgeHeight)];
    [badge.layer setCornerRadius:badgeHeight / 2.0];
}

- (void)setLeftArrowHidden:(BOOL)leftHidden RightArrowHidden:(BOOL)rightHidden {
    [leftArrowImageView setHidden:leftHidden];
    [rightArrowImageView setHidden:rightHidden];
}

- (void)setScrollTargetFrame:(UIScrollView *)scrollView {
    CGRect frame = scrollView.frame;
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    CGFloat scrollViewContentSizeWidth = scrollView.contentSize.width;
    CGFloat contentXOffset = scrollView.contentOffset.x;
    if (contentXOffset > 0 && contentXOffset < (scrollViewContentSizeWidth - scrollViewWidth)) {
        CGFloat minItemViewWidth = 0;
        if (itemsArray.count <= _maxItemsCountForRow) {
            minItemViewWidth = bottomBarScrollView.frame.size.width * 1.0 / itemsArray.count;
        } else {
            minItemViewWidth = bottomBarScrollView.frame.size.width * 1.0 / _maxItemsCountForRow;
        }
        CGFloat result = contentXOffset / minItemViewWidth;
        NSInteger integer = (NSInteger)result;
        CGFloat decimal = result - integer;
        if (decimal > 0.5) {
            frame.origin.x = (integer + 1)*minItemViewWidth;
        } else{
            frame.origin.x = integer*minItemViewWidth;
        }
        [scrollView scrollRectToVisible:frame animated:YES];
    }
}

- (void)setItemState:(UIView *)view isSelected:(BOOL)isSelected {
    XBottomBarModel *bottomBarModel = [itemsArray x_objectAtIndex:view.tag - initializeTag];
    UIImageView *itemImageView = (UIImageView *)[view viewWithTag:(view.tag + itemsArray.count)];
    UILabel *itemLabel = (UILabel *)[view viewWithTag:(view.tag + itemsArray.count*2)];
    
    UIColor *color;
    if (isSelected) {
        [self setImage:itemImageView image:bottomBarModel.selectedImage imageUrl:bottomBarModel.selectedImageUrl];
        color = _itemSelectedColor;
    } else {
        [self setImage:itemImageView image:bottomBarModel.normalImage imageUrl:bottomBarModel.normalImageUrl];
        color = _itemNormalColor;
    }
    
    [bottomBarModel setSelected:isSelected];
    [itemLabel setTextColor:color];
}

#pragma mark - property

- (void)setLeftArrowImage:(UIImage *)leftArrowImage {
    _leftArrowImage = leftArrowImage;
    
    [leftArrowImageView setImage:_leftArrowImage];
    [self updateFrame];
}

- (void)setRightArrowImage:(UIImage *)rightArrowImage {
    _rightArrowImage = rightArrowImage;
    
    [rightArrowImageView setImage:_rightArrowImage];
    [self updateFrame];
}


#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    CGFloat scrollViewContentSizeWidth = scrollView.contentSize.width;
    CGFloat contentXOffset = scrollView.contentOffset.x;
    
    if (contentXOffset <= 0) {
        [self setLeftArrowHidden:YES RightArrowHidden:NO];
    } else if (contentXOffset >= (scrollViewContentSizeWidth - scrollViewWidth)) {
        [self setLeftArrowHidden:NO RightArrowHidden:YES];
    } else {
        [self setLeftArrowHidden:NO RightArrowHidden:NO];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self setScrollTargetFrame:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self setScrollTargetFrame:scrollView];
}

#pragma mark itemClickEvent Mothed

- (void)itemClickEvent:(id)sender {
    //将已选中的item恢复到正常状态
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    UIView *itemView = (UIView *)[tap view];
    NSInteger selectedIndex = itemView.tag - initializeTag;
    [self selectItemAtIndex:selectedIndex];
}

@end
