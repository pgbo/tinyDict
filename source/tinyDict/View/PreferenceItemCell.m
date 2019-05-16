//
//  PreferenceItemCell.m
//  tinyDict
//
//  Created by guangbool on 2017/4/27.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "PreferenceItemCell.h"
#import <TDKit/TDSpecs.h>
#import "UITableViewCell+TDApp.h"

@interface PreferenceItemCell ()

@property (nonatomic) UISwitch *acc_switch;

@property (nonatomic) PreferenceItemCellModel *model;

@end

@implementation PreferenceItemCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    return [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        [self configureViews];
    }
    return self;
}

- (UISwitch *)acc_switch {
    if (!_acc_switch) {
        _acc_switch = [[UISwitch alloc] init];
        _acc_switch.onTintColor = [TDColorSpecs app_tint];
        [_acc_switch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _acc_switch;
}

// Override `systemLayoutSizeFittingSize:withHorizontalFittingPriority:verticalFittingPriority:`
// Caculate cell height automatically
// Detail: http://stackoverflow.com/questions/36587126/autolayout-ignores-multi-line-detailtextlabel-when-calculating-uitableviewcell-h
- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize
        withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority
              verticalFittingPriority:(UILayoutPriority)verticalFittingPriority
{
    [self layoutIfNeeded];
    CGSize size = [super systemLayoutSizeFittingSize:targetSize
                       withHorizontalFittingPriority:horizontalFittingPriority
                             verticalFittingPriority:verticalFittingPriority];
    CGFloat detailHeight = CGRectGetHeight(self.detailTextLabel.frame);
    if (detailHeight) { // if no detailTextLabel (eg style = Default) then no adjustment necessary
        // Determine UITableViewCellStyle by looking at textLabel vs detailTextLabel layout
        if (CGRectGetMinX(self.detailTextLabel.frame) > CGRectGetMinX(self.textLabel.frame)) { // style = Value1 or Value2
            CGFloat textHeight = CGRectGetHeight(self.textLabel.frame);
            // If detailTextLabel taller than textLabel then add difference to cell height
            if (detailHeight > textHeight) size.height += detailHeight - textHeight;
        } else { // style = Subtitle, so always add subtitle height
            size.height += detailHeight;
        }
    }
    return size;
}

- (void)configureViews {
    
    self.backgroundColor = [TDColorSpecs app_cellColor];
    
    [self textLabelConfigureDefault];
    self.textLabel.numberOfLines = 0;
    [self detailLabelConfigureDefault];
}

- (void)switchValueChanged:(UISwitch *)s {
    if (self.switchValueChangedBlock) {
        self.switchValueChangedBlock(self, s.on);
    }
}

- (void)setSwitchOn:(BOOL)switchOn {
    _switchOn = switchOn;
    _acc_switch.on = switchOn;
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    if (self.model.type == PreferenceTypeCheckmark) {
        self.accessoryType = self.checked?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    }
}

- (void)configureWithModel:(PreferenceItemCellModel *)model {
    
    self.model = model;
    
    if (model.type == PreferenceTypeCheckmark) {
        self.accessoryType = self.checked?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if (model.type == PreferenceTypeSwitch) {
        self.accessoryView = self.acc_switch;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (model.type == PreferenceTypeMovable) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    self.textLabel.text = model.title;
    self.detailTextLabel.text = model.subTitle;
}

@end

@implementation PreferenceItemCellModel

@end
