//
//  TranslateBottomBar.h
//  tinyDict
//
//  Created by guangbool on 2017/5/5.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TranslateBottomBar : UIView

@property (nonatomic, copy) void(^translateHandler)(TranslateBottomBar *bar);
@property (nonatomic, copy) void(^cancelHandler)(TranslateBottomBar *bar);

@end
