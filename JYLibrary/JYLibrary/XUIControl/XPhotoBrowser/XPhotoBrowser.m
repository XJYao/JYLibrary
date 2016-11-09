//
//  XPhotoBrowser.m
//  JYLibrary
//
//  Created by XJY on 16/4/14.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XPhotoBrowser.h"
#import "XPhotoView.h"
#import "UILabel+XLabel.h"
#import "XTool.h"
#import "XFileManager.h"
#import "UIImage+XImage.h"
#import "XThread.h"

@interface XPhotoBrowser() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    UILabel             *   pageNumberLabel;
    UICollectionView    *   photoBrowserCollectionView;
    UIActivityIndicatorView * loading;
    NSArray             *   imagesArray;
    
    NSInteger               currentPageIndex;
}

@end

@implementation XPhotoBrowser

#pragma mark private Method

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self addUI];
    }
    return self;
}

- (void)initialize {
    [self setBackgroundColor:[UIColor clearColor]];
    
    _placeHolderImage = nil;
    _maximumZoomScale = 2.0;
    _minimumZoomScale = 1.0;
    _pageNumberFont = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    currentPageIndex = 0;
}

- (void)addUI {
    pageNumberLabel = [[UILabel alloc] init];
    [pageNumberLabel setBackgroundColor:[UIColor clearColor]];
    [pageNumberLabel setTextAlignment:NSTextAlignmentCenter];
    [pageNumberLabel setTextColor:[UIColor whiteColor]];
    [pageNumberLabel setFont:_pageNumberFont];
    [pageNumberLabel setText:@"0/0"];
    [self addSubview:pageNumberLabel];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    CGSize pageNumberLabelSize = [pageNumberLabel labelSize];
    CGFloat pageNumberLabelHeight = pageNumberLabelSize.height;
    photoBrowserCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - pageNumberLabelHeight) collectionViewLayout:flowLayout];
    [photoBrowserCollectionView setBackgroundColor:[UIColor clearColor]];
    [photoBrowserCollectionView setPagingEnabled:YES];
    [photoBrowserCollectionView setBounces:YES];
    [photoBrowserCollectionView setShowsHorizontalScrollIndicator:NO];
    [photoBrowserCollectionView setShowsVerticalScrollIndicator:NO];
    Class class = [XPhotoView class];
    [photoBrowserCollectionView registerClass:class forCellWithReuseIdentifier:NSStringFromClass(class)];
    [photoBrowserCollectionView setDelaysContentTouches:NO];
    [photoBrowserCollectionView setDelegate:self];
    [photoBrowserCollectionView setDataSource:self];
    [self addSubview:photoBrowserCollectionView];
    
    loading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [loading setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:loading];
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
    
    [loading setCenter:self.center];
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
    
    [photoBrowserCollectionView setFrame:CGRectMake(galleryCollectionViewX, galleryCollectionViewY, galleryCollectionViewWidth, galleryCollectionViewHeight)];
}

- (void)setPageIndex:(NSInteger)pageIndex {
    NSInteger index = 0;
    if ([XTool isArrayEmpty:imagesArray]) {
        index = 0;
    } else {
        if (pageIndex >= imagesArray.count) {
            pageIndex = imagesArray.count - 1;
        } else if (pageIndex < 0) {
            pageIndex = 0;
        }
        index = pageIndex+1;
    }
    
    NSString *text = [[NSString stringWithFormat:@"%d", (int)index] stringByAppendingString:@"/"];
    text = [text stringByAppendingString:[NSString stringWithFormat:@"%d", (int)imagesArray.count]];
    [pageNumberLabel setText:text];
    [self updatePageNumberLabelFrame];
}

#pragma mark public Method

- (void)loadImages:(NSArray *)images {
    [loading startAnimating];
    
    x_dispatch_async_default(^{
        
        [XThread semaphoreCreate:0 executingBlock:^(WaitSignal waitSignal, SendSignal sendSignal) {
            
            if (![XTool isArrayEmpty:images]) {
                NSMutableArray *newMultiImages = [[NSMutableArray alloc] init];
                
                __block NSInteger index = 0;
                for (id imageObject in images) {
                    if ([imageObject isKindOfClass:[NSString class]]) {
                        x_dispatch_async_default(^{
                            NSData *data = [[NSData alloc] initWithContentsOfFile:imageObject];
                            NSArray *imagesWithData = [UIImage imagesWithData:data];
                            
                            @synchronized(self) {
                                [newMultiImages addObjectsFromArray:imagesWithData];
                                
                                if (index == images.count - 1) {
                                    imagesArray = newMultiImages;
                                    sendSignal();
                                } else {
                                    index ++;
                                }
                            }
                            
                        });
                    } else if ([imageObject isKindOfClass:[UIImage class]]) {
                        @synchronized(self) {
                            [newMultiImages x_addObject:imageObject];
                            
                            if (index == images.count - 1) {
                                imagesArray = newMultiImages;
                                sendSignal();
                            } else {
                                index ++;
                            }
                        }
                    }
                }
            } else {
                imagesArray = images;
                sendSignal();
            }
            
            waitSignal();
            
            x_dispatch_main_async(^{
                [loading stopAnimating];
                [photoBrowserCollectionView reloadData];
                [self setPageIndex:currentPageIndex];
            });
        }];
    });
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    currentPageIndex = index;
    [self setPageIndex:currentPageIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentPageIndex inSection:0];
    [photoBrowserCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:animated];
}

#pragma mark -- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger sectionCount = 0;
    if (![XTool isArrayEmpty:imagesArray]) {
        sectionCount = 1;
    }
    return sectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger itemCountForSection = 0;
    
    if (![XTool isArrayEmpty:imagesArray]) {
        itemCountForSection = imagesArray.count;
    }
    
    return itemCountForSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XPhotoView *cell = nil;
    if (![XTool isArrayEmpty:imagesArray]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XPhotoView class]) forIndexPath:indexPath];
        if (!cell) {
            cell = [[XPhotoView alloc] initWithFrame:collectionView.frame];
        }
        if (!cell) {
            return nil;
        }
        
        [cell setPlaceholderImage:_placeHolderImage];
        [cell setMaximumZoomScale:_maximumZoomScale];
        [cell setMinimumZoomScale:_minimumZoomScale];
        id unKnownObject = [imagesArray x_objectAtIndex:indexPath.item];
        if ([unKnownObject isKindOfClass:[NSString class]]) {
            NSString *imagePath = (NSString *)unKnownObject;
            if ([imagePath rangeOfString:@"http://"].location == NSNotFound) {
                [cell loadImageForPath:imagePath];
            } else {
                [cell loadImageForUrl:imagePath];
            }
        } else if ([unKnownObject isKindOfClass:[UIImage class]]) {
            [cell loadImage:(UIImage *)unKnownObject];
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

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    XPhotoView *photoView = (XPhotoView *)cell;
    [photoView releaseAll];
}

#pragma mark UIScrollView Delegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat galleryScrollViewWidth = scrollView.frame.size.width;
    NSInteger offsetX = scrollView.contentOffset.x;
    currentPageIndex = offsetX/galleryScrollViewWidth;
    [self setPageIndex:currentPageIndex];
}

@end
