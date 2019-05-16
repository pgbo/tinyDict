//
//  YDSearch.m
//  tinyDict
//
//  Created by guangbool on 2017/3/8.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "YDSearch.h"
#import "NSString+TDKit.h"
#if __has_include(<GDataXML-HTML/GDataXMLNode.h>)
#import <GDataXML-HTML/GDataXMLNode.h>
#else
#import "GDataXMLNode.h"
#endif

@interface YDSearch ()

@property (nonatomic) NSURLSession *session;

@end

@implementation YDSearch

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
    return @"有道词典";
}

- (NSString *)composeRequestUrlWithQuery:(NSString *)query suggestLimit:(NSUInteger)suggestLimit {
    return [NSString stringWithFormat:@"https://dict.youdao.com/suggest?type=DESKDICT&ver=2.0&le=eng&num=%@&q=%@", @(suggestLimit), [query stringByURLEncode]];
}

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _session;
}

+ (TDSearchResultSerializer)responseSerializer {
    return ^NSArray<TDictItem *> *(NSData *responseData, NSError **error){
        
        void(^safeHoldError)(NSError *err) = ^(NSError *err){
            if (err != nil && error != NULL) {
                *error = err;
            }
        };
        
        NSError *errHolder = nil;
        NSMutableArray<TDictItem *> *suggets = nil;
        
        @try {
            GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:responseData error:&errHolder];
            if (!doc) {
                safeHoldError(errHolder);
                return nil;
            }
            NSArray<GDataXMLNode *> *items = [doc nodesForXPath:@"//suggest/items/item" error:&errHolder];
            if (!items || items.count == 0) {
                safeHoldError(errHolder);
                return nil;
            }
            
            suggets = [NSMutableArray<TDictItem *> array];
            for (GDataXMLNode *obj in items) {
                GDataXMLNode *titleNode = [obj firstNodeForXPath:@"//title" error:&errHolder];
                NSString *sgg_text = [titleNode stringValue];
                GDataXMLNode *explainNode = [obj firstNodeForXPath:@"//explain" error:&errHolder];
                NSString *explain = [explainNode stringValue];
                if (sgg_text.length > 0 && explain.length > 0) {
                    TDictItem *item = [[TDictItem alloc] initWithSsgText:sgg_text explain:explain];
                    [suggets addObject:item];
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
