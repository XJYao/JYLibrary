//
//  XKeyboard.m
//  JYLibrary
//
//  Created by XJY on 16/10/28.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XKeyboard.h"
#import <UIKit/UIKit.h>


@interface XKeyboard ()
{
    UIView *currentResponderView; //当前输入框
    CGRect originViewFrame;       //视图原始Frame

    UITapGestureRecognizer *hideKeyboardGesture; //点击手势
    BOOL isRegisterdNotifications;               //是否已注册通知
}

@end


@implementation XKeyboard

+ (instancetype)manager {
    static XKeyboard *manager;
    if (!manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [[XKeyboard alloc] init];
        });
    }
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        isRegisterdNotifications = NO;
        originViewFrame = CGRectZero;
    }
    return self;
}

- (void)start {
    if (!isRegisterdNotifications) {
        [self registerNotifications];
    }
}

- (void)stop {
    if (isRegisterdNotifications) {
        [self unregisterNotifications];
    }
    [self removeGestureRecognizers];
    currentResponderView = nil;
    originViewFrame = CGRectZero;
}

- (void)dealloc {
    [self stop];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidBeginEditingNotification:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidEndEditingNotification:) name:UITextViewTextDidEndEditingNotification object:nil];

    isRegisterdNotifications = YES;
}

- (void)unregisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];

    isRegisterdNotifications = NO;
}

- (void)addGestureRecognizers:(UIView *)view {
    if (!hideKeyboardGesture) {
        hideKeyboardGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    }
    if (view && ![view.gestureRecognizers containsObject:hideKeyboardGesture]) {
        [view addGestureRecognizer:hideKeyboardGesture];
    }
}

- (void)removeGestureRecognizers {
    if (hideKeyboardGesture && hideKeyboardGesture.view && [hideKeyboardGesture.view.gestureRecognizers containsObject:hideKeyboardGesture]) {
        [hideKeyboardGesture.view removeGestureRecognizer:hideKeyboardGesture];
    }

    hideKeyboardGesture = nil;
}

#pragma mark - Notification

//输入框开始编辑
- (void)textFieldViewDidBeginEditing:(NSNotification *)notification {
    currentResponderView = notification.object;
}

- (void)textViewTextDidBeginEditingNotification:(NSNotification *)notification {
    currentResponderView = notification.object;
}

//输入框结束编辑
- (void)textFieldViewDidEndEditing:(NSNotification *)notification {
}

- (void)textViewTextDidEndEditingNotification:(NSNotification *)notification {
}

//键盘显示时
- (void)keyboardWillShow:(NSNotification *)notification {
    //找到要移动的视图
    UIViewController *responderViewController = [self responderViewController:currentResponderView];
    UIView *willMoveView = responderViewController.view;

    if (!willMoveView) {
        originViewFrame = CGRectZero;
        [self removeGestureRecognizers];
        return;
    }

    if (CGRectEqualToRect(originViewFrame, CGRectZero)) {
        originViewFrame = willMoveView.frame;
    }

    [self addGestureRecognizers:willMoveView];

    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;

    //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD)
    CGRect currentResponderViewFrame = [currentResponderView convertRect:currentResponderView.frame toView:willMoveView];
    CGFloat viewMoveOffset = (currentResponderViewFrame.origin.y + currentResponderViewFrame.size.height) - (willMoveView.frame.size.height - kbHeight);

    //将视图上移计算好的偏移
    if (viewMoveOffset > 0) {
        // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
        double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

        [UIView animateWithDuration:duration animations:^{
            CGRect willMoveViewFrame = originViewFrame;
            willMoveViewFrame.origin.y = (willMoveViewFrame.origin.y - viewMoveOffset);
            [willMoveView setFrame:willMoveViewFrame];
        }];
    }
}

//键盘收起时
- (void)keyboardWillHide:(NSNotification *)notification {
    [self removeGestureRecognizers];

    //找到要移动的视图
    UIViewController *responderViewController = [self responderViewController:currentResponderView];
    UIView *willMoveView = responderViewController.view;

    if (!willMoveView) {
        originViewFrame = CGRectZero;
        return;
    }

    // 键盘动画时间
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{

        [willMoveView setFrame:originViewFrame];

    } completion:^(BOOL finished) {
        if (finished) {
            originViewFrame = CGRectZero;
        }
    }];
}

/**
 点击收起键盘
 */
- (void)hideKeyboard:(UITapGestureRecognizer *)gestureRecognizer {
    [gestureRecognizer.view endEditing:YES];
}

/**
 找到输入框所在的ViewController
 */
- (UIViewController *)responderViewController:(UIView *)view {
    if (!view) {
        return nil;
    }

    UIResponder *nextResponder = view;

    Class viewControllerClass = [UIViewController class];

    do {
        nextResponder = [nextResponder nextResponder];

        if ([nextResponder isKindOfClass:viewControllerClass]) {
            return (UIViewController *)nextResponder;
        }

    } while (nextResponder);

    return nil;
}

@end
