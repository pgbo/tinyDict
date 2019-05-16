//
//  TDConstants.m
//  tinyDict
//
//  Created by guangbool on 2017/3/23.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TDConstants.h"

// app group 名称
NSString *const NameOfTDAppGroup = @"group.com.devbool.ttranslator";

NSString *const DirectoryNameOfAppPrefs = @"prefs";


// 各类型（历史、垃圾桶、收藏）翻译记录字典（input 作为 key，translateId 为 value）的 key
NSString *const kTranslateInputAndIdDictionary = @"kTranslateInputAndIdDictionary";

// 翻译历史保存的目录名
NSString *const DirectoryNameOfTranslateHistory = @"translateHistory";

// 翻译记录垃圾篓保存的目录名
NSString *const DirectoryNameOfTranslateTrash = @"translateTrash";

// 收藏的翻译记录保存的目录名
NSString *const DirectoryNameOfTranslateStarred = @"translateStarred";


BOOL TDTextTranslateLanguageFrom_zh_to_en(TDTextTranslateLanguage from, TDTextTranslateLanguage to) {
    return (from == TDTextTranslateLanguage_zh && to == TDTextTranslateLanguage_en);
};

BOOL TDTextTranslateLanguageFrom_cht_to_en(TDTextTranslateLanguage from, TDTextTranslateLanguage to) {
    return (from == TDTextTranslateLanguage_cht && to == TDTextTranslateLanguage_en);
};

BOOL TDTextTranslateLanguageFrom_en_to_zh(TDTextTranslateLanguage from, TDTextTranslateLanguage to) {
    return (from == TDTextTranslateLanguage_en && to == TDTextTranslateLanguage_zh);
};

BOOL TDTextTranslateLanguageFrom_en_to_cht(TDTextTranslateLanguage from, TDTextTranslateLanguage to) {
    return (from == TDTextTranslateLanguage_en && to == TDTextTranslateLanguage_cht);
};

BOOL TDTextTranslateLanguageFrom_unkown_to_unkown(TDTextTranslateLanguage from, TDTextTranslateLanguage to) {
    return (from == TDTextTranslateLanguage_unkown && to == TDTextTranslateLanguage_unkown);
};

BOOL TDTextTranslateLanguageNotUnkown(TDTextTranslateLanguage lang) {
    return lang != TDTextTranslateLanguage_unkown;
};


NSString* TDLanguageShortLocalizedKeyForType(TDTextTranslateLanguage langType)
{
    NSString *component = TDLanguageLocalizedComponentForType(langType);
    NSString *langLocalizedKey = [NSString stringWithFormat:@"lang_%@", component];
    return langLocalizedKey;
}

NSString* TDLanguageFullLocalizedKeyForType(TDTextTranslateLanguage langType)
{
    NSString *component = TDLanguageLocalizedComponentForType(langType);
    NSString *langLocalizedKey = [NSString stringWithFormat:@"fullname_lang_%@", component];
    return langLocalizedKey;
}

NSString *TDLanguageLocalizedComponentForType(TDTextTranslateLanguage langType)
{
    NSString *lang = @"";
    switch (langType) {
        case TDTextTranslateLanguage_unkown:
            lang = @"auto";
            break;
        case TDTextTranslateLanguage_en:                 // 英语
            lang = @"en";
            break;
        case TDTextTranslateLanguage_zh:                // 简体中文
            lang = @"zh";
            break;
        case TDTextTranslateLanguage_cht:               // 繁体中文
            lang = @"cht";
            break;
            
            // ABC prefix
        case TDTextTranslateLanguage_ara:                // 阿拉伯语
            lang = @"ara";
            break;
        case TDTextTranslateLanguage_est:                // 爱沙尼亚语
            lang = @"est";
            break;
        case TDTextTranslateLanguage_bul:                // 保加利亞语
            lang = @"bul";
            break;
        case TDTextTranslateLanguage_pl:                 // 波兰语
            lang = @"pl";
            break;
            
            // DEFG prefix
        case TDTextTranslateLanguage_dan:                // 丹麦语
            lang = @"dan";
            break;
        case TDTextTranslateLanguage_de:                 // 德语
            lang = @"de";
            break;
        case TDTextTranslateLanguage_ru:                 // 俄语
            lang = @"ru";
            break;
        case TDTextTranslateLanguage_fra:                // 法语
            lang = @"fra";
            break;
        case TDTextTranslateLanguage_fin:                // 芬兰语
            lang = @"fin";
            break;
            
            // HIJKLMN prefix
        case TDTextTranslateLanguage_kor:                // 韩语
            lang = @"kor";
            break;
        case TDTextTranslateLanguage_nl:                 // 荷兰语
            lang = @"nl";
            break;
        case TDTextTranslateLanguage_cs:                 // 捷克语
            lang = @"cs";
            break;
        case TDTextTranslateLanguage_rom:                // 罗马尼亚语
            lang = @"rom";
            break;
            
            // OPQRST prefix
        case TDTextTranslateLanguage_pt:                 // 葡萄牙语
            lang = @"pt";
            break;
        case TDTextTranslateLanguage_jp:                 // 日语
            lang = @"jp";
            break;
        case TDTextTranslateLanguage_swe:                // 瑞典语
            lang = @"swe";
            break;
        case TDTextTranslateLanguage_slo:                // 斯洛文尼亚语
            lang = @"slo";
            break;
        case TDTextTranslateLanguage_th:                 // 泰语
            lang = @"th";
            break;
            
            // UVWX prefix
        case TDTextTranslateLanguage_spa:                // 西班牙语
            lang = @"spa";
            break;
        case TDTextTranslateLanguage_el:                 // 希腊语
            lang = @"el";
            break;
        case TDTextTranslateLanguage_hu:                 // 匈牙利语
            lang = @"hu";
            break;
            
            // YZ prefix
        case TDTextTranslateLanguage_it:                 // 意大利语
            lang = @"it";
            break;
        case TDTextTranslateLanguage_vie:                // 越南语
            lang = @"vie";
            break;
    }
    return lang;
}

