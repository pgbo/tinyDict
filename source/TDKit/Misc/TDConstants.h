//
//  TDConstants.h
//  tinyDict
//
//  Created by guangbool on 2017/3/23.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>


// app group 名称
extern NSString *const NameOfTDAppGroup;

// 应用偏好设置数据存放目录名
extern NSString *const DirectoryNameOfAppPrefs;

// 各类型（历史、垃圾桶、收藏）翻译记录字典（input 作为 key，translateId 为 value）的 key
extern NSString *const kTranslateInputAndIdDictionary;

// 翻译历史保存的目录名
extern NSString *const DirectoryNameOfTranslateHistory;

// 翻译记录垃圾篓保存的目录名
extern NSString *const DirectoryNameOfTranslateTrash;

// 收藏的翻译记录保存的目录名
extern NSString *const DirectoryNameOfTranslateStarred;

// 翻译语言
typedef NS_ENUM(NSInteger, TDTextTranslateLanguage) {
    TDTextTranslateLanguage_unkown  = -1,       // 未知语言
    
    // Common use
    TDTextTranslateLanguage_en      = 0,         // 英语
    TDTextTranslateLanguage_zh      = 1,         // 简体中文
    TDTextTranslateLanguage_cht     = 2,         // 繁体中文
    
    
    // ABC prefix
    TDTextTranslateLanguage_ara,                // 阿拉伯语
    TDTextTranslateLanguage_est,                // 爱沙尼亚语
    TDTextTranslateLanguage_bul,                // 保加利亞语
    TDTextTranslateLanguage_pl,                 // 波兰语
    
    // DEFG prefix
    TDTextTranslateLanguage_dan,                // 丹麦语
    TDTextTranslateLanguage_de,                 // 德语
    TDTextTranslateLanguage_ru,                 // 俄语
    TDTextTranslateLanguage_fra,                // 法语
    TDTextTranslateLanguage_fin,                // 芬兰语
    
    // HIJKLMN prefix
    TDTextTranslateLanguage_kor,                // 韩语
    TDTextTranslateLanguage_nl,                 // 荷兰语
    TDTextTranslateLanguage_cs,                 // 捷克语
    TDTextTranslateLanguage_rom,                // 罗马尼亚语
    
    // OPQRST prefix
    TDTextTranslateLanguage_pt,                 // 葡萄牙语
    TDTextTranslateLanguage_jp,                 // 日语
    TDTextTranslateLanguage_swe,                // 瑞典语
    TDTextTranslateLanguage_slo,                // 斯洛文尼亚语
    TDTextTranslateLanguage_th,                 // 泰语
    
    // UVWX prefix
    TDTextTranslateLanguage_spa,                // 西班牙语
    TDTextTranslateLanguage_el,                 // 希腊语
    TDTextTranslateLanguage_hu,                 // 匈牙利语
    
    
    // YZ prefix
    TDTextTranslateLanguage_it,                 // 意大利语
    TDTextTranslateLanguage_vie,                // 越南语
};
// Change this first and last value if need when update TDTextTranslateLanguage list
static const TDTextTranslateLanguage TDTextTranslateLanguage_available_first = TDTextTranslateLanguage_en;
static const TDTextTranslateLanguage TDTextTranslateLanguage_available_last = TDTextTranslateLanguage_vie;

extern BOOL TDTextTranslateLanguageFrom_zh_to_en(TDTextTranslateLanguage from, TDTextTranslateLanguage to);
extern BOOL TDTextTranslateLanguageFrom_cht_to_en(TDTextTranslateLanguage from, TDTextTranslateLanguage to);
extern BOOL TDTextTranslateLanguageFrom_en_to_zh(TDTextTranslateLanguage from, TDTextTranslateLanguage to);
extern BOOL TDTextTranslateLanguageFrom_en_to_cht(TDTextTranslateLanguage from, TDTextTranslateLanguage to);
extern BOOL TDTextTranslateLanguageFrom_unkown_to_unkown(TDTextTranslateLanguage from, TDTextTranslateLanguage to);
extern BOOL TDTextTranslateLanguageNotUnkown(TDTextTranslateLanguage lang);

/**
 *  翻译语言缩写的本地化结果 key
 */
extern NSString* TDLanguageShortLocalizedKeyForType(TDTextTranslateLanguage lang);

/**
 *  翻译语言完整的本地化结果 key
 */
extern NSString* TDLanguageFullLocalizedKeyForType(TDTextTranslateLanguage lang);

extern NSString *TDLanguageLocalizedComponentForType(TDTextTranslateLanguage langType);

/**
 所有的翻译语言
 */
