//
//  XConstraint.h
//  JYLibrary
//
//  Created by XJY on 16/2/15.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XExpObject.h"


@interface UIView (XConstraint)

#define XConstraintMaker UIView

/**
 Note:
 'constant' is must be called if the constraint has relative view.
 */

/**
 Example: 
 
 *1. view2 is view1's father or brother.
 
    view1.x_left.x_equalTo(view2).x_left.x_multiplier(1.0).x_constant(0.0);    //view1's left equal to view2's left
    view1.x_left.x_equalTo(view2).x_multiplier(1.0).x_constant(10.0);          //view1's left equal to view2's left offset 10
    view1.x_left.x_equalTo(view2).x_constant(20.0);                            //view1's left equal to view2's left offset 20
 
    view1.x_left.x_right.x_top.x_bottom.x_equalTo(view2).x_constant(0.0);      //view1's left & right & top & bottom equal to view2
 
    view1.x_width.x_equalTo(view2).x_width.x_multiplier(0.5).x_constant(0.0);  //view1's width equal to half of the view2's width
    view1.x_width.x_equalTo(100);                                              //view1's width equal to 100
 
    view1.x_edge.x_equalTo(view2).x_edge.x_multiplier(1.0).x_constant(0.0);    //view1's left & right & top & bottom equal to view2
    view1.x_size.x_equalTo(view2).x_size.x_multiplier(1.0).x_constant(0.0);    //view1's size equal to view2
 
 *2. Use for UIScrollView, you should add a contentView to scrollView.
 
    scrollView.x_edge.x_equalTo(superView).x_edge.x_multiplier(1.0).x_constant(0);
 
    contentView.x_edge.x_equalTo(scrollView).x_edge.x_multiplier(1.0).x_constant(0);
    contentView.x_width.x_equalTo(scrollView).x_width.x_multiplier(1.0).x_constant(0);
    .
    .
    .
    contentView.x_bottom.x_equalTo(lastSubView).x_bottom.x_multiplier(1.0).x_constant(0);
 */

@property (nonatomic, strong, readonly) XConstraintMaker *x_left;
@property (nonatomic, strong, readonly) XConstraintMaker *x_right;
@property (nonatomic, strong, readonly) XConstraintMaker *x_top;
@property (nonatomic, strong, readonly) XConstraintMaker *x_bottom;
@property (nonatomic, strong, readonly) XConstraintMaker *x_leading;
@property (nonatomic, strong, readonly) XConstraintMaker *x_trailing;
@property (nonatomic, strong, readonly) XConstraintMaker *x_width;
@property (nonatomic, strong, readonly) XConstraintMaker *x_height;
@property (nonatomic, strong, readonly) XConstraintMaker *x_centerX;
@property (nonatomic, strong, readonly) XConstraintMaker *x_centerY;
@property (nonatomic, strong, readonly) XConstraintMaker *x_centerXY;
@property (nonatomic, strong, readonly) XConstraintMaker *x_edge;
@property (nonatomic, strong, readonly) XConstraintMaker *x_size;

- (XConstraintMaker * (^)(CGFloat multiplier))x_multiplier; //default is 1.0
- (XConstraintMaker * (^)(CGFloat constant))x_constant;     //default is 0.0

//call when you first add layout constraint.
- (XConstraintMaker * (^)(id reference))x_equalTo;
- (XConstraintMaker * (^)(id reference))x_lessThanOrEqualTo;
- (XConstraintMaker * (^)(id reference))x_greaterThanOrEqualTo;

#define x_equalTo(...) x_equalTo(expObject((__VA_ARGS__)))
#define x_lessThanOrEqualTo(...) x_lessThanOrEqualTo(expObject((__VA_ARGS__)))
#define x_greaterThanOrEqualTo(...) x_greaterThanOrEqualTo(expObject((__VA_ARGS__)))

//call when you need update constraint.
- (XConstraintMaker * (^)(id reference))x_update_equalTo;
- (XConstraintMaker * (^)(id reference))x_update_lessThanOrEqualTo;
- (XConstraintMaker * (^)(id reference))x_update_greaterThanOrEqualTo;

#define x_update_equalTo(...) x_update_equalTo(expObject((__VA_ARGS__)))
#define x_update_lessThanOrEqualTo(...) x_update_lessThanOrEqualTo(expObject((__VA_ARGS__)))
#define x_update_greaterThanOrEqualTo(...) x_update_greaterThanOrEqualTo(expObject((__VA_ARGS__)))

/** 
 remove constraints
 
 Example:
    view1.x_left.x_remove();
    view1.x_left.right.x_remove();
 */
- (XConstraintMaker * (^)(void))x_remove;

@end
