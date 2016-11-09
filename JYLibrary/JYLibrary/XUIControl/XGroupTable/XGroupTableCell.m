//
//  XGroupTableCell.m
//  JYLibrary
//
//  Created by XJY on 15-8-10.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XGroupTableCell.h"

@implementation XGroupTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [super initWithStyle:style reuseIdentifier:reuseIdentifier];
}

+ (CGFloat)getCellHeight:(id)model width:(CGFloat)width {
    
    return 50;
}

- (void)addModel:(id)model {
    _currentGroupTableModel = model;
}

@end
