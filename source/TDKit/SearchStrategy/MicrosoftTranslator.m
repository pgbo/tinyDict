//
//  MicrosoftTranslator.m
//  tinyDict
//
//  Created by guangbool on 2017/3/28.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "MicrosoftTranslator.h"
#import "NSString+TDKit.h"

@interface MicrosoftTranslator ()

@property (nonatomic) NSURLSession *session;

@end

@implementation MicrosoftTranslator

- (instancetype)initWithAppId:(NSString *)appId {
    if (self = [super init]) {
        _appId = [appId copy];
    }
    return self;
}

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _session;
}

+ (NSString *)languageStringForSearchType:(TDTextTranslateLanguage)type {
    
    NSString *lang = nil;
    
    switch (type) {
        // Common use
        case TDTextTranslateLanguage_en:                 // 英语
            lang = @"en";
            break;
        case TDTextTranslateLanguage_zh:                // 简体中文
            lang = @"zh-CHS";
            break;
        case TDTextTranslateLanguage_cht:               // 繁体中文
            lang = @"zh-CHT";
            break;
            
            // ABC prefix
        case TDTextTranslateLanguage_ara:                // 阿拉伯语
            lang = @"ar";
            break;
        case TDTextTranslateLanguage_est:                // 爱沙尼亚语
            lang = @"et";
            break;
        case TDTextTranslateLanguage_bul:                // 保加利亞语
            lang = @"bg";
            break;
        case TDTextTranslateLanguage_pl:                 // 波兰语
            lang = @"pl";
            break;
            
            // DEFG prefix
        case TDTextTranslateLanguage_dan:                // 丹麦语
            lang = @"da";
            break;
        case TDTextTranslateLanguage_de:                 // 德语
            lang = @"de";
            break;
        case TDTextTranslateLanguage_ru:                 // 俄语
            lang = @"ru";
            break;
        case TDTextTranslateLanguage_fra:                // 法语
            lang = @"fr";
            break;
        case TDTextTranslateLanguage_fin:                // 芬兰语
            lang = @"fi";
            break;
            
            // HIJKLMN prefix
        case TDTextTranslateLanguage_kor:                // 韩语
            lang = @"ko";
            break;
        case TDTextTranslateLanguage_nl:                 // 荷兰语
            lang = @"nl";
            break;
        case TDTextTranslateLanguage_cs:                 // 捷克语
            lang = @"cs";
            break;
        case TDTextTranslateLanguage_rom:                // 罗马尼亚语
            lang = @"ro";
            break;
            
            // OPQRST prefix
        case TDTextTranslateLanguage_pt:                 // 葡萄牙语
            lang = @"pt";
            break;
        case TDTextTranslateLanguage_jp:                 // 日语
            lang = @"ja";
            break;
        case TDTextTranslateLanguage_swe:                // 瑞典语
            lang = @"sv";
            break;
        case TDTextTranslateLanguage_slo:                // 斯洛文尼亚语
            lang = @"sl";
            break;
        case TDTextTranslateLanguage_th:                 // 泰语
            lang = @"th";
            break;
            
            // UVWX prefix
        case TDTextTranslateLanguage_spa:                // 西班牙语
            lang = @"es";
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
            lang = @"vi";
            break;
        default:
            break;
    }
    
    return lang;
}

- (NSURLRequest *)composeTranslateURLRequestWithQuery:(NSString *)query
                                                 from:(TDTextTranslateLanguage)from
                                                   to:(TDTextTranslateLanguage)to {
    
    NSMutableString *url = [NSMutableString stringWithString:@"https://api.microsofttranslator.com/V2/Ajax.svc/TranslateArray?foo=bar"];
    
    NSString *fromStr = [[self class] languageStringForSearchType:from];
    if (fromStr.length > 0) {
        [url appendFormat:@"&from=%@", fromStr];
    }
    NSString *toStr = [[self class] languageStringForSearchType:to];
    if (toStr.length > 0) {
        [url appendFormat:@"&to=%@", toStr];
    }
    
    [url appendFormat:@"&appId=%@", self.appId];
    [url appendFormat:@"&texts=%@]", [[NSString stringWithFormat:@"[\"%@\"]", query] stringByURLEncode]];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    return req;
}

+ (TDTranslateResultSerializer)translateResponseSerializer {
    return ^NSString* (NSData *responseData, NSError **error){
        void(^safeHoldError)(NSError *err) = ^(NSError *err){
            if (err != nil && error != NULL) {
                *error = err;
            }
        };
        
        NSError *errHolder = nil;
        NSString *translateResult = nil;
        
        @try {
            NSArray *jsonDoc = [NSJSONSerialization JSONObjectWithData:responseData
                                                               options:kNilOptions
                                                                 error:&errHolder];
            NSDictionary *item = [jsonDoc firstObject];
            translateResult = item[@"TranslatedText"];
            
        } @catch (NSException *exception) {
            errHolder = [[NSError alloc] initWithDomain:exception.name code:-1 userInfo:@{NSLocalizedDescriptionKey:exception.reason?:@""}];
        } @finally {
            safeHoldError(errHolder);
            return translateResult;
        }
    };
}

#pragma mark - TDTranslateStrategy

- (void)translateForText:(NSString *)text
                    from:(TDTextTranslateLanguage)from
                      to:(TDTextTranslateLanguage)to
         completeHandler:(TDTranslateCompleteHandler)completeHandler {
    
    TDTranslateCompleteHandler safeCallHandler = ^(TDTranslateItem *translate, NSError *error, NSString *serviceProvider){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeHandler) {
                completeHandler(translate, error, serviceProvider);
            }
        });
    };
    
    __block TDTranslateItem *translateItem = [[TDTranslateItem alloc] initWithInput:text inputLang:from outputLang:to];
    NSString *providerName = [[self class] translateServiceProviderName];
    
    if (![[self class] supportTranslateWithFrom:from to:to]) {
        safeCallHandler(translateItem, TDUnsupportedTranslateLanguagePairsError(), providerName);
        return;
    }
    
    NSURLRequest *request = [self composeTranslateURLRequestWithQuery:text from:from to:to];
    TDTranslateResultSerializer responseSerializer = [[self class] translateResponseSerializer];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            safeCallHandler(translateItem, error, providerName);
            return;
        }
        
        NSError *errHolder = nil;
        NSString *result = responseSerializer(data, &errHolder);
        translateItem.output = result;
        safeCallHandler(translateItem, errHolder, providerName);
    }];
    [task resume];
}

+ (BOOL)supportTranslateWithFrom:(TDTextTranslateLanguage)from to:(TDTextTranslateLanguage)to {
    return TDTextTranslateLanguageNotUnkown(to);
}

+ (NSString *)translateServiceProviderName {
    return @"微软翻译";
}

@end
