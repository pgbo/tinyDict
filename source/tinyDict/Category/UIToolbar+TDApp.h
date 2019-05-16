//
//  UIToolbar+TDApp.h
//  TDApp
//
//  Created by guangbool on 2016/10/26.
//  Copyright © 2016年 Formax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIToolbar (TDApp)

/**
 *  toolbar 带一个右按钮
 */
+ (UIToolbar *)td_createToolbarWithRightItemForTitle:(NSString *)title
                                              target:(id)target
                                              action:(SEL)action;

@end
