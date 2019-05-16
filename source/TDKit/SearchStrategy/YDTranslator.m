//
//  YDTranslator.m
//  tinyDict
//
//  Created by 彭光波 on 2018/2/15.
//  Copyright © 2018年 bool. All rights reserved.
//

#import "YDTranslator.h"
#import "NSString+TDKit.h"

@interface YDTranslator ()

@property (nonatomic) NSURLSession *session;

@end

@implementation YDTranslator

+ (NSString *)languageStringForSearchType:(TDTextTranslateLanguage)type {
    
    NSString *lang = nil;
    
    switch (type) {
            // Common use
        case TDTextTranslateLanguage_en:                 // 英语
            lang = @"EN";
            break;
        case TDTextTranslateLanguage_zh:                // 简体中文
            lang = @"zh-CHS";
            break;
        case TDTextTranslateLanguage_cht:               // 繁体中文
            break;
            
            // ABC prefix
        case TDTextTranslateLanguage_ara:                // 阿拉伯语
            break;
        case TDTextTranslateLanguage_est:                // 爱沙尼亚语
            break;
        case TDTextTranslateLanguage_bul:                // 保加利亞语
            break;
        case TDTextTranslateLanguage_pl:                 // 波兰语
            break;
            
            // DEFG prefix
        case TDTextTranslateLanguage_dan:                // 丹麦语
            break;
        case TDTextTranslateLanguage_de:                 // 德语
            break;
        case TDTextTranslateLanguage_ru:                 // 俄语
            lang = @"ru";
            break;
        case TDTextTranslateLanguage_fra:                // 法语
            lang = @"fr";
            break;
        case TDTextTranslateLanguage_fin:                // 芬兰语
            break;
            
            // HIJKLMN prefix
        case TDTextTranslateLanguage_kor:                // 韩语
            lang = @"ko";
            break;
        case TDTextTranslateLanguage_nl:                 // 荷兰语
            break;
        case TDTextTranslateLanguage_cs:                 // 捷克语
            break;
        case TDTextTranslateLanguage_rom:                // 罗马尼亚语
            break;
            
            // OPQRST prefix
        case TDTextTranslateLanguage_pt:                 // 葡萄牙语
            lang = @"pt";
            break;
        case TDTextTranslateLanguage_jp:                 // 日语
            lang = @"ja";
            break;
        case TDTextTranslateLanguage_swe:                // 瑞典语
            break;
        case TDTextTranslateLanguage_slo:                // 斯洛文尼亚语
            break;
        case TDTextTranslateLanguage_th:                 // 泰语
            break;
            
            // UVWX prefix
        case TDTextTranslateLanguage_spa:                // 西班牙语
            lang = @"es";
            break;
        case TDTextTranslateLanguage_el:                 // 希腊语
            break;
        case TDTextTranslateLanguage_hu:                 // 匈牙利语
            break;
            
            // YZ prefix
        case TDTextTranslateLanguage_it:                 // 意大利语
            break;
        case TDTextTranslateLanguage_vie:                // 越南语
            break;
        case TDTextTranslateLanguage_unkown:
            lang = @"auto";
            break;
    }
    
    return lang;
}

- (NSURLRequest *)composeTranslateURLRequestWithQuery:(NSString *)query
                                                 from:(TDTextTranslateLanguage)from
                                                   to:(TDTextTranslateLanguage)to{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://openapi.youdao.com/api"]];
    [req setHTTPMethod:@"POST"];
    
    {
        NSString *q = [query stringByURLDecodeEntirely:YES];
        NSString *appKey = @"2252a7ad97809674";
        NSString *appSec = @"rfMigTcxmvGWagY2eCQsg3AEm9dGym8K";
        NSString *salt = @(100 + arc4random_uniform(100)).stringValue;
        NSString *sign = [[NSString stringWithFormat:@"%@%@%@%@", appKey, q, salt, appSec] md5String];
        NSString *fromStr = [[self class] languageStringForSearchType:from]?:@"auto";
        NSString *toStr = [[self class] languageStringForSearchType:to]?:@"auto";
        
        NSMutableDictionary<NSString*,NSString*> *params = [NSMutableDictionary<NSString*,NSString*> dictionary];
        params[@"q"] = q;
        params[@"from"] = fromStr;
        params[@"to"] = toStr;
        params[@"appKey"] = appKey;
        params[@"sign"] = sign;
        params[@"salt"] = salt;
        params[@"appKey"] = appKey;
        
        
        NSMutableString *body = [NSMutableString string];
        NSUInteger paramCount = params.count;
        for (NSInteger i = 0; i < paramCount; i ++) {
            if (i != 0) {
                [body appendString:@"&"];
            }
            NSString *k = params.allKeys[i];
            NSString *v = params[k];
            [body appendFormat:@"%@=%@", k, [v stringByURLEncode]];
        }
        
        [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
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
            NSDictionary *jsonDoc = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errHolder];
            
            NSArray *translations = jsonDoc[@"translation"];
            if (!translations || translations.count == 0) {
                errHolder = TDTranslateServiceError();
                return nil;
            }
            translateResult = [translations componentsJoinedByString:@""];
            
        } @catch (NSException *exception) {
            errHolder = [[NSError alloc] initWithDomain:exception.name code:-1 userInfo:@{NSLocalizedDescriptionKey:exception.reason?:@""}];
        } @finally {
            safeHoldError(errHolder);
            return translateResult;
        }
    };
}


- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _session;
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
    NSString *fromStr = [[self class] languageStringForSearchType:from];
    NSString *toStr = [[self class] languageStringForSearchType:to];
    return (fromStr && toStr);
}

+ (NSString *)translateServiceProviderName {
    return @"有道翻译";
}

@end
