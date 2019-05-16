//
//  TodayDataController0012.h
//  tinyDict
//
//  Created by guangbool on 2017/4/5.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TDKit/TDModels.h>
#import <TDKit/TDTranslateItem.h>

@class TodayTranslateResponse;
@class TodayTranslateListResponse<T>;
@class TodayTranslateHistoryItem;
@class TodayTranslateHistoryRequest2;
@class TodayTranslateStarListRequest2;
@class TodayTrashedListRequest2;
@class TodayTranslateCheckExistRequest;
@class TodayTranslateCheckExistResponse;
@class TodayTranslateHistoryUpdateRequest;
@class TodayTranslateStarRequest;
@class TodayTranslateMoveToTrashRequest;
@class TodayCopiedTranslateMeta;
@class TodayCopiedTranslateResponse;

@interface TodayDataController0012 : NSObject


/**
 建立所有翻译记录的spotlight搜索索引
 */
- (void)indexesAllTranslateRecordsSpotlightSearchavleItemsIfNeed;

/**
 翻译
 
 @param input           输入
 @param destLanguage    翻译目标语言
 @param completeHandler 回调
 */
- (void)translateForInput:(NSString *)input
             destLanguage:(TDTextTranslateLanguage)destLanguage
          completeHandler:(void(^)(TodayTranslateResponse *resp, NSError *error))completeHandler;

/**
 获取历史列表
 */
- (TodayTranslateListResponse<TodayTranslateHistoryItem *> *)loadHistoryWithRequest2:(TodayTranslateHistoryRequest2*(^)())requestBlock;

/**
 获取收藏列表
 */
- (TodayTranslateListResponse<TodayTranslateHistoryItem *> *)loadStarredListWithRequest2:(TodayTranslateStarListRequest2*(^)())requestBlock;

/**
 获取垃圾桶记录列表
 */
- (TodayTranslateListResponse<TodayTranslateHistoryItem *> *)loadTrashedListWithRequest2:(TodayTrashedListRequest2*(^)())requestBlock;

/**
 检查记录是否存在
 
 @param requestBlock 请求 block
 @return exist item if exists
 */
- (TodayTranslateCheckExistResponse *)checkExistWithRequest:(TodayTranslateCheckExistRequest*(^)())requestBlock;

/**
 保存一个记录

 @param storeItem 保存的记录信息
 @return translate id
 */
- (NSString *)saveOrUpdateHistory:(TDTranslateStoreItem *)storeItem;


/**
 更新历史记录和收藏

 @param requestBlock 请求 block
 @return 记录信息
 */
- (TodayTranslateHistoryItem *)updateHistoryAndStarredWithRequest:(TodayTranslateHistoryUpdateRequest*(^)())requestBlock;


/**
 标星或取消

 @param requestBlock 请求 block
 @return 是否成功
 */
- (BOOL)starOrNotWithRequest:(TodayTranslateStarRequest*(^)())requestBlock;

/**
 放入垃圾篓
 
 @param requestBlock 请求 block
 @return 是否成功
 */
- (BOOL)moveToTrashWithRequest:(TodayTranslateMoveToTrashRequest*(^)())requestBlock;


/**
 从垃圾篓中恢复到历史记录

 @param translateId id of translation
 @return 恢复的记录
 */
- (TodayTranslateHistoryItem *)restoreToHistoryFromTrashWithTranslateId:(NSString *)translateId;


/**
 彻底清除垃圾篓中的某条记录

 @param translateId translateId id of translation
 */
- (void)clearFromTrashWithTranslateId:(NSString *)translateId;


/**
 彻底清除所有垃圾篓中的记录
 */
- (void)clearAllFromTrash;


/**
 保留制定数量的记录，其他都彻底清除（包括历史记录、收藏记录和垃圾桶）

 @param reserveNum 保留记录的数量
 */
- (void)clearAllButReserve:(NSUInteger)reserveNum;

/**
 设置最后一次拷贝的翻译信息
 
 @param meta 最后一次拷贝的翻译信息
 */
- (void)setLastCopiedTranslate:(TodayCopiedTranslateMeta *)meta;

/**
 获取最后一次拷贝的翻译信息
 
 @return 最后一次拷贝的翻译信息
 */
- (TodayCopiedTranslateResponse *)lastCopiedTranslate;


/**
 更新记录的顺序到第一。（历史和收藏都会修改）

 @param translateId 翻译记录 id
 */
