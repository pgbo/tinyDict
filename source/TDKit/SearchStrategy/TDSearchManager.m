//
//  TDSearchManager.m
//  tinyDict
//
//  Created by guangbool on 2017/3/28.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TDSearchManager.h"
#import <TDKit/YDSearch.h>
#import <TDKit/YDFYSearch.h>
#import <TDKit/EUSearch.h>
#import <TDKit/ICBSearch.h>
#import <TDKit/HCSearch.h>
#import <TDKit/BingDictSearch.h>
#import <TDKit/BDFYSearch.h>
#import <TDKit/AISISearch.h>
#import <TDKit/ZNSearch.h>
#import <TDKit/NSString+TDKit.h>
#import <objc/runtime.h>
#import "TDPrefs.h"
#import "TDTranslatorFactory.h"

@implementation TDSearchManager

- (void)searchForText:(NSString *)text
         suggestLimit:(NSUInteger)suggestLimit
      completeHandler:(TDSearchCompleteHandler)completeHandler {
    [[self getSearcher] searchForText:text suggestLimit:suggestLimit completeHandler:completeHandler];
}

- (id<TDSearchStrategy>)getSearcher {
    
    // TODO: 根据 configuration 来 init searcher
    
    id<TDSearchStrategy> searcher;
    searcher = [[YDSearch alloc] init];
    //    searcher = [[YDFYSearch alloc] init];
    //    searcher = [[EUSearch alloc] init];
    //        searcher = [[ICBSearch alloc] init];
    //    searcher = [[HCSearch alloc] init];
    //    searcher = [[BingDictSearch alloc] init];
    //    searcher = [[BDFYSearch alloc] init];
    //    searcher = [[AISISearch alloc] init];
    //        searcher = [[ZNSearch alloc] init];
    return searcher;
}

@end

@implementation TDSearchManager (TDTranslate)

- (NSArray<id<TDTranslateStrategy>> *)preferredTranslators {
    
    NSArray<NSNumber *> *preferredTranslateProviders = [TDPrefs shared].preferredTranslateProviderList;
    if (preferredTranslateProviders.count == 0) {
        preferredTranslateProviders = TDDefaultValue_preferredTranslateProviderList();
    }
    
    NSMutableArray<id<TDTranslateStrategy>> *translators = [NSMutableArray<id<TDTranslateStrategy>> array];
    for (NSNumber *providerCode in preferredTranslateProviders) {
        id<TDTranslateStrategy> translator = [TDTranslatorFactory translatorWithProviderCode:[providerCode integerValue]];
        if (translator) {
            [translators addObject:translator];
        }
    }
    
    return translators;
}

- (TDTextTranslateLanguage)preferredTranslateOutputLanguageForInputText:(NSString *)inputText
                                                   defaultInputLanguage:(TDTextTranslateLanguage)defaultInputLanguage{
    // 根据 设置 获取 是否检测输入语言并翻译成别的语言
    NSNumber *isDetectInputLang = [TDPrefs shared].detectInputLanguageAndTranslateOutputOther;
    if (!isDetectInputLang) {
        isDetectInputLang = @(TDDefaultValue_detectInputLanguageAndTranslateOutputOther);
    }
    
    //  根据 设置 获取 输出语言优先列表
    NSArray<NSNumber *> *preferredOutputLangList = [TDPrefs shared].preferredTranslateOutputLanguageList;
    if (preferredOutputLangList.count == 0) {
        preferredOutputLangList = TDDefaultValue_preferredTranslateOutputLanguageList();
    }
    
    TDTextTranslateLanguage outputLang = TDTextTranslateLanguage_unkown;
    if ([isDetectInputLang boolValue]) {
        TDTextTranslateLanguage detectInputLang;
        if (defaultInputLanguage == TDTextTranslateLanguage_unkown) {
            NSUInteger englishTagsNum, otherTagsNum;
            [inputText detectLanguagesWithEnglishTagsNum:&englishTagsNum otherTagsNum:&otherTagsNum];
            detectInputLang = (englishTagsNum > otherTagsNum)?TDTextTranslateLanguage_en:TDTextTranslateLanguage_unkown;
        } else {
            detectInputLang = defaultInputLanguage;
        }
        
        for (NSNumber *item in preferredOutputLangList) {
            TDTextTranslateLanguage itemLang = [item integerValue];
            if (itemLang != TDTextTranslateLanguage_unkown && itemLang != detectInputLang) {
                outputLang = itemLang;
                break;
            }
        }
        
    } else {
        outputLang = [preferredOutputLangList.firstObject integerValue];
    }
    
    return outputLang;
}

#pragma mark - TDTranslateStrategy

- (void)translateForText:(NSString *)text
                    from:(TDTextTranslateLanguage)from
                      to:(TDTextTranslateLanguage)to
         completeHandler:(TDTranslateCompleteHandler)completeHandler {
    
    TDTextTranslateLanguage targetLanguage = to;
    if (to == TDTextTranslateLanguage_unkown) {
        targetLanguage = [self preferredTranslateOutputLanguageForInputText:text defaultInputLanguage:from];
    }
    
    NSArray<id<TDTranslateStrategy>> *preferredTranslators = [self preferredTranslators];
    id<TDTranslateStrategy> translator = nil;
    for (id<TDTranslateStrategy> t in preferredTranslators) {
        if ([[t class] supportTranslateWithFrom:from to:targetLanguage]) {
            translator = t;
            break;
        }
    }
    if (!translator) {
        TDTranslateItem *translateItem = [[TDTranslateItem alloc] initWithInput:text inputLang:from outputLang:to];
        if (completeHandler) {
            completeHandler(translateItem, TDUnsupportedTranslateLanguagePairsError(), nil);
        }
        return;
    }
    
    [translator translateForText:text from:from to:targetLanguage completeHandler:^(TDTranslateItem *translateItem, NSError *error, NSString *serviceProvider) {
        if (completeHandler) {
            translateItem.outputLang = to;
            completeHandler(translateItem, error, serviceProvider);
        }
    }];
}

+ (BOOL)supportTranslateWithFrom:(TDTextTranslateLanguage)from to:(TDTextTranslateLanguage)to {
    return YES;
}

@end
