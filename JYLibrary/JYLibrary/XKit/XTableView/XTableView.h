//
//  XTableView.h
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XTableView : UITableView

typedef void (^XTableViewLoadVisibleRowsCompletedBlock)(NSArray<NSIndexPath *> *visibleRows);

- (void)observeLoadVisibleRowsCompleted:(XTableViewLoadVisibleRowsCompletedBlock)block;

@end
