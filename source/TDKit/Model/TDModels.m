//
//  TDModels.m
//  tinyDict
//
//  Created by guangbool on 2017/3/23.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TDModels.h"

@implementation TDQueryItemState

- (id)copyWithZone:(NSZone *)zone {
    TDQueryItemState *cop = [[TDQueryItemState allocWithZone:zone]init];
    cop.starred = self.starred;
    cop.trashy = self.trashy;
    return cop;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.starred = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(starred))];
        self.trashy = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(trashy))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:self.starred forKey:NSStringFromSelector(@selector(starred))];
    [aCoder encodeBool:self.trashy forKey:NSStringFromSelector(@selector(trashy))];
}

@end

@implementation TDQueryItemResult

- (id)copyWithZone:(NSZone *)zone {
    TDQueryItemResult *cop = [[TDQueryItemResult allocWithZone:zone]init];
    cop.query = self.query;
    cop.resultOfDictQuery = self.resultOfDictQuery;
    cop.dictProvider = self.dictProvider;
    cop.resultOfTranslate = self.resultOfTranslate;
    cop.translateProvider = self.translateProvider;
    cop.lastModifyTimestamp = self.lastModifyTimestamp;
    return cop;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.query = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(query))];
        self.resultOfDictQuery = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(resultOfDictQuery))];
        self.dictProvider = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dictProvider))];
        self.resultOfTranslate = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(resultOfTranslate))];
        self.translateProvider = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(translateProvider))];
        self.lastModifyTimestamp = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(lastModifyTimestamp))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.query forKey:NSStringFromSelector(@selector(query))];
    [aCoder encodeObject:self.resultOfDictQuery forKey:NSStringFromSelector(@selector(resultOfDictQuery))];
    [aCoder encodeObject:self.dictProvider forKey:NSStringFromSelector(@selector(dictProvider))];
    [aCoder encodeObject:self.resultOfTranslate forKey:NSStringFromSelector(@selector(resultOfTranslate))];
    [aCoder encodeObject:self.translateProvider forKey:NSStringFromSelector(@selector(translateProvider))];
    [aCoder encodeInteger:self.lastModifyTimestamp forKey:NSStringFromSelector(@selector(lastModifyTimestamp))];
}

@end


@implementation TDTranslateResultStoreItem

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    TDTextTranslateLanguage outputLang = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(outputLang))];
    NSString *output = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(output))];
    NSString *providerName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(providerName))];
    
    return [self initWithOutputLang:outputLang output:output providerName:providerName];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.outputLang forKey:NSStringFromSelector(@selector(outputLang))];
    [aCoder encodeObject:self.output forKey:NSStringFromSelector(@selector(output))];
    [aCoder encodeObject:self.providerName forKey:NSStringFromSelector(@selector(providerName))];
}

- (id)copyWithZone:(NSZone *)zone {
    TDTranslateResultStoreItem *cp = [[TDTranslateResultStoreItem allocWithZone:zone] initWithOutputLang:self.outputLang output:self.output providerName:self.providerName];
    return cp;
}

- (instancetype)initWithOutputLang:(TDTextTranslateLanguage)outputLang
                            output:(NSString *)output
                      providerName:(NSString *)providerName {
    if (self = [super init]) {
        self.outputLang = outputLang;
        self.output = output;
        self.providerName = providerName;
    }
    return self;
}

- (instancetype)initWithTranslateItem:(TDTranslateItem *)translateItem {
    return [self initWithOutputLang:translateItem.outputLang
                             output:translateItem.output
                       providerName:nil];
}

- (TDTranslateItem *)translateItem {
    TDTranslateItem *item = [[TDTranslateItem alloc] init];
    item.output = self.output;
    item.outputLang = self.outputLang;
    return item;
}

@end

@implementation TDTranslateStoreItem

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.input = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(input))];
        self.translateResults = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(translateResults))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.input forKey:NSStringFromSelector(@selector(input))];
    [aCoder encodeObject:self.translateResults forKey:NSStringFromSelector(@selector(translateResults))];
}

- (id)copyWithZone:(NSZone *)zone {
    TDTranslateStoreItem *cp = [[TDTranslateStoreItem allocWithZone:zone] init];
    cp.input = self.input;
    cp.translateResults = self.translateResults;
    return cp;
}

- (TDTranslateResultStoreItem *)translateResultForOutputLang:(TDTextTranslateLanguage)outputLang {
    
    TDTranslateResultStoreItem *holder = nil;
    
    NSArray<TDTranslateResultStoreItem *> *results = [self.translateResults copy];
    for (TDTranslateResultStoreItem *item in results) {
        if (item.outputLang == outputLang) {
            holder = item;
            break;
        }
    }
    
    return holder;
}

- (NSArray<NSNumber *> *)preferredOutputLanguagesOrderWithDefault:(NSArray<NSNumber *> *)defaultOrder {
    
    __block NSMutableArray<NSNumber *> *preferred = [NSMutableArray<NSNumber *> array];
    if (defaultOrder.count > 0) {
        [preferred addObjectsFromArray:defaultOrder];
    }
    [self.translateResults enumerateObjectsUsingBlock:^(TDTranslateResultStoreItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *outputLang = @(obj.outputLang);
        if (![preferred containsObject:outputLang]) {
            [preferred addObject:outputLang];
        }
    }];
    
    return preferred;
}

@end
