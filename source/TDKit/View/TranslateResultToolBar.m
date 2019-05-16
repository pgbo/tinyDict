//
//  TranslateResultToolBar.m
//  tinyDict
//
//  Created by guangbool on 2017/4/28.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TranslateResultToolBar.h"
#import <TDKit/WDScrollableSegmentedControl.h>
#import <TDKit/TDSpecs.h>
#import <TDKit/Masonry.h>
#import <TDKit/UIImage+TDKit.h>
#import <TDKit/NSBundle+TDKit.h>

static CGFloat TranslateResultToolBar_languageListGradientLayerWidth = 20.f;

@interface TranslateResultToolBar () <WDScrollableSegmentedControlDelegate>

@property (nonatomic, copy) NSArray<NSString *> *outputLanguages;

@property (nonatomic, weak) IBOutlet WDScrollableSegmentedControl *languageListView;

@property (nonatomic, weak) IBOutlet UIView *operateOptionsStackContainer;
@property (nonatomic, weak) IBOutlet UIStackView *operateOptionsStack;
@property (nonatomic, weak) IBOutlet UIButton *starButn;
@property (nonatomic, weak) IBOutlet UIButton *shareButn;
@property (nonatomic, weak) IBOutlet UIButton *copyyButn;
@property (nonatomic, weak) IBOutlet UIButton *trashButn;

@property (nonatomic) UILabel *copiedTipLabel;
@property (nonatomic, strong) CAGradientLayer *languageListGradientLayer;

@end

@implementation TranslateResultToolBar

+ (instancetype)fromNibWithOutputLanguages:(NSArray<NSString *> *)outputLanguages {
    TranslateResultToolBar *item = [[UINib nibWithNibName:@"TranslateResultToolBar" bundle:[NSBundle tdkit]] instantiateWithOwner:nil options:0].firstObject;
    item.outputLanguages = outputLanguages;
    return item;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configures];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLanguageListGradientLayerFrame];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    [_languageListGradientLayer setColors:@[(id)[self.backgroundColor colorWithAlphaComponent:0.2].CGColor, (id)self.backgroundColor.CGColor]];
}