NSArray<NSNumber *> *TDTextTranslateLanguage_All() {
    NSMutableArray<NSNumber *> *list = [NSMutableArray<NSNumber *> array];
    for (NSInteger i = TDTextTranslateLanguage_available_first; i <= TDTextTranslateLanguage_available_last; i++) {
        [list addObject:@(i)];
    }
    return list;
};

NSInteger TDUnsupportedTranslateLanguagePairsErrorCode = -10001;
NSError* TDUnsupportedTranslateLanguagePairsError() {
    return [[NSError alloc] initWithDomain:@"" code:TDUnsupportedTranslateLanguagePairsErrorCode userInfo:nil];
};

NSInteger TDTranslateInnerErrorCode = -10002;
NSError* TDTranslateInnerError() {
    return [[NSError alloc] initWithDomain:@"" code:TDTranslateInnerErrorCode userInfo:nil];
}

NSInteger TDTranslateServiceErrorCode = -10003;
NSError* TDTranslateServiceError() {
    return [[NSError alloc] initWithDomain:@"" code:TDTranslateServiceErrorCode userInfo:nil];
}

const BOOL TDDefaultValue_translateCopyTextAutomatically = YES;

const BOOL TDDefaultValue_detectInputLanguageAndTranslateOutputOther = YES;

const NSUInteger TD_preferredTranslateOutputLanguageListMaxCount = 4;

NSArray<NSNumber*> *TDDefaultValue_preferredTranslateOutputLanguageList() {
    NSArray<NSNumber *> *list = @[@(TDTextTranslateLanguage_unkown),
                                  @(TDTextTranslateLanguage_en),
                                  @(TDTextTranslateLanguage_zh)];
    NSCAssert(list.count <= TD_preferredTranslateOutputLanguageListMaxCount, @"default list count must <= 'TD_preferredTranslateOutputLanguageListMaxCount'");
    return list;
}

const TDTranslateServiceProvider TDTranslateServiceProvider_bdfy = 0;
const TDTranslateServiceProvider TDTranslateServiceProvider_hc = 1;
const TDTranslateServiceProvider TDTranslateServiceProvider_aisi = 2;

NSArray<NSNumber *> *TDDefaultValue_preferredTranslateProviderList(){
    return @[@(TDTranslateServiceProvider_aisi),
             @(TDTranslateServiceProvider_hc),
             @(TDTranslateServiceProvider_bdfy)];
};

const NSInteger TDNumberValue_UNLIMITED = -1;
const NSInteger TDDefaultValue_recordsLimit = TDNumberValue_UNLIMITED;

const BOOL TDDefaultValue_tapticPeekOpened = YES;


NSString *const kLastCopiedTranslateMeta = @"kLastCopiedTranslateMeta";


const BOOL TDAppDefaultValue_onlySaveLastTranslateInTranslatePage = YES;

const TDAppTranslateCopyOptionPreference TDAppDefaultValue_preferredTranslateCopyOptionInTranslatePage = TDAppTranslateCopyInputOnly;

const BOOL TDAppDefaultValue_onlyAlignCurrentParagraph = YES;


NSString *const TDContactUSEmail = @"devbool@126.com";


NSURL* TDSharePageURLComposer(NSString *translateId, TDTextTranslateLanguage initialLanguage) {
    return [NSURL URLWithString:[NSString stringWithFormat:@"tTranslator://share?tid=%@&init_lang=%@", translateId?:@"", @(initialLanguage)]];
}

NSString *const TDSpotlightFunctionSearchableItemsDomainIdentifier = @"spotlight.func";

NSString *const TDSpotlightTranslateRecordsSearchableItemsDomainIdentifier = @"spotlight.translate";

NSString* TDSpotlightTranslateRecordsSearchableItemIdentfierWapper(NSString *baseIdentfier) {
    if (!baseIdentfier) return nil;
    return [NSString stringWithFormat:@"%@_%@", TDSpotlightTranslateRecordsSearchableItemsDomainIdentifier, baseIdentfier];
}

NSString* TDTranslateIdParserFromSpotlightRecordsSearchableItemIdentfier(NSString *searchableItemIdentfier) {
    if (TDSpotlightTranslateRecordsSearchableItemJudger(searchableItemIdentfier)) {
        return [searchableItemIdentfier stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@_", TDSpotlightTranslateRecordsSearchableItemsDomainIdentifier] withString:@""];
    }
    return nil;
}

BOOL TDSpotlightTranslateRecordsSearchableItemJudger(NSString *searchItemIdentfier) {
    return [searchItemIdentfier hasPrefix:[NSString stringWithFormat:@"%@_", TDSpotlightTranslateRecordsSearchableItemsDomainIdentifier]];
}
