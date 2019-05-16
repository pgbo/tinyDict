//
//  YDFYSearch.m
//  tinyDict
//
//  Created by guangbool on 2017/3/9.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "YDFYSearch.h"
#import "NSString+TDKit.h"

@interface YDFYSearch ()

@property (nonatomic) NSURLSession *session;

@end

@implementation YDFYSearch

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
    return @"有道翻译";
}

- (NSString *)composeRequestUrlWithQuery:(NSString *)query suggestLimit:(NSUInteger)suggestLimit {
    return [NSString stringWithFormat:@"https://openapi.youdao.com/api?q=%@&",
            [query stringByURLEncode]];
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
            
            NSArray *translateResults = jsonDoc[@"translateResult"];
            if ([translateResults isKindOfClass:[NSArray class]] && translateResults.count > 0) {
                if (!suggets) {
                    suggets = [NSMutableArray<TDictItem *> array];
                }
                for (NSArray *itemArray in translateResults) {
                    NSMutableString *src = [NSMutableString string];
                    NSMutableString *tgt = [NSMutableString string];
                    for (NSDictionary *item in itemArray) {
                        [src appendString:item[@"src"]?:@""];
                        [tgt appendString:item[@"tgt"]?:@""];
                    }
                    TDictItem *sggItem = [[TDictItem alloc] initWithSsgText:src explain:tgt];
                    [suggets addObject:sggItem];
                }
            }
            
            NSDictionary *smartResult = jsonDoc[@"smartResult"];
            if (smartResult && [smartResult isKindOfClass:[NSDictionary class]]) {
                NSArray *entries = smartResult[@"entries"];
                if ([entries isKindOfClass:[NSArray class]] && entries.count > 0) {
                    if (!suggets) {
                        suggets = [NSMutableArray<TDictItem *> array];
                    }
                    NSMutableArray<NSString *> *explains = [NSMutableArray<NSString *> array];
                    for (NSString *entry in entries) {
                        NSString *explain = [entry stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if (explain.length > 0) {
                            [explains addObject:explain];
                        }
                    }
                    TDictItem *sggItem = [[TDictItem alloc] initWithSsgText:@"" explains:explains];
                    [suggets addObject:sggItem];
                }
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
