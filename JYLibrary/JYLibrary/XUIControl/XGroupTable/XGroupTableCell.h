//
//  XGroupTableCell.h
//  JYLibrary
//
//  Created by XJY on 15-8-10.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XTableViewCell.h"

@class XGroupTableModel;

@interface XGroupTableCell : XTableViewCell

#pragma mark property

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) XGroupTableModel *  currentGroupTableModel;

#pragma mark method

+ (CGFloat)getCellHeight:(id)model width:(CGFloat)width;

- (void)addModel:(id)model;

@end
