//
//  XGallery.m
//  JYLibrary
//
//  Created by XJY on 15-7-31.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XGallery.h"
#import "XGalleryCell.h"
#import "UILabel+XLabel.h"
#import "XTool.h"
#import "XFileManager.h"

@interface XGallery() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    UILabel             *   pageNumberLabel;
    UICollectionView    *   galleryCollectionView;
    NSMutableArray      *   imagesArr;

    NSInteger               currentPageIndex;
}

@end

@implementation XGallery

#pragma mark private Method

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self addUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images {
    self = [super initWithFrame:frame];
    if (self) {
        imagesArr = [[NSMutableArray alloc] initWithArray:images];
        [self initialize];
        [self addUI];
    }
    return self;
}

- (void)initialize {
    [self setBackgroundColor:[UIColor clearColor]];
    
    _placeholderImageName = @"";
    _maximumZoomScale = 2.0;
    _minimumZoomScale = 1.0;
    _pageNumberFont = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    currentPageIndex = 0;
}

- (void)addUI {
    [self addPageNumberLabel];
    [self addGalleryView];
}

- (void)addPageNumberLabel {
    pageNumberLabel = [[UILabel alloc] init];
    [pageNumberLabel setBackgroundColor:[UIColor clearColor]];
    [pageNumberLabel setTextAlignment:NSTextAlignmentCenter];
    [pageNumberLabel setTextColor:[UIColor whiteColor]];
    [pageNumberLabel setFont:_pageNumberFont];
    [pageNumberLabel setText:@"0/0"];
    [self addSubview:pageNumberLabel];
}

- (void)addGalleryView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    CGSize pageNumberLabelSize = [pageNumberLabel labelSize];
    CGFloat pageNumberLabelHeight = pageNumberLabelSize.height;
    galleryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - pageNumberLabelHeight) collectionViewLayout:flowLayout];
    [galleryCollectionView setBackgroundColor:[UIColor clearColor]];
    [galleryCollectionView setPagingEnabled:YES];
    [galleryCollectionView setBounces:YES];
    [galleryCollectionView setShowsHorizontalScrollIndicator:NO];
    [galleryCollectionView setShowsVerticalScrollIndicator:NO];
    [galleryCollectionView registerClass:[XGalleryCell class] forCellWithReuseIdentifier:galleryCellIdentifier];
    [galleryCollectionView setDelegate:self];
    [galleryCollectionView setDataSource:self];
    [galleryCollectionView setDelaysContentTouches:NO];
    [self addSubview:galleryCollectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateFrame];
}

- (void)updateFrame {
    [self updatePageNumberLabelFrame];
    [self updateGalleryFrame];
}

- (void)updatePageNumberLabelFrame {
    CGSize pageNumberLabelSize = [pageNumberLabel labelSize];
    CGFloat pageNumberLabelWidth = pageNumberLabelSize.width;
    CGFloat pageNumberLabelHeight = pageNumberLabelSize.height;
    CGFloat pageNumberLabelX = (self.frame.size.width - pageNumberLabelWidth) * 1.0 / 2;
    CGFloat pageNumberLabelY = self.frame.size.height - pageNumberLabelHeight;
    [pageNumberLabel setFrame:CGRectMake(pageNumberLabelX, pageNumberLabelY, pageNumberLabelWidth, pageNumberLabelHeight)];
}

- (void)updateGalleryFrame {
    CGFloat galleryCollectionViewWidth = self.frame.size.width;
    CGFloat galleryCollectionViewHeight = self.frame.size.height - pageNumberLabel.frame.size.height;
    CGFloat galleryCollectionViewX = 0;
    CGFloat galleryCollectionViewY = 0;
    
    [galleryCollectionView setFrame:CGRectMake(galleryCollectionViewX, galleryCollectionViewY, galleryCollectionViewWidth, galleryCollectionViewHeight)];
}

- (void)setPageIndex:(NSInteger)pageIndex {
    NSInteger index = 0;
    if ([XTool isArrayEmpty:imagesArr]) {
        index = 0;
    } else {
        if (pageIndex >= imagesArr.count) {
            pageIndex = imagesArr.count - 1;
        } else if (pageIndex < 0) {
            pageIndex = 0;
        }
        index = pageIndex+1;
    }
    
    NSString *text = [[NSString stringWithFormat:@"%d", (int)index] stringByAppendingString:@"/"];
    text = [text stringByAppendingString:[NSString stringWithFormat:@"%d", (int)imagesArr.count]];
    [pageNumberLabel setText:text];
    [self updatePageNumberLabelFrame];
}

#pragma mark public Method

- (void)updateFrameWhenRotation:(CGRect)frame {
    [self setFrame:frame];
    [galleryCollectionView reloadData];
    [self scrollToIndex:currentPageIndex animated:NO];
}

