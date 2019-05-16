//
//  ZNSearch.m
//  tinyDict
//
//  Created by guangbool on 2017/3/9.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "ZNSearch.h"
#import "NSString+TDKit.h"

@interface ZNSearch ()

@property (nonatomic) NSURLSession *session;

@end

@implementation ZNSearch

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
    return @"抓鸟";
}

- (NSString *)composeRequestUrlWithQuery:(NSString *)query suggestLimit:(NSUInteger)suggestLimit {
    return [NSString stringWithFormat:@"http://www.zhuaniao.com/do.hint?skey=%@", [query stringByURLEncode]];
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
            NSArray *items = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:kNilOptions
                                                               error:&errHolder];
            if (!items || items.count == 0) {
                safeHoldError(errHolder);
                return nil;
            }
            suggets = [NSMutableArray<TDictItem *> array];
            for (NSDictionary *item in items) {
                NSString *sggText = item[@"entry"];
                NSString *explain = item[@"definitions"];
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
