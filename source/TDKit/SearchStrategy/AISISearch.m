//
//  AISISearch.m
//  tinyDict
//
//  Created by guangbool on 2017/3/9.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "AISISearch.h"
#import "NSString+TDKit.h"

@interface AISISearch ()

@property (nonatomic) NSURLSession *session;

@end

@implementation AISISearch

#pragma mark - TDSearchStrategy

- (void)searchForText:(NSString *)text
         suggestLimit:(NSUInteger)suggestLimit
      completeHandler:(TDSearchCompleteHandler)completeHandler {
    
    NSURLRequest *request = [self composeURLRequestWithQuery:text suggestLimit:suggestLimit];
    TDSearchResultSerializer responseSerializer = [[self class] responseSerializer];
    NSString *providerName = [[self class] searchServiceProviderName];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
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
    return @"爱思网";
}

- (NSURLRequest *)composeURLRequestWithQuery:(NSString *)query suggestLimit:(NSUInteger)suggestLimit {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://m.24en.com/fy/get"]];
    [request setHTTPMethod:@"POST"];
    NSString *body = [NSString stringWithFormat:@"do=trans&fromto=auto-auto&q=%@", [query stringByURLEncode]];
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    return request;
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
            NSArray *items = jsonDoc[@"translation"];
            if (!items || items.count == 0) {
                safeHoldError(errHolder);
                return nil;
            }
            NSMutableArray<NSString *> *explains = [NSMutableArray<NSString *> array];
            for (NSString *explain in items) {
                if (explain.length > 0) {
                    [explains addObject:explain];
                }
            }
            
            if (explains.count == 0) {
                safeHoldError(errHolder);
                return nil;
            }
            NSString *sggText = jsonDoc[@"query"];
            TDictItem *sggItem = [[TDictItem alloc] initWithSsgText:sggText explains:explains];
            
            suggets = [NSMutableArray<TDictItem *> array];
            [suggets addObject:sggItem];
            
        } @catch (NSException *exception) {
            errHolder = [[NSError alloc] initWithDomain:exception.name code:-1 userInfo:@{NSLocalizedDescriptionKey:exception.reason?:@""}];
        } @finally {
            safeHoldError(errHolder);
            return suggets;
        }
    };
}

@end

@implementation AISISearch (TDTranslate)

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
    
    [self searchForText:text suggestLimit:1 completeHandler:^(NSArray<TDictItem *> *results, NSError *error, NSString *serviceProvider) {
        
        TDictItem *item = [results firstObject];
        translateItem.output = item.explains.firstObject;
        safeCallHandler(translateItem, error, providerName);
    }];
}

+ (BOOL)supportTranslateWithFrom:(TDTextTranslateLanguage)from to:(TDTextTranslateLanguage)to {
    return     TDTextTranslateLanguageFrom_zh_to_en(from, to)
            || TDTextTranslateLanguageFrom_en_to_zh(from, to)
            || TDTextTranslateLanguageFrom_unkown_to_unkown(from, to);
}

@end
