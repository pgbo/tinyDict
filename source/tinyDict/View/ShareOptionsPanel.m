//
//  ShareOptionsPanel.m
//  tinyDict
//
//  Created by guangbool on 2017/5/17.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "ShareOptionsPanel.h"
#import <TDKit/UIView+TDKit.h>
#import <TDKit/Masonry.h>

static const NSUInteger ShareOptionsPanelOptionNumber = 4;
static const CGFloat ShareOptionsPanelOptionButtonSize = 54.f;
static const CGFloat ShareOptionsPanelOptionButtonDefaultSpacing = 30.f;

@interface ShareOptionsPanel ()

@property (nonatomic) UIStackView *stackView;

@end

@implementation ShareOptionsPanel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureViews];
    }
    return self;
}

- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[[self createWechatButton],
                                                                     [self createWxmomentButton],
                                                                     [self createImportButton],
                                                                     [self createMoreButton]]];
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.distribution = UIStackViewDistributionEqualSpacing;
        _stackView.alignment = UIStackViewAlignmentCenter;
        _stackView.spacing = [self caculateShareOptionSpacing];
    }
    return _stackView;
}

- (void)configureViews {
    
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(ShareOptionsPanelOptionButtonSize);
    }];
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    
    _stackView.spacing = [self caculateShareOptionSpacing];
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    CGFloat height = ShareOptionsPanelOptionButtonSize;
    CGFloat width = _stackView.spacing * (ShareOptionsPanelOptionNumber - 1) + ShareOptionsPanelOptionButtonSize * ShareOptionsPanelOptionNumber;
    return CGSizeMake(width, height);
}

- (void)generalConfigureForShareButton:(UIButton *)butn {
    
    [butn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.mas_equalTo(ShareOptionsPanelOptionButtonSize);
    }];
    
    [butn setBackgroundColor:[UIColor whiteColor]];
    butn.layer.cornerRadius = ShareOptionsPanelOptionButtonSize/2;
    [butn setLayerShadow:[UIColor colorWithWhite:0 alpha:0.6] offset:CGSizeMake(0, 3) radius:3];
}

- (UIButton *)createWechatButton {
    UIButton *butn = [UIButton buttonWithType:UIButtonTypeCustom];
    [butn setImage:[UIImage imageNamed:@"share_wechat_ic"] forState:UIControlStateNormal];
    [butn addTarget:self action:@selector(wechatClick:) forControlEvents:UIControlEventTouchUpInside];
    [self generalConfigureForShareButton:butn];
    return butn;
}

- (UIButton *)createWxmomentButton {
    UIButton *butn = [UIButton buttonWithType:UIButtonTypeCustom];
    [butn setImage:[UIImage imageNamed:@"share_moment_ic"] forState:UIControlStateNormal];
    [butn addTarget:self action:@selector(wxMomentClick:) forControlEvents:UIControlEventTouchUpInside];
    [self generalConfigureForShareButton:butn];
    return butn;
}

- (UIButton *)createImportButton {
    UIButton *butn = [UIButton buttonWithType:UIButtonTypeCustom];
    [butn setImage:[UIImage imageNamed:@"share_save_ic"] forState:UIControlStateNormal];
    [butn addTarget:self action:@selector(importClick:) forControlEvents:UIControlEventTouchUpInside];
    [self generalConfigureForShareButton:butn];
    return butn;
}

- (UIButton *)createMoreButton {
    UIButton *butn = [UIButton buttonWithType:UIButtonTypeCustom];
    [butn setImage:[UIImage imageNamed:@"share_more_ic"] forState:UIControlStateNormal];
    [butn addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    [self generalConfigureForShareButton:butn];
    return butn;
}

- (void)wechatClick:(id)sender {
    if (self.wechatClickHandler) {
        self.wechatClickHandler(self);
    }
}

- (void)wxMomentClick:(id)sender {
    if (self.wx_momentClickHandler) {
        self.wx_momentClickHandler(self);
    }
}

- (void)importClick:(id)sender {
    if (self.importClickHandler) {
        self.importClickHandler(self);
    }
}

- (void)moreClick:(id)sender {
    if (self.moreClickHandler) {
        self.moreClickHandler(self);
    }
}

- (CGFloat)caculateShareOptionSpacing {
    NSUInteger optionNum = ShareOptionsPanelOptionNumber;
    CGFloat optionsWidth = optionNum*ShareOptionsPanelOptionButtonSize;
    CGFloat spacing = (self.preferredMaxLayoutWidth - optionsWidth)/(optionNum - 1);
    if (spacing > ShareOptionsPanelOptionButtonDefaultSpacing) {
        spacing = ShareOptionsPanelOptionButtonDefaultSpacing;
    }
    return spacing;
}

@end
