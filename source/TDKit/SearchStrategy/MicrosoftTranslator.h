//
//  MicrosoftTranslator.h
//  tinyDict
//
//  Created by guangbool on 2017/3/28.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDSearchStrategy.h"


/**
 微软翻译系列
 */
@interface MicrosoftTranslator : NSObject <TDTranslateStrategy>

@property (nonatomic, readonly) NSString *appId;

/**
 需要注册 app id，才能使用微软翻译 api

 @param appId appId
 @return the instance
 */
- (instancetype)initWithAppId:(NSString *)appId;
- (instancetype)init NS_UNAVAILABLE;

+ (NSString *)languageStringForSearchType:(TDTextTranslateLanguage)type;

@end