- (void)configures {
    
    NSBundle *bundle = [NSBundle tdkit];
    [self.starButn setImage:[UIImage imageNamed:@"star_ic" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.shareButn setImage:[UIImage imageNamed:@"share_ic" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.copyyButn setImage:[UIImage imageNamed:@"copy_ic" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.trashButn setImage:[UIImage imageNamed:@"trash_ic" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    self.languageListView.indicatorHeight = 0;
    self.languageListView.buttonColor = [TDColorSpecs app_mainTextColor];
    self.languageListView.buttonHighlightColor = [TDColorSpecs app_mainTextColor];
    self.languageListView.buttonSelectedColor = [TDColorSpecs app_tint];
    self.languageListView.font = [TDFontSpecs regular];
    self.languageListView.delegate = self;
    self.languageListView.buttons = self.outputLanguages;
    self.languageListView.selectedIndex = self.selectionOutputLanguageIndex;
    
    self.operateOptionsStackContainer.layer.masksToBounds = YES;
    self.operateOptionsStackContainer.layer.cornerRadius = 4;
    self.operateOptionsStackContainer.layer.borderColor = [TDColorSpecs app_separator].CGColor;
    self.operateOptionsStackContainer.layer.borderWidth = 0.5f;
    
    [self.starButn addTarget:self action:@selector(starClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButn addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.copyyButn addTarget:self action:@selector(copyyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.trashButn addTarget:self action:@selector(trashClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.layer addSublayer:self.languageListGradientLayer];
    [self updateLanguageListGradientLayerFrame];
}

- (void)setOutputLanguages:(NSArray<NSString *> *)outputLanguages {
    _outputLanguages = [outputLanguages copy];
    self.languageListView.buttons = outputLanguages;
}

- (void)starClick:(id)sender {
    if (self.starOperateItemClickBlock) {
        self.starOperateItemClickBlock(self);
    }
}

- (void)shareClick:(id)sender {
    if (self.shareOperateItemClickBlock) {
        self.shareOperateItemClickBlock(self);
    }
}

- (void)copyyClick:(id)sender {
    if (self.copyyOperateItemClickBlock) {
        self.copyyOperateItemClickBlock(self);
    }
    [self toggleCopiedTipLableHiddenState];
}

- (void)trashClick:(id)sender {
    if (self.trashOperateItemClickBlock) {
        self.trashOperateItemClickBlock(self);
    }
}

- (void)toggleCopiedTipLableHiddenState {
    
    if (!self.copiedTipLabel.superview) {
        self.copiedTipLabel.alpha = 0;
        [self addSubview:self.copiedTipLabel];
    }
    
    CGPoint centerAtRoot = [self.copyyButn.superview convertPoint:self.copyyButn.center toView:self];
    __weak typeof(self)weakSelf = self;
    [self.copiedTipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.mas_leading).offset(centerAtRoot.x);
        make.centerY.equalTo(weakSelf.mas_top).offset(centerAtRoot.y);
    }];
    self.copiedTipLabel.center = centerAtRoot;
    
    BOOL labelHidden = (_copiedTipLabel.alpha == 0);
    void(^animation)() = ^{
        if (labelHidden) {
            self.copiedTipLabel.alpha = 1;
            self.copyyButn.alpha = 0;
        } else {
            self.copiedTipLabel.alpha = 0;
            self.copyyButn.alpha = 1;
        }
    };
    
    [UIView animateWithDuration:0.2
                     animations:animation
                     completion:^(BOOL finished) {
                         if (labelHidden) {
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 if (!weakSelf) return;
                                 [weakSelf toggleCopiedTipLableHiddenState];
                             });
                         }
                     }];
}

- (UILabel *)copiedTipLabel {
    if (!_copiedTipLabel) {
        _copiedTipLabel = [[UILabel alloc] init];
        _copiedTipLabel.text = NSLocalizedStringFromTable(@"copied", @"TDBundle", nil);
        _copiedTipLabel.textColor = [TDColorSpecs wd_mainTextColor];
        _copiedTipLabel.font = [TDFontSpecs tiny];
    }
    return _copiedTipLabel;
}

- (CAGradientLayer *)languageListGradientLayer {
    if (!_languageListGradientLayer) {
        CAGradientLayer *gradLayer = [CAGradientLayer layer];
        gradLayer.bounds = CGRectMake(0, 0, TranslateResultToolBar_languageListGradientLayerWidth, 44);
        [gradLayer setColors:@[(id)[self.backgroundColor colorWithAlphaComponent:0.2].CGColor, (id)self.backgroundColor.CGColor]];
        gradLayer.locations = @[@(0), @(1)];
        gradLayer.startPoint = CGPointMake(0, 0.5);
        gradLayer.endPoint = CGPointMake(1, 0.5);
        gradLayer.name = NSStringFromSelector(@selector(languageListGradientLayer));
        _languageListGradientLayer = gradLayer;
    }
    return _languageListGradientLayer;
}

- (void)updateLanguageListGradientLayerFrame {
    if (_languageListView) {
        CGRect langListViewFrame = _languageListView.frame;
        _languageListGradientLayer.frame = CGRectMake(CGRectGetMaxX(langListViewFrame) - TranslateResultToolBar_languageListGradientLayerWidth, 0, TranslateResultToolBar_languageListGradientLayerWidth, CGRectGetHeight(langListViewFrame));
    }
}

- (void)setSelectionOutputLanguageIndex:(NSUInteger)selectionOutputLanguageIndex {
    NSAssert(selectionOutputLanguageIndex < self.outputLanguages.count, @"index is out of outputLanguages max bounds.");
    _selectionOutputLanguageIndex = selectionOutputLanguageIndex;
    [_languageListView setSelectedIndex:selectionOutputLanguageIndex];
}

- (void)setItemStarred:(BOOL)starred {
    _isItemStarred = starred;
    
    UIImage *ic = [UIImage imageNamed:@"star_ic" inBundle:[NSBundle tdkit] compatibleWithTraitCollection:nil];
    if (starred) {
        ic = [ic imageByTintColor:[TDColorSpecs remindColor]];
    }
    [self.starButn setImage:ic forState:UIControlStateNormal];
}

#pragma mark - WDScrollableSegmentedControlDelegate

- (void)didSelectButtonAtIndex:(NSInteger)index {
    if (self.outputLanguageItemSelectionBlock) {
        self.outputLanguageItemSelectionBlock(self, index);
    }
}

@end
