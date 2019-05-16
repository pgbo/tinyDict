//
//  ICBSearch.m
//  tinyDict
//
//  Created by guangbool on 2017/3/8.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "ICBSearch.h"
#import "NSString+TDKit.h"

@interface ICBSearch ()

@property (nonatomic) NSURLSession *session;

@end

@implementation ICBSearch

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
        safeCallHandler(result, errHolder, providerName);
    }];
    [task resume];
}

+ (NSString *)searchServiceProviderName {
    return @"爱词霸";
}

- (NSString *)composeRequestUrlWithQuery:(NSString *)query suggestLimit:(NSUInteger)suggestLimit {
    return [NSString stringWithFormat:@"https://m.iciba.com/index.php?c=search&m=getsuggest&client=6&uid=0&is_need_mean=1&nums=%@&word=%@", @(suggestLimit), [query stringByURLEncode]];
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
            NSArray *items = (NSArray *)jsonDoc[@"message"];
            if (!items || items.count == 0) {
                safeHoldError(errHolder);
                return nil;
            }
            suggets = [NSMutableArray<TDictItem *> array];
            for (NSDictionary *item in items) {
                NSArray *meanNodes = item[@"means"];
                NSString *sggText = item[@"key"];
                if (!meanNodes || meanNodes.count == 0 || !sggText || sggText.length == 0) {
                    continue;
                }
                NSMutableArray<NSString *> *explains = [NSMutableArray<NSString *> array];
                for (NSDictionary *meanNode in meanNodes) {
                    NSString *part = meanNode[@"part"];
                    NSArray *means = meanNode[@"means"];
                    NSString *componentMeans = [means componentsJoinedByString:@", "];
                    
                    NSMutableString *explain = [NSMutableString string];
                    if (part.length > 0) {
                        [explain appendString:part];
                        [explain appendString:@" "];
                    }
                    
                    if (componentMeans.length > 0) {
                        [explain appendString:componentMeans];
                    }
                    if (explain.length > 0) {
                        [explains addObject:explain];
                    }
                }
                if (explains.count == 0) {
                    continue;
                }
                TDictItem *sggItem = [[TDictItem alloc] initWithSsgText:sggText explains:explains];
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
