//
//  XGalleryCell.h
//  JYLibrary
//
//  Created by XJY on 15-7-31.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const galleryCellIdentifier;

@interface XGalleryCell : UICollectionViewCell

@property (nonatomic, copy)     NSString    *   placeholderImageName;
@property (nonatomic, assign)   CGFloat         maximumZoomScale;       //default is 2.0
@property (nonatomic, assign)   CGFloat         minimumZoomScale;       //default is 1.0

- (void)addImageForName:(NSString *)imageName;

- (void)addImageForPath:(NSString *)imagePath;

- (void)addImageForUrl:(NSString *)imageUrl placeHolderImageName:(NSString *)placeHolderImageName;

- (void)addImageForData:(NSData *)data;

- (void)addGifForName:(NSString *)name;

- (void)addGifForPath:(NSString *)gifPath;

- (void)addGifForData:(NSData *)data;

- (void)addImage:(UIImage *)image;

@end
