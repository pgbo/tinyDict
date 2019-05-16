//
//  TodayItemBriefViewController.m
//  tinyDict
//
//  Created by guangbool on 2017/4/17.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TodayItemBriefViewController.h"
#import <TDKit/TDKit.h>

@interface TodayItemBriefViewController ()

@property (nonatomic, copy) NSString *input;
@property (nonatomic) UILabel *displayLabel;

@end

@implementation TodayItemBriefViewController

- (instancetype)initWithInput:(NSString *)input {
    if (self = [super init]) {
        self.input = input;
    }
    return self;
}

- (UILabel *)displayLabel {
    if (!_displayLabel) {
        _displayLabel = [[UILabel alloc] init];
        _displayLabel.numberOfLines = 0;
        _displayLabel.font = [TDFontSpecs largeBold];
        _displayLabel.textColor = [TDColorSpecs wd_mainTextColor];
        _displayLabel.textAlignment = NSTextAlignmentCenter;
        _displayLabel.lineBreakMode = NSLineBreakByClipping;
    }
    return _displayLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.displayLabel];
    [self.displayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo([TDPadding regular]);
        make.bottom.mas_equalTo((-1)*[TDPadding regular]);
        make.leading.mas_equalTo([TDPadding regular]);
        make.trailing.mas_equalTo((-1)*[TDPadding regular]);
    }];
    
    self.displayLabel.text = self.input;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.displayLabel.preferredMaxLayoutWidth = (CGRectGetWidth(self.view.bounds) - [TDPadding regular]*2);
}

@end
