//
//  XTextField.m
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XTextField.h"


@interface XTextField ()
{
    UILabel *placeHolderLabel;
}

@end


@implementation XTextField

@synthesize multiLinePlaceholder;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _maxLengthForInput = 0;
    _multiLinePlaceholderEnable = NO;
    multiLinePlaceholder = nil;
    _multiLineAttributedPlaceholder = nil;
    _multiLinePlaceholderFont = self.font;
    _multiLinePlaceholderColor = self.textColor;
    _multiLinePlaceholderAlignment = self.textAlignment;
    [self addTarget:self action:@selector(textFieldDidBegin) forControlEvents:UIControlEventEditingDidBegin];
    [self addTarget:self action:@selector(textFieldDidEnd) forControlEvents:UIControlEventEditingDidEnd];
    [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.secureTextEntry) {
        return NO;
    } else {
        if (action == @selector(cut:) ||
            action == @selector(copy:) ||
            action == @selector(paste:) ||
            action == @selector(select:) ||
            action == @selector(selectAll:)) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (void) delete:(id)sender {
    //实现长按选择删除方法,如果不实现这方法,点击删除按钮会崩溃!
}

- (void)textFieldDidBegin {
    if (placeHolderLabel) {
        [placeHolderLabel setAlpha:0];
    }
}

- (void)textFieldDidEnd {
    [self refreshPlaceholder];
}

- (void)textFieldDidChange:(UITextField *)textField {
    [self refreshPlaceholder];
    BOOL isChinese; //判断当前输入法是否是中文
    if ([[UITextInputMode currentInputMode].primaryLanguage isEqualToString:@"en-US"]) {
        isChinese = NO;
    } else {
        isChinese = YES;
    }
    NSString *text = [textField.text stringByReplacingOccurrencesOfString:@"?" withString:@""];
    if (isChinese) { //中文输入法下
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字,则对已输入的文字进行字数统计和限制
        if (!position) {
            [self updateText:text];
        }
    } else {
        [self updateText:text];
    }
}

- (void)updateText:(NSString *)text {
    if (_maxLengthForInput != 0) {
        if (text.length > _maxLengthForInput) {
            NSString *newText = [NSString stringWithString:text];
            [self setText:[newText substringToIndex:_maxLengthForInput]];
        }
    }

    id x_delegate = self.delegate;
    if (x_delegate && [x_delegate respondsToSelector:@selector(updateInputLengthForTextField:)]) {
        [x_delegate updateInputLengthForTextField:self];
    }
}

- (void)refreshPlaceholder {
    if (placeHolderLabel) {
        if (_multiLinePlaceholderEnable && !self.isEditing) {
            [placeHolderLabel setAlpha:self.text.length > 0 ? 0 : 1];
        } else {
            [placeHolderLabel setAlpha:0];
        }
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self refreshPlaceholder];
}

- (NSString *)multiLinePlaceholder {
    if (placeHolderLabel) {
        return placeHolderLabel.text;
    } else {
        return @"";
    }
}

- (void)setMultiLinePlaceholder:(NSString *)placeholder {
    multiLinePlaceholder = placeholder;
    [self addPlaceHolderLabel];
    [placeHolderLabel setText:multiLinePlaceholder];
    if (_multiLinePlaceholderEnable) {
        [placeHolderLabel setAlpha:placeHolderLabel.text.length > 0 ? 0 : 1];
    } else {
        [placeHolderLabel setAlpha:0];
    }
    [self updatePlaceHolderLabelFrame];
    [self refreshPlaceholder];
}

- (void)setMultiLineAttributedPlaceholder:(NSAttributedString *)multiLineAttributedPlaceholder {
    _multiLineAttributedPlaceholder = multiLineAttributedPlaceholder;
    [self addPlaceHolderLabel];
    [placeHolderLabel setAttributedText:_multiLineAttributedPlaceholder];
    if (_multiLinePlaceholderEnable) {
        [placeHolderLabel setAlpha:placeHolderLabel.attributedText.length > 0 ? 0 : 1];
    } else {
        [placeHolderLabel setAlpha:0];
    }
    [self updatePlaceHolderLabelFrame];
    [self refreshPlaceholder];
}

- (void)addPlaceHolderLabel {
    if (!placeHolderLabel) {
        placeHolderLabel = [[UILabel alloc] init];
        [placeHolderLabel setBackgroundColor:[UIColor clearColor]];
        [placeHolderLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [placeHolderLabel setFont:_multiLinePlaceholderFont];
        [placeHolderLabel setTextColor:_multiLinePlaceholderColor];
        [placeHolderLabel setTextAlignment:_multiLinePlaceholderAlignment];
        [placeHolderLabel setNumberOfLines:0];
        [placeHolderLabel setLineBreakMode:NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail];
        [placeHolderLabel setAlpha:0];
        [self addSubview:placeHolderLabel];
    }
}

- (void)updatePlaceHolderLabelFrame {
    if (placeHolderLabel && _multiLinePlaceholderEnable) {
        CGFloat offset = 8;
        [placeHolderLabel setFrame:CGRectMake(offset, 0, self.frame.size.width - offset * 2, self.frame.size.height)];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updatePlaceHolderLabelFrame];
}

@end
