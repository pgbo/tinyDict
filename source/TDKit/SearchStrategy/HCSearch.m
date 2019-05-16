//
//  HCSearch.m
//  tinyDict
//
//  Created by guangbool on 2017/3/8.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "HCSearch.h"
#import "NSString+TDKit.h"
#import "MicrosoftTranslator.h"

@interface HCSearch ()

@property (nonatomic) NSURLSession *session;

@end

@implementation HCSearch

#pragma mark - TDSearchStrategy

- (void)searchForText:(NSString *)text
         suggestLimit:(NSUInteger)suggestLimit
      completeHandler:(TDSearchCompleteHandler)completeHandler {
    
    NSString *queryUrl = [self composeRequestUrlWithQuery:text suggestLimit:suggestLimit];
    TDSearchResultSerializer responseSerializer = [[self class] responseSerializer];
    NSString *providerName = [[self class] searchServiceProviderName];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:queryUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        TDSearchCompleteHandler safeCallHandler = ^(NSArray<TDictItem *> *result, NSError *err, NSString *serv_p){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completeHandler) {
                    completeHandler(result, err, serv_p);
                }
            });
        };
        
        if (error) {
            safeCallHandler(nil, error, providerName);
            return;
        }
        
        NSError *errHolder = nil;
        NSArray<TDictItem *> *result = responseSerializer(data, &errHolder);
        if (result.count > suggestLimit) {
            result = [result subarrayWithRange:NSMakeRange(0, suggestLimit)];
        }
        safeCallHandler(result, errHolder, providerName);
    }];
    [task resume];
}

+ (NSString *)searchServiceProviderName {
    return @"海词";
}

- (NSString *)composeRequestUrlWithQuery:(NSString *)query suggestLimit:(NSUInteger)suggestLimit {
    return [NSString stringWithFormat:@"http://dict.cn/apis/suggestion.php?dict=dict&s=dict&q=%@", [query stringByURLEncode]];
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
            NSArray *items = jsonDoc[@"s"];
            if (!items || items.count == 0) {
                safeHoldError(errHolder);
                return nil;
            }
            suggets = [NSMutableArray<TDictItem *> array];
            for (NSDictionary *item in items) {
                NSString *sggText = item[@"g"];
                NSString *explain = item[@"e"];
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


@implementation HCSearch (TDTranslate)

- (NSString*(^)(NSData *))appIdSerializer {
    return ^NSString*(NSData *data){
        NSString *result = nil;
        @try {
            result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } @catch (NSException *exception) {
            
        } @finally {
            return result;
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
    NSString *providerName = [[self class] searchServiceProviderName];
    
    // 获取动态变化的 appId
    NSString*(^appIdSerializer)(NSData *) = [self appIdSerializer];
    [self.session dataTaskWithURL:[NSURL URLWithString:@"http://capi.dict.cn/fanyi.php"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            safeCallHandler(translateItem, error, providerName);
            return;
        }
        
        NSString *appId = appIdSerializer(data);
        if (appId.length == 0) {
            safeCallHandler(translateItem, TDTranslateInnerError(), providerName);
            return;
        }
        
        id<TDTranslateStrategy> delegate = [[MicrosoftTranslator alloc] initWithAppId:appId];
        [delegate translateForText:text from:from to:to completeHandler:^(TDTranslateItem *translate, NSError *error, NSString *serviceProvider) {
            safeCallHandler(translate, error, providerName);
        }];
    }];
}

+ (BOOL)supportTranslateWithFrom:(TDTextTranslateLanguage)from to:(TDTextTranslateLanguage)to {
    return [MicrosoftTranslator supportTranslateWithFrom:from to:to];
}

+ (NSString *)translateServiceProviderName {
    return [self searchServiceProviderName];
}

@end
