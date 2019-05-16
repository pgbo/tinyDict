//
//  NSBundle+TDApp.m
//  tinyDict
//
//  Created by guangbool on 2017/5/11.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "NSBundle+TDApp.h"
#import <TDKit/UIImage+TDKit.h>

@implementation NSBundle (TDApp)

+ (UIImage *)arrowUpIcon {
    return [[self arrowLeftIcon] imageByRotateRight90];
}

+ (UIImage *)arrowDownIcon {
    return [[self arrowLeftIcon] imageByRotateLeft90];
}

+ (UIImage *)arrowLeftIcon {
    return [UIImage imageNamed:@"back_ic"];
}

+ (UIImage *)arrowRightIcon {
    return [[self arrowLeftIcon] imageByFlipHorizontal];
}

@end
