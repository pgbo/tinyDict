//
//  TodayInputAccessoryView.m
//  tinyDict
//
//  Created by guangbool on 2017/4/10.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TodayInputAccessoryView.h"
#import <TDKit/TDKit.h>

@interface TodayInputAccessoryView () <UITextFieldDelegate>

@property (nonatomic) UITextField *textField;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIView *topSeperator;

@end

@implementation TodayInputAccessoryView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureViews];
    }
    return self;
}

- (UIView *)topSeperator {
    if (!_topSeperator) {
        _topSeperator = [UIView new];
        _topSeperator.backgroundColor = [TDColorSpecs wd_separator];
    }
    return _topSeperator;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.spellCheckingType = UITextSpellCheckingTypeNo;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.font = [TDFontSpecs regularBold];
        _textField.textColor = [TDColorSpecs wd_tint];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.text = self.text;
        _textField.placeholder = NSLocalizedStringFromTable(@"Input...", @"todayextension", nil);
        _textField.delegate = self;
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setImage:[UIImage imageNamed:@"keyboard_down"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (void)configureViews {
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.textField];
    [self addSubview:self.cancelButton];
    [self addSubview:self.topSeperator];
    
    __weak typeof(self)weakSelf = self;
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
        make.centerY.mas_equalTo(0);
        make.leading.mas_equalTo(12);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(0);
        make.width.mas_equalTo(40);
        make.leading.equalTo(weakSelf.textField.mas_trailing).offset(8);
        make.trailing.mas_equalTo(0);
    }];
    
    [self.topSeperator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.leading.and.trailing.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)cancelButtonClick:(id)sender {
    [self resignFirstResponder];
    if (self.cancelItemClickBlock) {
        self.cancelItemClickBlock();
    }
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    _textField.text = text;
}

- (void)clearText {
    _textField.text = nil;
}

- (BOOL)becomeFirstResponder {
    return [_textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [_textField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.finishInputBlock) {
        [self resignFirstResponder];
        self.finishInputBlock(textField.text);
        return NO;
    }
    return YES;
}

- (void)textFieldDidChange:(id)sender {
    if (self.inputingBlock) {
        self.inputingBlock(_textField.text);
    }
}

@end
