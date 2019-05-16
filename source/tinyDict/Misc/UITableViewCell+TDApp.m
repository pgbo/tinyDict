//
//  UITableViewCell+TDApp.m
//  tinyDict
//
//  Created by guangbool on 2017/5/22.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "UITableViewCell+TDApp.h"
#import <TDKit/TDSpecs.h>

@implementation UITableViewCell (TDApp)

- (void)textLabelConfigureDefault {
    self.textLabel.font = [TDFontSpecs large];
    self.textLabel.textColor = [TDColorSpecs app_mainTextColor];
    self.textLabel.numberOfLines = 1;
}

- (void)detailLabelConfigureDefault {
    self.detailTextLabel.font = [TDFontSpecs regular];
    self.detailTextLabel.textColor = [TDColorSpecs app_minorTextColor];
    self.detailTextLabel.numberOfLines = 0;
}

@end