extern NSArray<NSNumber*> *TDTextTranslateLanguage_All();

// 错误：不支持的翻译语言
extern NSInteger TDUnsupportedTranslateLanguagePairsErrorCode;
extern NSError* TDUnsupportedTranslateLanguagePairsError();

// 错误：翻译系统内部错误
extern NSInteger TDTranslateInnerErrorCode;
extern NSError* TDTranslateInnerError();

// 错误：翻译服务出错
extern NSInteger TDTranslateServiceErrorCode;
extern NSError* TDTranslateServiceError();

/**
 默认值: 「在 widget 上是否对拷贝的文本进行自动翻译」偏好
 */
extern const BOOL TDDefaultValue_translateCopyTextAutomatically;

/**
 默认值: 是否检测输入文字的语言并将文字翻译成别的语言
 */
extern const BOOL TDDefaultValue_detectInputLanguageAndTranslateOutputOther;

/**
 「翻译的输出语言的偏好列表」的最大数目
 */
extern const NSUInteger TD_preferredTranslateOutputLanguageListMaxCount;

/**
 默认值: 翻译的输出语言的偏好列表
 */
extern NSArray<NSNumber*> *TDDefaultValue_preferredTranslateOutputLanguageList();



typedef NSInteger TDTranslateServiceProvider; // 翻译服务提供商
extern const TDTranslateServiceProvider TDTranslateServiceProvider_bdfy;
extern const TDTranslateServiceProvider TDTranslateServiceProvider_hc;
extern const TDTranslateServiceProvider TDTranslateServiceProvider_aisi;

/**
 默认值: 翻译服务提供商偏好列表
 */
extern NSArray<NSNumber*> *TDDefaultValue_preferredTranslateProviderList();

/**
 常量值: 数量无限制
 */
extern const NSInteger TDNumberValue_UNLIMITED;

/**
 默认值: 记录保存数量限制
 */
extern const NSInteger TDDefaultValue_recordsLimit;

/**
 默认值: 「tapticPeek」是否开启
 */
extern const BOOL TDDefaultValue_tapticPeekOpened;


/**
 上一次拷贝的翻译信息的 key
 */
extern NSString *const kLastCopiedTranslateMeta;


/**
 翻译详情的拷贝选项偏好
 */
typedef NS_ENUM(NSUInteger, TDAppTranslateCopyOptionPreference) {
    TDAppTranslateCopyInputOnly = 0,
    TDAppTranslateCopyOutputOnly,
    TDAppTranslateCopyAll,
};

/**
 默认值: 如果在某次打开的翻译页面进行了多次翻译，是否只保存最后一次
 */
extern const BOOL TDAppDefaultValue_onlySaveLastTranslateInTranslatePage;

/**
 默认值: 翻译页面的拷贝偏好
 */
extern const TDAppTranslateCopyOptionPreference TDAppDefaultValue_preferredTranslateCopyOptionInTranslatePage;

/**
 默认值: App的分享编辑页面的「只对齐当前段落」偏好
 */
extern const BOOL TDAppDefaultValue_onlyAlignCurrentParagraph;

/**
 联系我们的 email
 */
extern NSString *const TDContactUSEmail;


/**
 去分享页面的 url 组装器
 
 @param translateId 翻译 id
 @param initialLanguage 初始显示的语言
 @return 组装后的 url
 */
extern NSURL* TDSharePageURLComposer(NSString *translateId, TDTextTranslateLanguage initialLanguage);

/**
 功能型的 Spotlight 项目的domian identifier
 */
extern NSString *const TDSpotlightFunctionSearchableItemsDomainIdentifier;

/**
 翻译记录的 Spotlight 项目的domian identifier
 */
extern NSString *const TDSpotlightTranslateRecordsSearchableItemsDomainIdentifier;

/**
 历史记录 spotlight 搜索项目 id 的包装方法

 @param baseIdentfier 原本的 id
 @return 包装后的 id
 */
extern NSString* TDSpotlightTranslateRecordsSearchableItemIdentfierWapper(NSString *baseIdentfier);

/**
 从翻译记录 spotlight 搜索项目 id 拆解获得翻译记录 id 的方法
 
 @param searchableItemIdentfier 原本的 id
 @return 翻译记录 id
 */
extern NSString* TDTranslateIdParserFromSpotlightRecordsSearchableItemIdentfier(NSString *searchableItemIdentfier);

/**
 是否为历史记录 spotlight 搜索项目的判断方法

 @param searchItemIdentfier 历史记录 spotlight id
 @return 判断结果
 */
extern BOOL TDSpotlightTranslateRecordsSearchableItemJudger(NSString *searchItemIdentfier);