- (void)updateOrderToFirst:(NSString *)translateId;

@end


@interface TodayTranslateResponse : NSObject

@property (nonatomic, copy) TDTranslateItem *result;
@property (nonatomic, copy) NSString *providerName;
@property (nonatomic, copy) NSString *translateId;

// 是否来源于本地缓存
@property (nonatomic, assign) BOOL isFromCached;

@end


@interface TodayTranslateListResponse<T> : NSObject

// 查询结果列表
@property (nonatomic, copy) NSArray<T> *list;
// 参考 id
@property (nonatomic, copy) NSString *referTranslateId;
// 参考 item 是否存在
@property (nonatomic, assign) BOOL referItemIfExist;

@end

@interface TodayTranslateHistoryItem : NSObject

@property (nonatomic, copy) NSString *translateId;
@property (nonatomic, copy) TDTranslateStoreItem *item;
@property (nonatomic, assign) BOOL starred;

@end

@interface TodayTranslateHistoryRequest2 : NSObject

/**
 参考 id。如果为 nil，则从第一条开始查询；如果该 id 不存在，则查询返回空列表
 */
@property (nonatomic, copy) NSString *referTranslateId;

/**
 欲查询的数量。正数为向后查询，负数为向前查询
 */
@property (nonatomic, assign) NSInteger num;

/**
 是否获取该记录的收藏状态
 */
@property (nonatomic, assign) BOOL loadStarredState;

@end

@interface TodayTranslateStarListRequest2 : NSObject

/**
 参考 id。如果为 nil，则从第一条开始查询
 */
@property (nonatomic, copy) NSString *referTranslateId;

/**
 欲查询的数量。正数为向后查询，负数为向前查询
 */
@property (nonatomic, assign) NSInteger num;

@end

@interface TodayTrashedListRequest2 : NSObject

/**
 参考 id。如果为 nil，则从第一条开始查询
 */
@property (nonatomic, copy) NSString *referTranslateId;

/**
 欲查询的数量。正数为向后查询，负数为向前查询
 */
@property (nonatomic, assign) NSInteger num;

@end

@interface TodayTranslateCheckExistRequest : NSObject

@property (nonatomic, copy) NSString *translateId;      // optional
@property (nonatomic, copy) NSString *input;            // optional
@property (nonatomic, assign) BOOL checkExistInHistory; // 是否检查在历史记录中
@property (nonatomic, assign) BOOL checkExistInStarred; // 是否检查在收藏中
@property (nonatomic, assign) BOOL checkExistInTrash;   // 是否检查在垃圾篓中

@end

@interface TodayTranslateCheckExistResponse : NSObject

@property (nonatomic, copy) NSString *translateId;

@property (nonatomic, copy) TDTranslateStoreItem *existItemInHistory;

@property (nonatomic, copy) TDTranslateStoreItem *existItemInStarred;

@property (nonatomic, copy) TDTranslateStoreItem *existItemInTrash;

@end

@interface TodayTranslateHistoryUpdateRequest : NSObject

@property (nonatomic, copy) NSString *translateId;  // required
@property (nonatomic, copy) NSArray<TDTranslateResultStoreItem *> *updateTranslateItems;

@end

@interface TodayTranslateStarRequest : NSObject

@property (nonatomic, copy) NSString *translateId;
@property (nonatomic, assign) BOOL isToStarOrNot; // 是否标星或取消标星

@end

@interface TodayTranslateMoveToTrashRequest : NSObject

@property (nonatomic, copy) NSString *translateId;
// 删除 「历史」 中的存在的相关记录
@property (nonatomic, assign) BOOL deleteExistInHistory;
// 删除 「收藏」 中的存在的相关记录
@property (nonatomic, assign) BOOL deleteExistInStarred;
// 是否不可还原的
@property (nonatomic, assign) BOOL disrestorable;

@end


@interface TodayCopiedTranslateMeta : NSObject <NSCopying, NSCoding>

// 拷贝的项目的 translate id
@property (nonatomic, copy) NSString *translateId;
// 拷贝的文本
@property (nonatomic, copy) NSString *copiedString;

@end

@interface TodayCopiedTranslateResponse : NSObject

@property (nonatomic) TodayCopiedTranslateMeta *meta;
// 是否在垃圾桶
@property (nonatomic, assign) BOOL isTrashed;

@end
