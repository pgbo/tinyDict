//
//  TodayDataController0012.m
//  tinyDict
//
//  Created by guangbool on 2017/4/5.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TodayDataController0012.h"
#import <TDKit/MMWormhole.h>
#import <TDKit/TDSearchManager.h>
#import <TDKit/OrderedDictionary.h>
#import <TDKit/NSString+TDKit.h>
#import <TDKit/NSBundle+TDkit.h>
#import <TDKit/UIDevice+TDKit.h>
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface TodayDataController0012 ()

@property (nonatomic) MMWormhole *historyWormhole;
@property (nonatomic) MMWormhole *trashWormhole;
@property (nonatomic) MMWormhole *starredWormhole;

@property (nonatomic) CSSearchQuery *translateSearchableItemsQuery;

@end

@implementation TodayDataController0012

+ (void)clearAllButReserve:(NSUInteger)reserveNum inWormhole:(MMWormhole *)wormhole {
    if (!wormhole) return;
    
    OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [wormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
    MutableOrderedDictionary<NSString *, NSString *> *newDictionary = [MutableOrderedDictionary<NSString *, NSString *> dictionary];
    if (translateAndIdDictionary.count > 0) {
        [newDictionary addEntriesFromDictionary:translateAndIdDictionary];
    }
    
    [translateAndIdDictionary enumerateKeysAndObjectsWithIndexUsingBlock:^(NSString * _Nonnull input, NSString * _Nonnull translateId, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= reserveNum) {
            [wormhole clearMessageContentsForIdentifier:translateId];
            [newDictionary removeObjectForKey:input];
        }
    }];
    
    [wormhole passMessageObject:newDictionary identifier:kTranslateInputAndIdDictionary];
}


- (MMWormhole *)historyWormhole {
    if (!_historyWormhole) {
        _historyWormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:NameOfTDAppGroup
                                                                optionalDirectory:DirectoryNameOfTranslateHistory];
    }
    return _historyWormhole;
}

- (MMWormhole *)trashWormhole {
    if (!_trashWormhole) {
        _trashWormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:NameOfTDAppGroup
                                                              optionalDirectory:DirectoryNameOfTranslateTrash];
    }
    return _trashWormhole;
}

- (MMWormhole *)starredWormhole {
    if (!_starredWormhole) {
        _starredWormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:NameOfTDAppGroup
                                                                optionalDirectory:DirectoryNameOfTranslateStarred];
    }
    return _starredWormhole;
}

/**
 Add as spotlight searchable items
 
 @param translateItems   a translate dictionary. translate id as key, TDTranslateStoreItem as value.
 */
- (void)addAsSpotlightSeachableItemForTranslateItems:(NSDictionary<NSString*,TDTranslateStoreItem*>*)translateItems {
    if (translateItems.count == 0) return;
    
    NSMutableArray<CSSearchableItem*> *indexSearchableItems = [NSMutableArray array];
    [translateItems enumerateKeysAndObjectsUsingBlock:^(NSString *translateId,
                                                        TDTranslateStoreItem *storeItem,
                                                        BOOL *stop) {
        
        NSString *searchableItemId = TDSpotlightTranslateRecordsSearchableItemIdentfierWapper(translateId);
        if (!searchableItemId) return;
        
        // Add as spotlight searchable item
        NSString *domainIdentifier = TDSpotlightTranslateRecordsSearchableItemsDomainIdentifier;
        CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeTXNTextAndMultimediaData];
        attributeSet.title = storeItem.input;
        
        // Localized description
        NSUInteger resultCount = storeItem.translateResults.count;
        NSDictionary *descLocalized = @{@"en":[NSString stringWithFormat:@"Exists %@ translate results", @(resultCount)], @"zh-Hans":[NSString stringWithFormat:@"已有%@条翻译结果", @(resultCount)],
                                        @"zh-Hant":[NSString stringWithFormat:@"已有%@條翻譯結果", @(resultCount)]};
        CSLocalizedString *contentDesc = [[CSLocalizedString alloc] initWithLocalizedStrings:descLocalized];
        attributeSet.contentDescription = contentDesc;
        
        attributeSet.contentModificationDate = [NSDate date];
        attributeSet.thumbnailData = nil;
        
        // Custom key to indicate translate item
        CSCustomAttributeKey *translateIndicateKey = [[CSCustomAttributeKey alloc] initWithKeyName:@"translateIndicateFlag" searchable:NO searchableByDefault:NO unique:NO multiValued:NO];
        [attributeSet setValue:@(1) forCustomKey:translateIndicateKey];
        
        CSSearchableItem *searchableItem = [[CSSearchableItem alloc] initWithUniqueIdentifier:searchableItemId domainIdentifier:domainIdentifier attributeSet:attributeSet];
        
        [indexSearchableItems addObject:searchableItem];
    }];
    
    if (indexSearchableItems.count == 0) return;
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:indexSearchableItems completionHandler:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}


/**
 删除翻译记录的 spotlight 搜索项目

 @param translateId 要删除的翻译 id
 */
