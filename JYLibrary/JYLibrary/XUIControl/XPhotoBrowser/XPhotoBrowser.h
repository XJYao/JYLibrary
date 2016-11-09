//
//  XPhotoBrowser.h
//  JYLibrary
//
//  Created by XJY on 16/4/14.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XPhotoBrowser : UIView

@property (nonatomic, strong)   UIImage *placeHolderImage;
@property (nonatomic, assign)   CGFloat maximumZoomScale; //default is 2.0
@property (nonatomic, assign)   CGFloat minimumZoomScale; //default is 1.0
@property (nonatomic, strong)   UIFont *pageNumberFont;

- (void)loadImages:(NSArray *)images;

@end
