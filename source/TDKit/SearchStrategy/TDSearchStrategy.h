//
//  TDSearchStrategy.h
//  tinyDict
//
//  Created by guangbool on 2017/3/8.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDictItem.h"
#import "TDTranslateItem.h"
#import "TDConstants.h"

typedef void(^TDSearchCompleteHandler)(NSArray<TDictItem *> *results, NSError *error, NSString *serviceProvider);
typedef void(^TDTranslateCompleteHandler)(TDTranslateItem *translateItem, NSError *error, NSString *serviceProvider);
typedef NSArray<TDictItem *>* (^TDSearchResultSerializer)(id sourceData, NSError **errorHolder);
typedef NSString* (^TDTranslateResultSerializer)(id sourceData, NSError **errorHolder);

@protocol TDSearchStrategy <NSObject>


/**
 查词

 @param text 文字
 @param suggestLimit 查询建议条目限定
 @param completeHandler 回调
 */
- (void)searchForText:(NSString *)text
         suggestLimit:(NSUInteger)suggestLimit
      completeHandler:(TDSearchCompleteHandler)completeHandler;

@optional
// 查词服务提供者名称
+ (NSString *)searchServiceProviderName;

@end

@protocol TDTranslateStrategy <NSObject>

/**
 翻译
 
 @param text    文字
 @param from    源文字语言
 @param to      目标文字语言
 @param completeHandler 回调
 */
- (void)translateForText:(NSString *)text
                    from:(TDTextTranslateLanguage)from
                      to:(TDTextTranslateLanguage)to
         completeHandler:(TDTranslateCompleteHandler)completeHandler;


/**
 是否支持该种类型的翻译

 @param from    源文字语言
 @param to      目标文字语言
 */
+ (BOOL)supportTranslateWithFrom:(TDTextTranslateLanguage)from to:(TDTextTranslateLanguage)to;

@optional
// 查词服务提供者名称
+ (NSString *)translateServiceProviderName;

@end
