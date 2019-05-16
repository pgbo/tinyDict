//
//  TDSpecs.h
//  tinyDict
//
//  Created by guangbool on 2017/4/7.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TDColorSpecs;
@class TDFontSizeSpecs;
@class TDFontSpecs;

/**
 UI specs
 */

@interface TDColorSpecs : NSObject

+ (UIColor *)wd_tint;
+ (UIColor *)wd_separator;
+ (UIColor *)wd_mainTextColor;
+ (UIColor *)wd_minorTextColor;

+ (UIColor *)app_tint;
+ (UIColor *)app_pageBackground;
+ (UIColor *)app_separator;
+ (UIColor *)app_mainTextColor;
+ (UIColor *)app_minorTextColor;
+ (UIColor *)app_cellColor;

+ (UIColor *)remindColor;

@end

@interface TDFontSizeSpecs : NSObject

+ (CGFloat)tiny;
+ (CGFloat)small;
+ (CGFloat)regular;
+ (CGFloat)large;

@end

@interface TDFontSpecs : NSObject

+ (UIFont *)tiny;
+ (UIFont *)small;
+ (UIFont *)regular;
+ (UIFont *)large;
+ (UIFont *)tinyBold;
+ (UIFont *)smallBold;
+ (UIFont *)regularBold;
+ (UIFont *)largeBold;

@end


/**
 widget 上的 padding
 */
@interface TDPadding : NSObject

+ (CGFloat)tiny;
+ (CGFloat)small;
+ (CGFloat)regular;
+ (CGFloat)large;
+ (CGFloat)extra;

@end

@interface TDHeight : NSObject

+ (CGFloat)app_prefsCellHeight;
+ (CGFloat)app_bottomBarHeight;

@end


