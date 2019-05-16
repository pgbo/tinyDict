//
//  TranslateBottomBar.m
//  tinyDict
//
//  Created by guangbool on 2017/5/5.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TranslateBottomBar.h"
#import <TDKit/Masonry.h>
#import <TDKit/TDSpecs.h>
#import <TDKit/UIView+TDKit.h>

@interface TranslateBottomBar ()

@property (nonatomic) UIButton *translateButn;
@property (nonatomic) UIButton *cancelButn;

@end

@implementation TranslateBottomBar

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureViews];
    }
    return self;
}

- (UIButton *)translateButn {
    if (!_translateButn) {
        _translateButn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_translateButn setBackgroundColor:[UIColor clearColor]];
        [_translateButn setTitleColor:[TDColorSpecs app_tint] forState:UIControlStateNormal];
        _translateButn.titleLabel.font = [TDFontSpecs largeBold];
        _translateButn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_translateButn setTitle:NSLocalizedStringFromTable(@"Translate", @"TinyT", nil) forState:UIControlStateNormal];
        [_translateButn addTarget:self action:@selector(translate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _translateButn;
}

- (UIButton *)cancelButn {
    if (!_cancelButn) {
        _cancelButn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButn setBackgroundColor:[UIColor clearColor]];
        [_cancelButn setTitleColor:[TDColorSpecs app_minorTextColor] forState:UIControlStateNormal];
        _cancelButn.titleLabel.font = [TDFontSpecs regular];
        _cancelButn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_cancelButn setTitle:NSLocalizedStringFromTable(@"Cancel", @"TinyT", nil) forState:UIControlStateNormal];
        [_cancelButn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButn;
}

- (void)translate:(id)sender {
    if (self.translateHandler) {
        self.translateHandler(self);
    }
}

- (void)cancel:(id)sender {
    if (self.cancelHandler) {
        self.cancelHandler(self);
    }
}

- (void)configureViews {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.translateButn];
    [self addSubview:self.cancelButn];
    CGFloat cancelWidth = [self.cancelButn intrinsicContentSize].width;
    [self.cancelButn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(cancelWidth + 8*2);
        make.trailing.mas_equalTo(-8);
        make.top.and.bottom.mas_equalTo(0);
    }];
    __weak typeof(self)weakSelf = self;
    [self.translateButn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.trailing.equalTo(weakSelf.cancelButn.mas_leading);
        make.top.and.bottom.mas_equalTo(0);
    }];
}

@end