- (void)deleteSpotlightTranslateSearchableItemsWithTranslateId:(NSString *)translateId {
    NSString *searchableItemId = TDSpotlightTranslateRecordsSearchableItemIdentfierWapper(translateId);
    if (!searchableItemId) return;
    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithIdentifiers:@[searchableItemId] completionHandler:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (void)indexesAllTranslateRecordsSpotlightSearchavleItemsIfNeed {
    // Not support below iOS 10.0
    if ([UIDevice systemVersion] < 10) return;
    
    [self.translateSearchableItemsQuery cancel];
    self.translateSearchableItemsQuery = [[CSSearchQuery alloc] initWithQueryString:@"translateIndicateFlag==1" attributes:nil];
    __weak typeof(self)weakSelf = self;
    self.translateSearchableItemsQuery.foundItemsHandler = ^(NSArray<CSSearchableItem *> * _Nonnull items) {
        NSLog(@"foundItemsHandler, items.count: %@", @(items.count));
    };
    self.translateSearchableItemsQuery.completionHandler = ^(NSError * _Nullable error) {
        NSLog(@"completionHandler, error: %@\n foundItemCount: %@", error, @(weakSelf.translateSearchableItemsQuery.foundItemCount));
        if (!error && weakSelf.translateSearchableItemsQuery.foundItemCount == 0) {

            // indexes all translate records
            NSArray<NSString*> *allHistoryTranslateIds = ((OrderedDictionary*)[weakSelf.historyWormhole messageWithIdentifier:kTranslateInputAndIdDictionary]).allValues;
            NSArray<NSString*> *allStarredTranslateIds = ((OrderedDictionary*)[weakSelf.starredWormhole messageWithIdentifier:kTranslateInputAndIdDictionary]).allValues;
            
            NSMutableDictionary<NSString*,TDTranslateStoreItem*> *searchableItems = [NSMutableDictionary dictionary];
            for (NSString *_id in allHistoryTranslateIds) {
                TDTranslateStoreItem *existOne = [weakSelf.historyWormhole messageWithIdentifier:_id];
                if (existOne) searchableItems[_id] = existOne;
            }
            for (NSString *_id in allStarredTranslateIds) {
                TDTranslateStoreItem *existOne = [weakSelf.starredWormhole messageWithIdentifier:_id];
                if (existOne) searchableItems[_id] = existOne;
            }
            
            [weakSelf addAsSpotlightSeachableItemForTranslateItems:searchableItems];
        }
    };
    [self.translateSearchableItemsQuery start];
}

/**
 翻译
 
 @param input           输入
 @param destLanguage    翻译目标语言
 @param completeHandler 回调
 */
- (void)translateForInput:(NSString *)input
             destLanguage:(TDTextTranslateLanguage)destLanguage
          completeHandler:(void(^)(TodayTranslateResponse *resp, NSError *error))completeHandler {
    
    NSAssert(input.length != 0, @"input's length must > 0");
    
    void(^safelyCallHandler)(TodayTranslateResponse *, NSError *) = ^(TodayTranslateResponse *resp, NSError *error){
        if (completeHandler) {
            completeHandler(resp, error);
        }
    };
    
    // check exists
    TodayTranslateCheckExistRequest *checkExistRequest = ({
        TodayTranslateCheckExistRequest *info = [[TodayTranslateCheckExistRequest alloc] init];
        info.translateId = nil;
        info.input = input;
        info.checkExistInHistory = YES;
        info.checkExistInStarred = YES;
        info.checkExistInTrash = NO;
        info;
    });
    __block TodayTranslateCheckExistResponse *checkExistResp = [self checkExistWithRequest:^TodayTranslateCheckExistRequest *{
        return checkExistRequest;
    }];
    
    __block TDTranslateStoreItem *existItem = checkExistResp.existItemInHistory?:checkExistResp.existItemInStarred;
    if (existItem) {
        TDTranslateResultStoreItem *destStoreItem = [existItem translateResultForOutputLang:destLanguage];
        if (destStoreItem) {
            TodayTranslateResponse *resp = [[TodayTranslateResponse alloc] init];
            resp.result = [destStoreItem translateItem];
            resp.result.input = input;
            resp.result.inputLang = TDTextTranslateLanguage_unkown;
            resp.providerName = destStoreItem.providerName;
            resp.translateId = checkExistResp.translateId;
            resp.isFromCached = YES;
            safelyCallHandler(resp, nil);
            return;
        }
    }
    
    __block NSString *existItemTranslateId = checkExistResp.translateId;
    id<TDTranslateStrategy> translator = [[TDSearchManager alloc] init];
    [translator translateForText:input from:TDTextTranslateLanguage_unkown to:destLanguage completeHandler:^(TDTranslateItem *translateItem, NSError *error, NSString *serviceProvider) {
        
        checkExistResp = [self checkExistWithRequest:^TodayTranslateCheckExistRequest *{
            checkExistRequest.translateId = existItemTranslateId;
            return checkExistRequest;
        }];
        
        TDTranslateResultStoreItem *translateStoreItem = nil;
        if (translateItem && !error) {
            translateStoreItem = [[TDTranslateResultStoreItem alloc] initWithOutputLang:translateItem.outputLang
                                                                                 output:translateItem.output
                                                                           providerName:serviceProvider];
        }
        
        NSString *translateId = nil;
        TodayDataController0012 *dataController = [[TodayDataController0012 alloc] init];
        existItem = checkExistResp.existItemInHistory?:checkExistResp.existItemInStarred;
        if (existItem && translateStoreItem) {
            // update
            [dataController updateHistoryAndStarredWithRequest:^TodayTranslateHistoryUpdateRequest *{
                TodayTranslateHistoryUpdateRequest *info = [[TodayTranslateHistoryUpdateRequest alloc] init];
                info.translateId = checkExistResp.translateId;
                info.updateTranslateItems = @[translateStoreItem];
                return info;
            }];
            
            translateId = checkExistResp.translateId;
        } else {
            // add a new record even though error occurs
            translateId = [dataController saveOrUpdateHistory:({
                TDTranslateStoreItem *storeItm = [[TDTranslateStoreItem alloc] init];
                storeItm.input = input;
                storeItm.translateResults = translateStoreItem?@[translateStoreItem]:nil;
                storeItm;
            })];
        }
        
        TodayTranslateResponse *resp = [[TodayTranslateResponse alloc] init];
        resp.result = translateItem;
        resp.providerName = serviceProvider;
        resp.translateId = translateId;
        resp.isFromCached = NO;

        safelyCallHandler(resp, error);
    }];
}

+ (void)caculateListQueryOffset:(NSUInteger *)offsetHolder
                          limit:(NSUInteger *)limitHolder
        withReferTranslateIndex:(NSInteger)referIdx
                     totalCount:(NSUInteger)totalCount
                       queryNum:(NSInteger)queryNum {
    
    NSUInteger offset = ({
        NSInteger holder = 0;
        if (queryNum > 0) {
            holder = referIdx + 1;
        } else {
            holder = referIdx + queryNum;
        }
        if (holder < 0) {
            holder = 0;
        }
        holder;
    });
    NSUInteger limit = ({
        NSUInteger holder = 0;
        if (queryNum < 0 && referIdx >= offset ) {
            holder = MIN(ABS(queryNum), referIdx - offset);
        } else if (queryNum > 0){
            holder = MIN(queryNum, (totalCount - offset));
        }
        holder;
    });
    
    if (offsetHolder != NULL) {
        *offsetHolder = offset;
    }
    if (limitHolder != NULL) {
        *limitHolder = limit;
    }
}

/**
 获取历史列表
 */
- (TodayTranslateListResponse<TodayTranslateHistoryItem *> *)loadHistoryWithRequest2:(TodayTranslateHistoryRequest2*(^)())requestBlock {
    
    TodayTranslateHistoryRequest2 *request = requestBlock?requestBlock():nil;
    NSAssert(request != nil, @"requestBlock can't return nil");
    NSAssert(request.num != 0, @"request.num can't be 0");
    
    TodayTranslateListResponse<TodayTranslateHistoryItem *> *response = [[TodayTranslateListResponse<TodayTranslateHistoryItem *> alloc] init];
    response.referTranslateId = request.referTranslateId;
    
    OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.historyWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
    
    NSInteger referIdx = -1;
    if (request.referTranslateId) {
        referIdx = [translateAndIdDictionary.allValues indexOfObject:request.referTranslateId];
        if (referIdx == NSNotFound) {
            return response;
        } else {
            response.referItemIfExist = YES;
        }
    } else if (request.num <= 0) {
        return response;
    }
    
    NSUInteger offset;
    NSUInteger limit;
    [self.class caculateListQueryOffset:&offset
                                  limit:&limit
                withReferTranslateIndex:referIdx
                             totalCount:translateAndIdDictionary.count
                               queryNum:request.num];
    
    if (limit == 0) {
        return response;
    }
    
    
    NSMutableArray<TodayTranslateHistoryItem *> *historyList = [NSMutableArray<TodayTranslateHistoryItem *> array];
    for (NSUInteger i = offset; i < (offset + limit); i ++) {
        NSString *translateId = translateAndIdDictionary.allValues[i];
        TDTranslateStoreItem *existStoreItem = [self.historyWormhole messageWithIdentifier:translateId];
        if (!existStoreItem) {
            continue;
        }
        
        TodayTranslateHistoryItem *historyItem = [[TodayTranslateHistoryItem alloc] init];
        historyItem.translateId = translateId;
        historyItem.item = existStoreItem;
        
        if (request.loadStarredState) {
            TDTranslateStoreItem *starredStoreItem = [self.starredWormhole messageWithIdentifier:translateId];
            historyItem.starred = (starredStoreItem != nil);
        }
        
        [historyList addObject:historyItem];
    }
    
    response.list = historyList;
    return response;
}

/**
 获取收藏列表
 */
- (TodayTranslateListResponse<TodayTranslateHistoryItem *> *)loadStarredListWithRequest2:(TodayTranslateStarListRequest2*(^)())requestBlock {

    TodayTranslateStarListRequest2 *request = requestBlock?requestBlock():nil;
    NSAssert(request != nil, @"requestBlock can't return nil");
    NSAssert(request.num != 0, @"request.num can't be 0");
    
    TodayTranslateListResponse<TodayTranslateHistoryItem *> *response = [[TodayTranslateListResponse<TodayTranslateHistoryItem *> alloc] init];
    response.referTranslateId = request.referTranslateId;
    
    OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.starredWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
    
    NSInteger referIdx = -1;
    if (request.referTranslateId) {
        referIdx = [translateAndIdDictionary.allValues indexOfObject:request.referTranslateId];
        if (referIdx == NSNotFound) {
            return response;
        } else {
            response.referItemIfExist = YES;
        }
    } else if (request.num <= 0) {
        return response;
    }
    
    NSUInteger offset;
    NSUInteger limit;
    [self.class caculateListQueryOffset:&offset
                                  limit:&limit
                withReferTranslateIndex:referIdx
                             totalCount:translateAndIdDictionary.count
                               queryNum:request.num];
    
    if (limit == 0) {
        return response;
    }
    
    NSMutableArray<TodayTranslateHistoryItem *> *starredList = [NSMutableArray<TodayTranslateHistoryItem *> array];
    for (NSUInteger i = offset; i < (offset + limit); i ++) {
        NSString *translateId = translateAndIdDictionary.allValues[i];
        TDTranslateStoreItem *existStoreItem = [self.starredWormhole messageWithIdentifier:translateId];
        if (!existStoreItem) {
            continue;
        }
        
        TodayTranslateHistoryItem *starredItem = [[TodayTranslateHistoryItem alloc] init];
        starredItem.translateId = translateId;
        starredItem.item = existStoreItem;
        starredItem.starred = YES;
        
        [starredList addObject:starredItem];
    }
    
    response.list = starredList;
    return response;
}

- (TodayTranslateListResponse<TodayTranslateHistoryItem *> *)loadTrashedListWithRequest2:(TodayTrashedListRequest2*(^)())requestBlock {
    
    TodayTrashedListRequest2 *request = requestBlock?requestBlock():nil;
    NSAssert(request != nil, @"requestBlock can't return nil");
    NSAssert(request.num != 0, @"request.num can't be 0");
    
    TodayTranslateListResponse<TodayTranslateHistoryItem *> *response = [[TodayTranslateListResponse<TodayTranslateHistoryItem *> alloc] init];
    response.referTranslateId = request.referTranslateId;
    
    OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.trashWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
    
    NSInteger referIdx = -1;
    if (request.referTranslateId) {
        referIdx = [translateAndIdDictionary.allValues indexOfObject:request.referTranslateId];
        if (referIdx == NSNotFound) {
            return response;
        } else {
            response.referItemIfExist = YES;
        }
    } else if (request.num <= 0) {
        return response;
    }
    
    NSUInteger offset;
    NSUInteger limit;
    [self.class caculateListQueryOffset:&offset
                                  limit:&limit
                withReferTranslateIndex:referIdx
                             totalCount:translateAndIdDictionary.count
                               queryNum:request.num];
    
    if (limit == 0) {
        return response;
    }
    
    NSMutableArray<TodayTranslateHistoryItem *> *trashedList = [NSMutableArray<TodayTranslateHistoryItem *> array];
    for (NSUInteger i = offset; i < (offset + limit); i ++) {
        NSString *translateId = translateAndIdDictionary.allValues[i];
        TDTranslateStoreItem *existStoreItem = [self.trashWormhole messageWithIdentifier:translateId];
        if (!existStoreItem) {
            continue;
        }
        
        TodayTranslateHistoryItem *trashedItem = [[TodayTranslateHistoryItem alloc] init];
        trashedItem.translateId = translateId;
        trashedItem.item = existStoreItem;
        
        [trashedList addObject:trashedItem];
    }
    
    response.list = trashedList;
    return response;
}


/**
 检查记录是否存在
 
 @param requestBlock 请求 block
 @return exist item if exists
 */
- (TodayTranslateCheckExistResponse *)checkExistWithRequest:(TodayTranslateCheckExistRequest*(^)())requestBlock {
    
    TodayTranslateCheckExistRequest *request = requestBlock?requestBlock():nil;
    NSAssert(request != nil, @"requestBlock can't return nil");
    
    TodayTranslateCheckExistResponse *resp = [[TodayTranslateCheckExistResponse alloc] init];
    
    // 检查是否在历史记录中
    if (request.checkExistInHistory) {
        NSString *translateId = request.translateId;
        if (!translateId) {
            OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.historyWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
            translateId = translateAndIdDictionary[request.input];
        }
        if (translateId) {
            resp.existItemInHistory = [self.historyWormhole messageWithIdentifier:translateId];
            resp.translateId = resp.translateId?:translateId;
        }
    }
    
    // 检查是否在收藏记录中
    if (request.checkExistInStarred) {
        NSString *translateId = request.translateId;
        if (!translateId) {
            OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.starredWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
            translateId = translateAndIdDictionary[request.input];
        }
        if (translateId) {
            resp.existItemInStarred = [self.starredWormhole messageWithIdentifier:translateId];
            resp.translateId = resp.translateId?:translateId;
        }
    }
    
    // 检查是否在垃圾篓中
    if (request.checkExistInTrash) {
        NSString *translateId = request.translateId;
        if (!translateId) {
            OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.trashWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
            translateId = translateAndIdDictionary[request.input];
        }
        if (translateId) {
            resp.existItemInTrash = [self.trashWormhole messageWithIdentifier:translateId];
            resp.translateId = resp.translateId?:translateId;
        }
    }
    
    resp.translateId = resp.translateId?:request.translateId;
    return resp;
}

/**
 保存或更新一个记录
 
 @param storeItem 保存的记录信息
 @return translate id
 */
- (NSString *)saveOrUpdateHistory:(TDTranslateStoreItem *)storeItem {
    
    NSAssert(storeItem != nil, @"storeItem can't return nil");
    NSAssert(storeItem.input.length != 0, @"storeItem.input can't be empty");
    
    // check exist
    TodayTranslateCheckExistResponse *checkExistResp = [self checkExistWithRequest:^TodayTranslateCheckExistRequest *{
        TodayTranslateCheckExistRequest *info = [[TodayTranslateCheckExistRequest alloc] init];
        info.translateId = nil;
        info.input = storeItem.input;
        info.checkExistInHistory = YES;
        info.checkExistInStarred = YES;
        info.checkExistInTrash = NO;
        return info;
    }];
    
    NSString *translateId = nil;
    {
        // update or add new history
        NSString *historyTranslateId = checkExistResp.translateId?:[NSString stringWithUUID];
        
        OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.historyWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
        MutableOrderedDictionary *mutableDict = [MutableOrderedDictionary dictionary];
        if (translateAndIdDictionary.count > 0) {
            [mutableDict addEntriesFromDictionary:translateAndIdDictionary];
        }
        [mutableDict removeObjectForKey:storeItem.input];
        [mutableDict insertObject:historyTranslateId forKey:storeItem.input atIndex:0];
        [self.historyWormhole passMessageObject:mutableDict identifier:kTranslateInputAndIdDictionary];
        [self.historyWormhole passMessageObject:storeItem identifier:historyTranslateId];
        
        translateId = historyTranslateId;
        
        [self addAsSpotlightSeachableItemForTranslateItems:@{translateId:storeItem}];
    }
    
    {
        // update starred if need
        if (checkExistResp.existItemInStarred) {
            
            OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.starredWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
            MutableOrderedDictionary *mutableDict = [MutableOrderedDictionary dictionary];
            if (translateAndIdDictionary.count > 0) {
                [mutableDict addEntriesFromDictionary:translateAndIdDictionary];
            }
            [mutableDict removeObjectForKey:storeItem.input];
            [mutableDict insertObject:checkExistResp.translateId forKey:storeItem.input atIndex:0];
            [self.starredWormhole passMessageObject:mutableDict identifier:kTranslateInputAndIdDictionary];
            [self.starredWormhole passMessageObject:storeItem identifier:checkExistResp.translateId];
        }
    }
    
    return translateId;
}


/**
 更新历史记录和收藏
 
 @param requestBlock 请求 block
 @return 记录信息
 */
- (TodayTranslateHistoryItem *)updateHistoryAndStarredWithRequest:(TodayTranslateHistoryUpdateRequest*(^)())requestBlock {
    
    TodayTranslateHistoryUpdateRequest *request = requestBlock?requestBlock():nil;
    NSAssert(request != nil, @"requestBlock can't return nil");
    NSAssert(request.translateId != nil, @"request.translateId can't be nil");
    
    TodayTranslateHistoryItem *resp = [[TodayTranslateHistoryItem alloc] init];
    resp.translateId = request.translateId;
    
    NSArray<TDTranslateResultStoreItem *>*(^mergeTranslateResults)(NSArray *, NSArray *) = ^NSArray<TDTranslateResultStoreItem *>*(NSArray *results1, NSArray *results2) {
        
        MutableOrderedDictionary<NSNumber *, TDTranslateResultStoreItem *> *translateResultsDict = [MutableOrderedDictionary<NSNumber *, TDTranslateResultStoreItem *> dictionary];
        [results1 enumerateObjectsUsingBlock:^(TDTranslateResultStoreItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            translateResultsDict[@(obj.outputLang)] = obj;
        }];
        
        [results2 enumerateObjectsUsingBlock:^(TDTranslateResultStoreItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            translateResultsDict[@(obj.outputLang)] = obj;
        }];
        
        return translateResultsDict.allValues;
        
    };
    
    {
        // update history
        
        TDTranslateStoreItem *existHistoryItem = [self.historyWormhole messageWithIdentifier:request.translateId];
        if (existHistoryItem && request.updateTranslateItems.count > 0) {
            existHistoryItem.translateResults = mergeTranslateResults(existHistoryItem.translateResults, request.updateTranslateItems);
            [self.historyWormhole passMessageObject:existHistoryItem identifier:request.translateId];
            
            resp.item = resp.item?:existHistoryItem;
        }
    }
    
    {
        // update starred
        
        TDTranslateStoreItem *existStarredItem = [self.starredWormhole messageWithIdentifier:request.translateId];
        if (existStarredItem && request.updateTranslateItems.count > 0) {
            existStarredItem.translateResults = mergeTranslateResults(existStarredItem.translateResults, request.updateTranslateItems);
            [self.starredWormhole passMessageObject:existStarredItem identifier:request.translateId];
            
            resp.item = resp.item?:existStarredItem;
        }
        if (existStarredItem) {
            resp.starred = YES;
        }
    }
    
    if (resp.item && resp.translateId) {
        [self addAsSpotlightSeachableItemForTranslateItems:@{resp.translateId:resp.item}];
    }

    return resp;
}


/**
 标星或取消
 
 @param requestBlock 请求 block
 @return 是否成功
 */
- (BOOL)starOrNotWithRequest:(TodayTranslateStarRequest*(^)())requestBlock {
    
    TodayTranslateStarRequest *request = requestBlock?requestBlock():nil;
    NSAssert(request != nil, @"requestBlock can't return nil");
    NSAssert(request.translateId != nil, @"request.translateId can't be nil");
    
    if (request.isToStarOrNot) {
        // 标星
        
        TDTranslateStoreItem *existHistoryItem = [self.historyWormhole messageWithIdentifier:request.translateId];
        if (existHistoryItem) {
            // save as a starred
            
            OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.starredWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
            MutableOrderedDictionary *mutableDict = [MutableOrderedDictionary dictionary];
            if (translateAndIdDictionary.count > 0) {
                [mutableDict addEntriesFromDictionary:translateAndIdDictionary];
            }
            [mutableDict removeObjectForKey:existHistoryItem.input];
            [mutableDict insertObject:request.translateId forKey:existHistoryItem.input atIndex:0];
            [self.starredWormhole passMessageObject:mutableDict identifier:kTranslateInputAndIdDictionary];
            [self.starredWormhole passMessageObject:existHistoryItem identifier:request.translateId];
            
            return YES;
        }
        NSLog(@"not exist history with this translate id(:%@)", request.translateId);
        return NO;
        
    } else {
    
        // 取消星标
        
        TDTranslateStoreItem *existStarredItem = [self.starredWormhole messageWithIdentifier:request.translateId];
        if (existStarredItem) {
            // remove this starred
            
            OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.starredWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
            MutableOrderedDictionary *mutableDict = [MutableOrderedDictionary dictionary];
            if (translateAndIdDictionary.count > 0) {
                [mutableDict addEntriesFromDictionary:translateAndIdDictionary];
            }
            [mutableDict removeObjectForKey:existStarredItem.input];
            [self.starredWormhole passMessageObject:mutableDict identifier:kTranslateInputAndIdDictionary];
            [self.starredWormhole clearMessageContentsForIdentifier:request.translateId];
        
            // restore in history
            [self saveOrUpdateHistory:existStarredItem];
        }
        return YES;
    }

    return YES;
}


/**
 放入垃圾篓
 
 @param requestBlock 请求 block
 @return 是否成功
 */
- (BOOL)moveToTrashWithRequest:(TodayTranslateMoveToTrashRequest*(^)())requestBlock {
    
    TodayTranslateMoveToTrashRequest *request = requestBlock?requestBlock():nil;
    NSAssert(request != nil, @"requestBlock can't return nil");
    NSAssert(request.translateId != nil, @"request.translateId can't be nil");
    
    void(^moveToTrash)(TDTranslateStoreItem *, NSString *) = ^(TDTranslateStoreItem *storeItem, NSString *translateId){
        if (!storeItem || !translateId) return;
        
        OrderedDictionary<NSString *, NSString *> *trashInputAndIdDictionary = [self.trashWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
        MutableOrderedDictionary *mutableDict = [MutableOrderedDictionary dictionary];
        if (trashInputAndIdDictionary.count > 0) {
            [mutableDict addEntriesFromDictionary:trashInputAndIdDictionary];
        }
        [mutableDict removeObjectForKey:storeItem.input];
        [mutableDict insertObject:translateId forKey:storeItem.input atIndex:0];
        [self.trashWormhole passMessageObject:mutableDict identifier:kTranslateInputAndIdDictionary];
        [self.trashWormhole passMessageObject:storeItem identifier:translateId];
    };
    
    TDTranslateStoreItem *existStarredItem = [self.starredWormhole messageWithIdentifier:request.translateId];
    if (request.deleteExistInStarred && existStarredItem) {
        // cancel starred
        OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.starredWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
        MutableOrderedDictionary *mutableDict = [MutableOrderedDictionary dictionary];
        if (translateAndIdDictionary.count > 0) {
            [mutableDict addEntriesFromDictionary:translateAndIdDictionary];
        }
        [mutableDict removeObjectForKey:existStarredItem.input];
        [self.starredWormhole passMessageObject:mutableDict identifier:kTranslateInputAndIdDictionary];
        [self.starredWormhole clearMessageContentsForIdentifier:request.translateId];
        
        if (!request.disrestorable) {
            // move to trash
            moveToTrash(existStarredItem, request.translateId);
        }
    }
    
    TDTranslateStoreItem *existHistoryItem = [self.historyWormhole messageWithIdentifier:request.translateId];
    if (request.deleteExistInHistory && existHistoryItem) {
        // remove this history
        OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.historyWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
        MutableOrderedDictionary *mutableDict = [MutableOrderedDictionary dictionary];
        if (translateAndIdDictionary.count > 0) {
            [mutableDict addEntriesFromDictionary:translateAndIdDictionary];
        }
        [mutableDict removeObjectForKey:existHistoryItem.input];
        [self.historyWormhole passMessageObject:mutableDict identifier:kTranslateInputAndIdDictionary];
        [self.historyWormhole clearMessageContentsForIdentifier:request.translateId];
        
        if (!request.disrestorable) {
            // move to trash
            moveToTrash(existHistoryItem, request.translateId);
        }
    }
    
    // 如果从星标、历史记录中都删除，则删除其搜索索引
    BOOL deleteFromStarred = (!existStarredItem) || (existStarredItem && request.deleteExistInStarred);
    BOOL deleteFromHistory = (!existHistoryItem) || (existHistoryItem && request.deleteExistInHistory);
    if (deleteFromStarred && deleteFromHistory) {
        [self deleteSpotlightTranslateSearchableItemsWithTranslateId:request.translateId];
    }
    
    if (request.disrestorable) {
        // Clear lastCopiedTranslate if need
        TodayCopiedTranslateMeta *lastCopiedTranslate = [self lastCopiedTranslate].meta;
        if ([request.translateId isEqualToString:lastCopiedTranslate.translateId]) {
            [self setLastCopiedTranslate:nil];
        }
    }
    
    return YES;
}



/**
 从垃圾篓中恢复到历史记录
 
 @param translateId id of translation
 @return 恢复的记录
 */
- (TodayTranslateHistoryItem *)restoreToHistoryFromTrashWithTranslateId:(NSString *)translateId {
    
    NSAssert(translateId != nil, @"translateId can't be nil");
    
    TodayTranslateCheckExistResponse *checkExistResp
        = [self checkExistWithRequest:^TodayTranslateCheckExistRequest *{
        TodayTranslateCheckExistRequest *info = [[TodayTranslateCheckExistRequest alloc] init];
        info.translateId = translateId;
        info.checkExistInHistory = YES;
        info.checkExistInTrash = YES;
        return info;
    }];
    
    if (!checkExistResp.existItemInTrash) {
        return nil;
    }
    
    // clear from trash
    [self clearFromTrashWithTranslateId:translateId];
    
    TodayTranslateHistoryItem *historyItem = [[TodayTranslateHistoryItem alloc] init];
    historyItem.item = checkExistResp.existItemInTrash;
    historyItem.starred = NO;
    
    if (checkExistResp.existItemInHistory) {
        historyItem.translateId = translateId;
    } else {
        // save history
        historyItem.translateId = [self saveOrUpdateHistory:checkExistResp.existItemInTrash];
    }
    
    return historyItem;
}

/**
 彻底清除垃圾篓中的某条记录
 
 @param translateId translateId id of translation
 */
- (void)clearFromTrashWithTranslateId:(NSString *)translateId {
    
    if (!translateId) return;
    
    // clear from trash
    OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.trashWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
    
    NSInteger idx = [translateAndIdDictionary.allValues indexOfObject:translateId];
    if (idx != NSNotFound) {
        MutableOrderedDictionary *mutableDict = [MutableOrderedDictionary dictionary];
        if (translateAndIdDictionary.count > 0) {
            [mutableDict addEntriesFromDictionary:translateAndIdDictionary];
        }
        [mutableDict removeObjectAtIndex:idx];
        [self.trashWormhole passMessageObject:mutableDict identifier:kTranslateInputAndIdDictionary];
    }
    [self.trashWormhole clearMessageContentsForIdentifier:translateId];
}


/**
 彻底清除所有垃圾篓中的记录
 */
- (void)clearAllFromTrash {
    
    [[self class] clearAllButReserve:0 inWormhole:self.trashWormhole];
}

/**
 保留制定数量的记录，其他都彻底清除（包括历史记录、收藏记录和垃圾桶）
 
 @param reserveNum 保留记录的数量
 */
- (void)clearAllButReserve:(NSUInteger)reserveNum {
    // History clear
    [[self class] clearAllButReserve:reserveNum inWormhole:self.historyWormhole];
    
    // Starred clear
    [[self class] clearAllButReserve:reserveNum inWormhole:self.starredWormhole];
    
    // Trash clear
    [[self class] clearAllButReserve:reserveNum inWormhole:self.trashWormhole];
}

/**
 设置最后一次拷贝的翻译信息
 
 @param meta 最后一次拷贝的翻译信息
 */
- (void)setLastCopiedTranslate:(TodayCopiedTranslateMeta *)meta {
    if (!meta) {
        [self.historyWormhole clearMessageContentsForIdentifier:kLastCopiedTranslateMeta];
    } else {
        TodayTranslateCheckExistResponse *checkResp
        = [self checkExistWithRequest:^TodayTranslateCheckExistRequest *{
            TodayTranslateCheckExistRequest *info = [TodayTranslateCheckExistRequest new];
            info.translateId = meta.translateId;
            info.checkExistInStarred = YES;
            info.checkExistInHistory = YES;
            info.checkExistInTrash = YES;
            return info;
        }];
        if (checkResp.existItemInHistory
            || checkResp.existItemInStarred
            || checkResp.existItemInTrash) {
            // 存在该翻译，则保存该次拷贝
            [self.historyWormhole passMessageObject:meta identifier:kLastCopiedTranslateMeta];
        }
    }
}

/**
 获取最后一次拷贝的翻译信息
 
 @return 最后一次拷贝的翻译信息
 */
- (TodayCopiedTranslateResponse *)lastCopiedTranslate {
    TodayCopiedTranslateResponse *response = [[TodayCopiedTranslateResponse alloc] init];
    TodayCopiedTranslateMeta *meta = [self.historyWormhole messageWithIdentifier:kLastCopiedTranslateMeta];
    if (meta) {
        response.meta = meta;
        if (meta.translateId) {
            TodayTranslateCheckExistResponse *checkResp
            = [self checkExistWithRequest:^TodayTranslateCheckExistRequest *{
                TodayTranslateCheckExistRequest *info = [TodayTranslateCheckExistRequest new];
                info.translateId = meta.translateId;
                info.checkExistInStarred = NO;
                info.checkExistInHistory = NO;
                info.checkExistInTrash = YES;
                return info;
            }];
            response.isTrashed = (checkResp.existItemInTrash != nil);
        }
    }
    return response;
}

- (void)updateOrderToFirst:(NSString *)translateId {
    if (!translateId) return;
    
    TodayTranslateCheckExistResponse *checkResp
    = [self checkExistWithRequest:^TodayTranslateCheckExistRequest *{
        TodayTranslateCheckExistRequest *info = [TodayTranslateCheckExistRequest new];
        info.translateId = translateId;
        info.checkExistInStarred = YES;
        info.checkExistInHistory = YES;
        return info;
    }];
    TDTranslateStoreItem *existItemInHistory = checkResp.existItemInHistory;
    if (existItemInHistory) {
        OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.historyWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
        MutableOrderedDictionary *mutableDict = [MutableOrderedDictionary dictionary];
        if (translateAndIdDictionary.count > 0) {
            [mutableDict addEntriesFromDictionary:translateAndIdDictionary];
        }
        [mutableDict removeObjectForKey:existItemInHistory.input];
        [mutableDict insertObject:translateId forKey:existItemInHistory.input atIndex:0];
        [self.historyWormhole passMessageObject:mutableDict identifier:kTranslateInputAndIdDictionary];
    }
    
    TDTranslateStoreItem *existItemInStarred = checkResp.existItemInStarred;
    if (existItemInStarred) {
        OrderedDictionary<NSString *, NSString *> *translateAndIdDictionary = [self.starredWormhole messageWithIdentifier:kTranslateInputAndIdDictionary];
        MutableOrderedDictionary *mutableDict = [MutableOrderedDictionary dictionary];
        if (translateAndIdDictionary.count > 0) {
            [mutableDict addEntriesFromDictionary:translateAndIdDictionary];
        }
        [mutableDict removeObjectForKey:existItemInStarred.input];
        [mutableDict insertObject:translateId forKey:existItemInStarred.input atIndex:0];
        [self.starredWormhole passMessageObject:mutableDict identifier:kTranslateInputAndIdDictionary];
    }
}

@end

@implementation TodayTranslateResponse
@end

@implementation TodayTranslateListResponse
@end

@implementation TodayTranslateHistoryItem
@end

@implementation TodayTranslateHistoryRequest2
@end

@implementation TodayTranslateStarListRequest2
@end

@implementation TodayTrashedListRequest2
@end

@implementation TodayTranslateCheckExistRequest
@end

@implementation TodayTranslateCheckExistResponse
@end

@implementation TodayTranslateHistoryUpdateRequest
@end

@implementation TodayTranslateStarRequest
@end

@implementation TodayTranslateMoveToTrashRequest
@end

@implementation TodayCopiedTranslateMeta

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.translateId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(translateId))];
        self.copiedString = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(copiedString))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.translateId forKey:NSStringFromSelector(@selector(translateId))];
    [aCoder encodeObject:self.copiedString forKey:NSStringFromSelector(@selector(copiedString))];
}

- (id)copyWithZone:(NSZone *)zone {
    TodayCopiedTranslateMeta *cp = [[TodayCopiedTranslateMeta allocWithZone:zone] init];
    cp.translateId = self.translateId;
    cp.copiedString = self.copiedString;
    return cp;
}

@end

@implementation TodayCopiedTranslateResponse
@end
