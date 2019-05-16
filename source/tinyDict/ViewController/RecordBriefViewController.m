//
//  RecordBriefViewController.m
//  tinyDict
//
//  Created by guangbool on 2017/4/26.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "RecordBriefViewController.h"
#import <TDKit/TDKit.h>

@interface RecordBriefViewController ()

@property (nonatomic, copy) NSString *input;
@property (nonatomic) UILabel *displayLabel;

@end

@implementation RecordBriefViewController

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
        _displayLabel.font = [TDFontSpecs large];
        _displayLabel.textColor = [TDColorSpecs wd_mainTextColor];
        _displayLabel.textAlignment = NSTextAlignmentCenter;
        _displayLabel.lineBreakMode = NSLineBreakByClipping;
    }
    return _displayLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.displayLabel];
    [self.displayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo([TDPadding large]);
        make.bottom.mas_equalTo((-1)*[TDPadding large]);
        make.leading.mas_equalTo([TDPadding large]);
        make.trailing.mas_equalTo((-1)*[TDPadding large]);
    }];
    
    self.displayLabel.text = self.input;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.displayLabel.preferredMaxLayoutWidth = (CGRectGetWidth(self.view.bounds) - [TDPadding large]*2);
}

@end
