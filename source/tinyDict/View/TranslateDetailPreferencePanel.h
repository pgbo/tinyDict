//
//  TranslateDetailPreferencePanel.h
//  tinyDict
//
//  Created by guangbool on 2017/5/9.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TDKit/TDConstants.h>

@interface TranslateDetailPreferencePanel : UIView

@property (nonatomic, assign) BOOL onlySaveLastTranslateOn;
@property (nonatomic, assign) TDAppTranslateCopyOptionPreference selectOption;

@property (nonatomic, copy) void(^onlySaveLastTranslateToggleBlock)(UIView *panel, BOOL isOn);
@property (nonatomic, copy) void(^preferredCopyOptionSelectionBlock)(UIView *panel, TDAppTranslateCopyOptionPreference selectedOption);

// 最大本身高度
@property (nonatomic, assign) CGFloat maxIntrinsicContentHeight;

- (CGSize)intrinsicContentSize;

@end
