//
//  XPickerView.m
//  JYLibrary
//
//  Created by XJY on 15/11/9.
//  Copyright © 2015年 XJY. All rights reserved.
//

#import "XPickerView.h"
#import "XTool.h"
#import "XAnimation.h"
#import "UIImage+XImage.h"

@interface XPickerView () <UIPickerViewDataSource, UIPickerViewDelegate> {
    UIPickerView *picker;
    UIButton *cancelPickerButton;
    UIButton *selectPickerButton;
    NSMutableArray *pickerTitlesArray;
    
    XPickerViewBlock selectPickerBlock;
}

@end

@implementation XPickerView

#pragma mark - Public

- (instancetype)initWithTitles:(NSArray *)titles onView:(UIView *)view {
    self = [self init];
    
    if (self) {
        [view addSubview:self];
        
        CGFloat pickerViewHeight = [self getPickerViewHeight];
        CGFloat pickerViewY = view.frame.size.height - pickerViewHeight;
        [self setFrameWithX:0 y:pickerViewY width:view.frame.size.width];

        [self reloadData:titles];
    }
    
    return self;
}

- (void)setFrameWithX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width {
    CGFloat totalHeight = [self getPickerViewHeight];
    [super setFrame:CGRectMake(x, y, width, totalHeight)];
    
    CGFloat offsetX = 10;
    CGFloat buttonWidth = 50;
    CGFloat buttonHeight = 30;
    
    [cancelPickerButton setFrame:CGRectMake(offsetX, 10, buttonWidth, buttonHeight)];
    [selectPickerButton setFrame:CGRectMake(width - buttonWidth - offsetX, 10, buttonWidth, buttonHeight)];
    
    CGRect pickerFrame = picker.frame;
    pickerFrame.origin.x = 0;
    pickerFrame.origin.y = 0;
    pickerFrame.size.width = width;
    [picker setFrame:pickerFrame];
}

- (CGFloat)getPickerViewHeight {
    return picker.frame.size.height + 20;
}

- (void)reloadData:(NSArray *)titles {
    [pickerTitlesArray removeAllObjects];
    [pickerTitlesArray addObjectsFromArray:titles];
    [picker reloadAllComponents];
}

- (void)show:(BOOL)animated {
    if (!animated) {
        [self setHidden:NO];
        return;
    }
    
    [XAnimation animationFromBottomToTop:self duration:0.3f executingBlock:^{
        [self setHidden:NO];
    }];
}

- (void)hide:(BOOL)animated {
    if (!animated) {
        [self setHidden:YES];
        return;
    }
    
    [XAnimation animationFromTopToBottom:self duration:0.3f executingBlock:^{
        [self setHidden:YES];
    }];
}

- (void)selectRow:(NSInteger)row animated:(BOOL)animated {
    [picker selectRow:row inComponent:0 animated:animated];
}

- (void)selectPickerBlock:(XPickerViewBlock)block {
    selectPickerBlock = block;
}

#pragma mark - Private

- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
        [self addPicker];
        [self addButtons];
    }
    return self;
}

- (void)initialize {
    [self setBackgroundColor:[UIColor whiteColor]];
    pickerTitlesArray = [[NSMutableArray alloc] init];
    
    _cancelButtonTitle = @"取消";
    _selectButtonTitle = @"确定";
}

- (void)drawRect:(CGRect)rect {
     CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.frame.size.width, 0);
    CGContextStrokePath(context);
}

- (void)addPicker {
    picker = [[UIPickerView alloc] init];
    [picker setBackgroundColor:[UIColor clearColor]];
    [picker setShowsSelectionIndicator:YES];
    [picker setDataSource:self];
    [picker setDelegate:self];
    [self addSubview:picker];
}

- (void)addButtons {
    cancelPickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelPickerButton setBackgroundColor:[UIColor whiteColor]];
    [cancelPickerButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [cancelPickerButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];
    [cancelPickerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelPickerButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [cancelPickerButton.layer setMasksToBounds:YES];
    [cancelPickerButton.layer setBorderWidth:1];
    [cancelPickerButton.layer setCornerRadius:5.0];
    [cancelPickerButton addTarget:self action:@selector(cancelPicker) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelPickerButton];
    
    selectPickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectPickerButton setBackgroundColor:[UIColor whiteColor]];
    [selectPickerButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [selectPickerButton setTitle:_selectButtonTitle forState:UIControlStateNormal];
    [selectPickerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectPickerButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [selectPickerButton.layer setMasksToBounds:YES];
    [selectPickerButton.layer setBorderWidth:1];
    [selectPickerButton.layer setCornerRadius:5.0];
    [selectPickerButton addTarget:self action:@selector(selectPicker) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:selectPickerButton];
}

- (void)setCancelButtonTitle:(NSString *)cancelButtonTitle {
    _cancelButtonTitle = cancelButtonTitle;
    
    [cancelPickerButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];
}

- (void)setSelectButtonTitle:(NSString *)selectButtonTitle {
    _selectButtonTitle = selectButtonTitle;
    
    [selectPickerButton setTitle:_selectButtonTitle forState:UIControlStateNormal];
}

- (BOOL)isShowing {
    return !self.isHidden;
}

- (NSArray *)titles {
    return [NSArray arrayWithArray:pickerTitlesArray];
}

#pragma mark TouchEvent Method

- (void)cancelPicker {
    if(_delegate && [_delegate respondsToSelector:@selector(cancelPicker:)]) {
        [_delegate cancelPicker:self];
    }
}

- (void)selectPicker {
    NSString *selectedTitle = @"";
    NSInteger atIndex = NSNotFound;
    
    if (![XTool isArrayEmpty:pickerTitlesArray]) {
        atIndex = [picker selectedRowInComponent:0];
        selectedTitle = [pickerTitlesArray x_objectAtIndex:atIndex];
    }
    
    if (selectPickerBlock) {
        selectPickerBlock(self, selectedTitle, atIndex);
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(selectPicker:withTitle:atIndex:)]) {
        [_delegate selectPicker:self withTitle:selectedTitle atIndex:atIndex];
    }
}

#pragma mark UIPickerViewDataSource Method

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSInteger componentsCount = 0;
    if (![XTool isArrayEmpty:pickerTitlesArray]) {
        componentsCount = 1;
    }
    return componentsCount;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger rowsCount = 0;
    if (![XTool isArrayEmpty:pickerTitlesArray]) {
        rowsCount = pickerTitlesArray.count;
    }
    return rowsCount;
}

#pragma mark UIPickerViewDelegate Method

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    CGFloat componentWidth = 0;
    if (![XTool isArrayEmpty:pickerTitlesArray]) {
        componentWidth = pickerView.frame.size.width;
    }
    return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    CGFloat rowHeight = 0;
    if (![XTool isArrayEmpty:pickerTitlesArray]) {
        rowHeight = 30;
    }
    return rowHeight;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *pickTitle = @"";
    if (![XTool isArrayEmpty:pickerTitlesArray]) {
        pickTitle = [pickerTitlesArray x_objectAtIndex:row];
    }
    return pickTitle;
}

@end
