//
//  UIToolbar+TDApp.m
//  TDApp
//
//  Created by guangbool on 2016/10/26.
//  Copyright © 2016年 Formax. All rights reserved.
//

#import "UIToolbar+TDApp.h"
#import <TDKit/TDSpecs.h>

@implementation UIToolbar (TDApp)

+ (UIToolbar *)td_createToolbarWithRightItemForTitle:(NSString *)title
                                              target:(id)target
                                              action:(SEL)action {
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    toolBar.translucent = NO;
    toolBar.barTintColor = [UIColor whiteColor];
    
    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *actionItem = [[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
    
    UIColor *textColor = [TDColorSpecs app_tint];
    
    NSDictionary *titleTextAttributes = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal];
    if (titleTextAttributes.count > 0) {
        NSMutableDictionary *newAttrs = [NSMutableDictionary dictionaryWithDictionary:titleTextAttributes];
        newAttrs[NSForegroundColorAttributeName] = textColor;
        [actionItem setTitleTextAttributes:newAttrs forState:UIControlStateNormal];
    } else {
        [actionItem setTintColor:textColor];
    }
    
    toolBar.items = @[flexibleSpaceItem, actionItem];
    return toolBar;
}

@end
