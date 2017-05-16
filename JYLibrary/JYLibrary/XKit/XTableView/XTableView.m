//
//  XTableView.m
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XTableView.h"
#import "XTool.h"
#import "XThread.h"
#import "UITableView+XTableView.h"
#import "NSArray+XArray.h"


@interface XTableView ()
{
    XTableViewLoadVisibleRowsCompletedBlock loadVisibleRowsCompletedBlock;
}

@end


@implementation XTableView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

- (void)observeLoadVisibleRowsCompleted:(XTableViewLoadVisibleRowsCompletedBlock)block {
    loadVisibleRowsCompletedBlock = block;
}

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    UITableViewCell *cell = [super dequeueReusableCellWithIdentifier:identifier];
    [self judgeLoadCompleted:cell];

    return cell;
}

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [self judgeLoadCompleted:cell];

    return cell;
}

- (void)judgeLoadCompleted:(UITableViewCell *)cell {
    if (!loadVisibleRowsCompletedBlock) {
        return;
    }

    x_dispatch_async_default(^{
        NSArray *shouldLoadRows = [self indexPathsForVisibleRows];
        NSMutableArray *visibleRows = [[NSMutableArray alloc] initWithArray:[self visibleCells]];
        if (cell) {
            [visibleRows x_addObject:cell];
        }

        BOOL loadCompleted = YES;

        if ([XTool isArrayEmpty:shouldLoadRows]) {
            loadCompleted = NO;
        } else {
            if ([XTool isArrayEmpty:visibleRows]) {
                loadCompleted = NO;
            } else {
                for (NSIndexPath *shouldLoadRowIndexPath in shouldLoadRows) {
                    BOOL hasVisible = NO;

                    for (UITableViewCell *visibleRow in visibleRows) {
                        NSArray *visibleRowIndexPathArray = [self indexPathsForRowsInRect:visibleRow.frame];

                        NSIndexPath *visibleRowIndexPath = nil;
                        if (![XTool isArrayEmpty:visibleRowIndexPathArray]) {
                            visibleRowIndexPath = [visibleRowIndexPathArray x_objectAtIndex:0];
                        }

                        if (visibleRowIndexPath &&
                            (visibleRowIndexPath.section == shouldLoadRowIndexPath.section) &&
                            (visibleRowIndexPath.row == shouldLoadRowIndexPath.row)) {
                            hasVisible = YES;
                            break;
                        }
                    }
                    if (!hasVisible) {
                        loadCompleted = NO;
                        break;
                    }
                }
            }
        }

        if (loadCompleted) {
            x_dispatch_main_async(^{
                loadVisibleRowsCompletedBlock(shouldLoadRows);
            });
        }
    });
}

@end
