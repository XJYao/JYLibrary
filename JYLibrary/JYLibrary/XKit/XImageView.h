//
//  XImageView.h
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XImageView : UIImageView

@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *highlightImage;
@property (nonatomic, strong) UIImage *selectedImage;

@end
