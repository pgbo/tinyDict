//
//  BingDictSearch.m
//  tinyDict
//
//  Created by guangbool on 2017/3/8.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "BingDictSearch.h"
#import "NSString+TDKit.h"

@interface BingDictSearch ()

@property (nonatomic) NSURLSession *session;

@end

@implementation BingDictSearch

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
        NSArray<TDictItem*>* result = responseSerializer(data, &errHolder);
        safeCallHandler(result, errHolder, providerName);
    }];
    [task resume];
}

+ (NSString *)searchServiceProviderName {
    return @"必应";
}

- (NSString *)composeRequestUrlWithQuery:(NSString *)query suggestLimit:(NSUInteger)suggestLimit {
    return [NSString stringWithFormat:@"https://api.bing.com/qsonhs.aspx?mkt=zh-CN&ds=bingdict&count=%@&q=%@", @(suggestLimit), [query stringByURLEncode]];
}

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _session;
}

+ (TDSearchResultSerializer)responseSerializer {
    return ^NSArray<TDictItem*>*(NSData *responseData, NSError **error){
        void(^safeHoldError)(NSError *err) = ^(NSError *err){
            if (err != nil && error != NULL) {
                *error = err;
            }
        };
        
        NSError *errHolder = nil;
        NSMutableArray<TDictItem *> *suggests = nil;
        
        @try {
            
            NSDictionary *jsonDoc = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errHolder];
            
            NSArray *items = ((NSDictionary *)((NSArray *)(((NSDictionary *)jsonDoc[@"AS"])[@"Results"])).firstObject)[@"Suggests"];
            if (!items || items.count == 0) {
                safeHoldError(errHolder);
                return nil;
            }
            
            suggests = [NSMutableArray<TDictItem *> array];
            for (NSDictionary *item in items) {
                NSString *explain = item[@"Txt"];
                if (explain.length == 0) {
                    continue;
                }
                TDictItem *sggItem = [[TDictItem alloc] initWithSsgText:@"" explain:explain];
                [suggests addObject:sggItem];
            }
        } @catch (NSException *exception) {
            errHolder = [[NSError alloc] initWithDomain:exception.name code:-1 userInfo:@{NSLocalizedDescriptionKey:exception.reason?:@""}];
        } @finally {
            safeHoldError(errHolder);
            return suggests;
        }
    };
}

@end
