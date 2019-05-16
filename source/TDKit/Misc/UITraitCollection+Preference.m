//
//  UITraitCollection+Preference.m
//  tinyDict
//
//  Created by guangbool on 2017/7/14.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "UITraitCollection+Preference.h"
#import <TDKit/UITraitCollection+TDKit.h>
#import <TDKit/TDConstants.h>
#import <TDKit/TDPrefs.h>

@implementation UITraitCollection (Preference)

- (BOOL)tapticPeekIfPossible {
    
    NSNumber *opened = [TDPrefs shared].tapticPeekOpened;
    if (!opened) opened = @(TDDefaultValue_tapticPeekOpened);
    
    if ([opened boolValue]) {
        return [self tapticPeekVibrate];
    }
    return NO;
}

@end
