//
//  BDFYSearch.m
//  tinyDict
//
//  Created by guangbool on 2017/3/9.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "BDFYSearch.h"
#import "NSString+TDKit.h"

@interface BDFYSearch ()

@property (nonatomic) NSURLSession *session;

@end

@implementation BDFYSearch

#pragma mark - TDSearchStrategy

- (void)searchForText:(NSString *)text
         suggestLimit:(NSUInteger)suggestLimit
      completeHandler:(TDSearchCompleteHandler)completeHandler {
    
    NSString *queryUrl = [self composeRequestUrlWithQuery:text suggestLimit:suggestLimit];
    TDSearchResultSerializer responseSerializer = [[self class] responseSerializer];
    NSString *serviceProvider = [[self class] searchServiceProviderName];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:queryUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        TDSearchCompleteHandler safeCallHandler = ^(NSArray<TDictItem *> *result, NSError *err, NSString *serv_p){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completeHandler) {
                    completeHandler(result, err, serv_p);
                }
            });
        };
        
        if (error) {
            safeCallHandler(nil, error, serviceProvider);
            return;
        }
        
        NSError *errHolder = nil;
        NSArray<TDictItem *> *result = responseSerializer(data, &errHolder);
        if (result.count > suggestLimit) {
            result = [result subarrayWithRange:NSMakeRange(0, suggestLimit)];
        }
        safeCallHandler(result, errHolder, serviceProvider);
    }];
    [task resume];
}

+ (NSString *)searchServiceProviderName {
    return @"百度翻译";
}

- (NSString *)composeRequestUrlWithQuery:(NSString *)query suggestLimit:(NSUInteger)suggestLimit {
    return [NSString stringWithFormat:@"https://fanyi.baidu.com/sug?kw=%@", [query stringByURLEncode]];
}

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _session;
}

+ (TDSearchResultSerializer)responseSerializer {
    return ^NSArray<TDictItem *>*(NSData *responseData, NSError **error){
        void(^safeHoldError)(NSError *err) = ^(NSError *err){
            if (err != nil && error != NULL) {
                *error = err;
            }
        };
        
        NSError *errHolder = nil;
        NSMutableArray<TDictItem *> *suggets = nil;
        
        @try {
            NSDictionary *jsonDoc = [NSJSONSerialization JSONObjectWithData:responseData
                                                                    options:kNilOptions
                                                                      error:&errHolder];
            NSArray *items = jsonDoc[@"data"];
            if (!items || items.count == 0) {
                safeHoldError(errHolder);
                return nil;
            }
            suggets = [NSMutableArray<TDictItem *> array];
            for (NSDictionary *item in items) {
                NSString *sggText = item[@"k"];
                NSString *explain = item[@"v"];
                explain = [explain stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
                if (sggText.length == 0 || explain.length == 0) {
                    continue;
                }
                TDictItem *sggItem = [[TDictItem alloc] initWithSsgText:sggText explain:explain];
                [suggets addObject:sggItem];
            }
        } @catch (NSException *exception) {
            errHolder = [[NSError alloc] initWithDomain:exception.name code:-1 userInfo:@{NSLocalizedDescriptionKey:exception.reason?:@""}];
        } @finally {
            safeHoldError(errHolder);
            return suggets;
        }
    };
}

@end


@implementation BDFYSearch (TDTranslate)

+ (NSString *)languageStringForSearchType:(TDTextTranslateLanguage)type {
    
    NSString *lang = nil;
    
    switch (type) {
        // Common use
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
        default:
            break;
    }
    
    return lang;
}

- (NSURLRequest *)composeTranslateURLRequestWithQuery:(NSString *)query
                                                 from:(TDTextTranslateLanguage)from
                                                   to:(TDTextTranslateLanguage)to{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://fanyi.baidu.com/v2transapi"]];
    [req setHTTPMethod:@"POST"];
    
    {
        NSMutableString *body = [NSMutableString string];
        [body appendFormat:@"query=%@", [query stringByURLDecodeEntirely:YES]];
        NSString *fromStr = [[self class] languageStringForSearchType:from];
        if (fromStr.length > 0) {
            [body appendFormat:@"&from=%@", fromStr];
        }
        NSString *toStr = [[self class] languageStringForSearchType:to];
        if (toStr.length > 0) {
            [body appendFormat:@"&to=%@", toStr];
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
            NSDictionary *jsonDoc = [NSJSONSerialization JSONObjectWithData:responseData
                                                                    options:kNilOptions
                                                                      error:&errHolder];
            NSDictionary *trans_result = jsonDoc[@"trans_result"];
            NSArray *data = trans_result[@"data"];
            if (!data || data.count == 0) {
                safeHoldError(errHolder);
                return nil;
            }
            NSMutableString *result = [NSMutableString string];
            [data enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *dst = item[@"dst"];
                if (idx != 0) {
                    [result appendString:@"\n"];
                }
                if (dst.length > 0) {
                    [result appendString:dst];
                }
            }];
            translateResult = result;
            
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
    return YES;
}

+ (NSString *)translateServiceProviderName {
    return [self searchServiceProviderName];
}

@end
