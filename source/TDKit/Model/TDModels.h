//
//  TDModels.h
//  tinyDict
//
//  Created by guangbool on 2017/3/23.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDConstants.h"
#import "TDTranslateItem.h"

@interface TDQueryItemState : NSObject <NSCopying, NSCoding>

@property (nonatomic, assign) BOOL starred;
@property (nonatomic, assign) BOOL trashy;

@end

@interface TDQueryItemResult : NSObject <NSCopying, NSCoding>

@property (nonatomic, copy) NSString *query;
@property (nonatomic, copy) NSString *resultOfDictQuery;
@property (nonatomic, copy) NSString *dictProvider;
@property (nonatomic, copy) NSString *resultOfTranslate;
@property (nonatomic, copy) NSString *translateProvider;
@property (nonatomic, assign) NSInteger lastModifyTimestamp;

@end



/**
 翻译结果存储 model
 */
@interface TDTranslateResultStoreItem : NSObject <NSCopying, NSCoding>

@property (nonatomic, assign) TDTextTranslateLanguage outputLang;
@property (nonatomic, copy) NSString *output;
@property (nonatomic, copy) NSString *providerName;

- (instancetype)initWithOutputLang:(TDTextTranslateLanguage)outputLang
                            output:(NSString *)output
                      providerName:(NSString *)providerName;

- (instancetype)initWithTranslateItem:(TDTranslateItem *)translateItem;

- (TDTranslateItem *)translateItem;

@end

/**
 翻译存储 model
 */
@interface TDTranslateStoreItem : NSObject <NSCopying, NSCoding>

@property (nonatomic, copy) NSString *input;

/**
 翻译结果列表
 */
@property (nonatomic, copy) NSArray<TDTranslateResultStoreItem *> *translateResults;


/**
 返回某个语言的翻译结果。如果不存在，返回 nil

 @param outputLang 翻译语言
 @return 某个语言的翻译结果
 */
- (TDTranslateResultStoreItem *)translateResultForOutputLang:(TDTextTranslateLanguage)outputLang;

/**
 首选翻译语言顺序，根据`translateResults`和默认顺序综合得出该顺序

 @param defaultOrder 默认顺序
 @return 首选翻译语言顺序
 */
- (NSArray<NSNumber *> *)preferredOutputLanguagesOrderWithDefault:(NSArray<NSNumber *> *)defaultOrder;

@end
