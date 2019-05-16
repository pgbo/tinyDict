//
//  TDPrefs.h
//  tinyDict
//
//  Created by guangbool on 2017/3/31.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDPrefs : NSObject

+ (instancetype)shared;

/**
 「在 widget 上是否对拷贝的文本进行自动翻译」偏好(类型：BOOL)
 */
@property (nonatomic) NSNumber *translateCopyTextAutomatically;

/**
 是否检测输入文字的语言并将文字翻译成别的语言
 */
@property (nonatomic, assign) NSNumber *detectInputLanguageAndTranslateOutputOther;

/**
 翻译的输出语言的偏好列表，排在前的优先级更高
 */
@property (nonatomic, copy) NSArray<NSNumber *> *preferredTranslateOutputLanguageList;

/**
 翻译服务提供商偏好列表，排在前的优先级更高
 */
@property (nonatomic, copy) NSArray<NSNumber *> *preferredTranslateProviderList;


/**
 记录保存数目限制(类型：NSInteger)
 */
@property (nonatomic) NSNumber *recordsLimit;

/**
 「tapticPeek」是否开启
 */
@property (nonatomic) NSNumber *tapticPeekOpened;

/**
 如果在App的某次打开的翻译页面进行了多次翻译，是否只保存最后一次(类型：BOOL)
 */
@property (nonatomic) NSNumber *onlySaveLastTranslateInAppTranslatePage;

/**
 App的翻译页面的拷贝偏好(类型：NSInteger)
 */
@property (nonatomic) NSNumber *preferredTranslateCopyOptionInAppTranslatePage;

/**
 App的分享编辑页面的「只对齐当前段落」偏好(类型：BOOL)
 */
@property (nonatomic) NSNumber *onlyAlignCurrentParagraph;

@end
