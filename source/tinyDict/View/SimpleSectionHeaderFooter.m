//
//  SimpleSectionHeaderFooter.m
//  tinyDict
//
//  Created by guangbool on 2017/5/27.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "SimpleSectionHeaderFooter.h"
#import <TDKit/TDSpecs.h>
#import <TDKit/Masonry.h>

@interface SimpleSectionHeaderFooter ()
@property (nonatomic) UILabel *label;
@end

@implementation SimpleSectionHeaderFooter

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

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self configureViews];
    }
    return self;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = [TDColorSpecs app_minorTextColor];
        _label.font = [TDFontSpecs regular];
        _label.numberOfLines = 0;
    }
    return _label;
}

- (void)configureViews {
    [self addSubview:self.label];
    __weak typeof(self)weakSelf = self;
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.textEdgeInset);
    }];
}

- (void)setTextEdgeInset:(UIEdgeInsets)textEdgeInset {
    _textEdgeInset = textEdgeInset;
    [_label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(textEdgeInset);
    }];
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    _label.text = text;
}

@end
