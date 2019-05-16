//
//  TDTranslatorFactory.m
//  tinyDict
//
//  Created by guangbool on 2017/3/31.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TDTranslatorFactory.h"
#import "NSBundle+TDKit.h"

@implementation TDTranslatorFactory

+ (id<TDTranslateStrategy>)translatorWithProviderCode:(NSInteger)providerCode {
    
    static NSDictionary *translatorProviders = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        translatorProviders = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle tdkit] URLForResource:@"TDTranslatorProviders" withExtension:@"plist"]];
    });
    
    NSString *providerClassName = translatorProviders[@(providerCode).stringValue];
    if (!providerClassName) return nil;
    
    Class providerClasss = NSClassFromString(providerClassName);
    if (!providerClasss || ![providerClasss conformsToProtocol:@protocol(TDTranslateStrategy)]) {
        return nil;
    }
    return [[providerClasss alloc] init];
}

@end