- (void)addImages:(NSArray *)images {
    if (![XTool isArrayEmpty:images]) {
        if (!imagesArr) {
            imagesArr = [[NSMutableArray alloc] init];
        }
        [imagesArr addObjectsFromArray:images];
        if ([XTool isArrayEmpty:imagesArr]) {
            [galleryCollectionView reloadData];
        } else {
            NSInteger beginIndex = imagesArr.count - images.count;
            NSMutableArray *indexPathsArr = [[NSMutableArray alloc] init];
            for (NSInteger item=beginIndex; item<imagesArr.count; item++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
                [indexPathsArr x_addObject:indexPath];
            }
            [galleryCollectionView insertItemsAtIndexPaths:indexPathsArr];
        }
        [self setPageIndex:currentPageIndex];
    }
}

- (void)addImages:(NSArray *)images placeHolderImageName:(NSString *)imageName {
    _placeholderImageName = imageName;
    [self addImages:images];
}

- (void)addImage:(id)anObject {
    if ([anObject isKindOfClass:[NSString class]]) {
        NSString *str = (NSString *)anObject;
        if (![XTool isStringEmpty:str]) {
            [self addImages:@[str]];
        }
    } else if ([anObject isKindOfClass:[NSData class]]) {
        NSData *data = (NSData *)anObject;
        if (data) {
            [self addImages:@[data]];
        }
    } else if ([anObject isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage *)anObject;
        if (image) {
            [self addImages:@[image]];
        }
    }
}

- (BOOL)removeImageAtIndex:(NSInteger)index {
    if (index < 0 || index > imagesArr.count - 1 || index == NSNotFound) {
        return NO;
    } else {
        if (index < currentPageIndex ||
            (index == currentPageIndex && currentPageIndex == imagesArr.count - 1)) {
            currentPageIndex = currentPageIndex - 1;
        }
        [imagesArr x_removeObjectAtIndex:index];
        [self setPageIndex:currentPageIndex];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [galleryCollectionView deleteItemsAtIndexPaths:@[indexPath]];
        return YES;
    }
}

- (BOOL)removeImage:(id)anObject {
    NSInteger index = [imagesArr indexOfObject:anObject];
    return [self removeImageAtIndex:index];
}

- (void)removeAllImages {
    [imagesArr removeAllObjects];
    currentPageIndex = 0;
    [self setPageIndex:currentPageIndex];
    [galleryCollectionView reloadData];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    currentPageIndex = index;
    [self setPageIndex:currentPageIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentPageIndex inSection:0];
    [galleryCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:animated];
}

#pragma mark -- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger sectionCount = 0;
    if (![XTool isArrayEmpty:imagesArr]) {
        sectionCount = 1;
    }
    return sectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger itemCountForSection = 0;
    
    if (![XTool isArrayEmpty:imagesArr]) {
        itemCountForSection = imagesArr.count;
    }
    
    return itemCountForSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XGalleryCell *cell = nil;
    if (![XTool isArrayEmpty:imagesArr]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:galleryCellIdentifier forIndexPath:indexPath];
        [cell setPlaceholderImageName:_placeholderImageName];
        [cell setMaximumZoomScale:_maximumZoomScale];
        [cell setMinimumZoomScale:_minimumZoomScale];
        id unKnownObject = [imagesArr x_objectAtIndex:indexPath.item];
        if ([unKnownObject isKindOfClass:[NSString class]]) {
            NSString *imagePath = (NSString *)unKnownObject;
            if ([imagePath rangeOfString:@"http://"].location == NSNotFound) {
                if ([imagePath rangeOfString:@"/"].location == NSNotFound) {//不是地址,是文件名
                    if ([imagePath rangeOfString:@"."].location != NSNotFound) {//带后缀
                        NSString *type = [XFileManager getSufixForName:imagePath];
                        if ([type isEqualToString:@"gif"]) {//gif
                            NSString *name = [XFileManager getFileNameWithoutSufixForName:imagePath];
                            [cell addGifForName:name];
                        } else {//图片
                            [cell addImageForName:imagePath];
                        }
                    } else {//不带后缀
                        [cell addImageForName:imagePath];
                    }
                } else {//是地址
                    NSString *type = [XFileManager getSufixForPath:imagePath];
                    if ([type isEqualToString:@"gif"]) {//gif
                        [cell addGifForPath:imagePath];
                    } else {//图片
                        [cell addImageForPath:imagePath];
                    }
                }
            } else {
                [cell addImageForUrl:imagePath placeHolderImageName:_placeholderImageName];
            }
        } else if ([unKnownObject isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)unKnownObject;
            [cell addImageForData:data];
        } else if ([unKnownObject isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage *)unKnownObject;
            [cell addImage:image];
        }
    }
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout

-  (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = collectionView.frame.size.width;
    CGFloat height = collectionView.frame.size.height;
    CGSize size = CGSizeMake(width, height);
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark UICollectionViewDelegate Method

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark UIScrollView Delegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat galleryScrollViewWidth = scrollView.frame.size.width;
    NSInteger offsetX = scrollView.contentOffset.x;
    currentPageIndex = offsetX/galleryScrollViewWidth;
    [self setPageIndex:currentPageIndex];
}


@end
