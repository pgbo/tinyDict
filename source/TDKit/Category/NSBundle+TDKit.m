//
//  NSBundle+TDKit.m
//  tinyDict
//
//  Created by guangbool on 2017/4/7.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "NSBundle+TDKit.h"
#import "TDPrefs.h"

@implementation NSBundle (TDKit)

+ (NSBundle *)tdkit {
    static NSBundle *tdkitBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tdkitBundle = [NSBundle bundleForClass:[TDPrefs class]];
    });
    return tdkitBundle;
}

@end
