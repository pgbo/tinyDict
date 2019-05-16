//
//  ShareOptionsPanel.h
//  tinyDict
//
//  Created by guangbool on 2017/5/17.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareOptionsPanel : UIView

@property (nonatomic, copy) void(^wechatClickHandler)(ShareOptionsPanel *panel);
@property (nonatomic, copy) void(^wx_momentClickHandler)(ShareOptionsPanel *panel);
@property (nonatomic, copy) void(^importClickHandler)(ShareOptionsPanel *panel);
@property (nonatomic, copy) void(^moreClickHandler)(ShareOptionsPanel *panel);

// The preferred maximum width (in points) for the panel.
@property (nonatomic, assign) CGFloat preferredMaxLayoutWidth;

- (CGSize)intrinsicContentSize;

@end
