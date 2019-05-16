//
//  TDSpecs.m
//  tinyDict
//
//  Created by guangbool on 2017/4/7.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TDSpecs.h"
#import "UIColor+TDKit.h"


/**
 UI specs
 */

@implementation TDColorSpecs

+ (UIColor *)wd_tint {
    static UIColor *tint = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tint = [UIColor colorWithRGB:0x4A4A4A];
    });
    return tint;
}

+ (UIColor *)wd_separator {
    static UIColor *separator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        separator = [UIColor colorWithRGB:0x777777 alpha:0.6];
    });
    return separator;
}

+ (UIColor *)wd_mainTextColor {
    static UIColor *mainTextColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainTextColor = [UIColor colorWithRGB:0x282828];
    });
    return mainTextColor;
}

+ (UIColor *)wd_minorTextColor {
    static UIColor *minorTextColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        minorTextColor = [UIColor colorWithRGB:0x777777];
    });
    return minorTextColor;
}

+ (UIColor *)app_tint {
    static UIColor *app_tint = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_tint = [UIColor colorWithRGB:0x4990E2];
    });
    return app_tint;
}

+ (UIColor *)app_pageBackground {
    static UIColor *app_pageBackground = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_pageBackground = [UIColor colorWithRGB:0xe8ecf0];
    });
    return app_pageBackground;
}

+ (UIColor *)app_separator {
    static UIColor *app_separator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_separator = [UIColor colorWithRGB:0xC8C7C7];
    });
    return app_separator;
}

+ (UIColor *)app_mainTextColor {
    return [self wd_mainTextColor];
}

+ (UIColor *)app_minorTextColor {
    return [self wd_minorTextColor];
}

+ (UIColor *)app_cellColor {
    static UIColor *app_cellColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app_cellColor = [UIColor whiteColor];
    });
    return app_cellColor;
}

+ (UIColor *)remindColor {
    static UIColor *remindColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        remindColor = [UIColor colorWithRGB:0xC0350C];
    });
    return remindColor;
}

@end

@implementation TDFontSizeSpecs

+ (CGFloat)tiny {
    return 10;
}

+ (CGFloat)small {
    return 12;
}

+ (CGFloat)regular {
    return 14;
}

+ (CGFloat)large {
    return 16;
}

@end

@implementation TDFontSpecs

static NSString *const TDFontSpecsRegularName = @"Lato-Regular";
static NSString *const TDFontSpecsBoldName = @"Lato-Bold";

+ (UIFont *)tiny {
    static UIFont *tinyFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tinyFont = [UIFont fontWithName:TDFontSpecsRegularName size:[TDFontSizeSpecs tiny]];
    });
    return tinyFont;
}

+ (UIFont *)small {
    static UIFont *smallFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        smallFont = [UIFont fontWithName:TDFontSpecsRegularName size:[TDFontSizeSpecs small]];
    });
    return smallFont;
}

+ (UIFont *)regular {
    static UIFont *regularFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regularFont = [UIFont fontWithName:TDFontSpecsRegularName size:[TDFontSizeSpecs regular]];
    });
    return regularFont;
}

+ (UIFont *)large {
    static UIFont *largeFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        largeFont = [UIFont fontWithName:TDFontSpecsRegularName size:[TDFontSizeSpecs large]];
    });
    return largeFont;
}

+ (UIFont *)tinyBold {
    static UIFont *tinyBoldFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tinyBoldFont = [UIFont fontWithName:TDFontSpecsBoldName size:[TDFontSizeSpecs tiny]];
    });
    return tinyBoldFont;
}

+ (UIFont *)smallBold {
    static UIFont *smallBoldFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        smallBoldFont = [UIFont fontWithName:TDFontSpecsBoldName size:[TDFontSizeSpecs small]];
    });
    return smallBoldFont;
}

+ (UIFont *)regularBold {
    static UIFont *regularBoldFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regularBoldFont = [UIFont fontWithName:TDFontSpecsBoldName size:[TDFontSizeSpecs regular]];
    });
    return regularBoldFont;
}

+ (UIFont *)largeBold {
    static UIFont *largeBoldFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        largeBoldFont = [UIFont fontWithName:TDFontSpecsBoldName size:[TDFontSizeSpecs large]];
    });
    return largeBoldFont;
}

@end

@implementation TDPadding

+ (CGFloat)tiny {
    return 4.f;
}

+ (CGFloat)small {
    return 8.f;
}

+ (CGFloat)regular {
    return 12.f;
}

+ (CGFloat)large {
    return 16.f;
}

+ (CGFloat)extra {
    return 20.f;
}

@end

@implementation TDHeight

+ (CGFloat)app_prefsCellHeight {
    return 44.f;
}

+ (CGFloat)app_bottomBarHeight {
    return 44.f;
}

@end
