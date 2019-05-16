//
//  BDFYSearch.h
//  tinyDict
//
//  Created by guangbool on 2017/3/9.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDSearchStrategy.h"

// 查询
@interface BDFYSearch : NSObject <TDSearchStrategy>

@end

// 翻译
@interface BDFYSearch (TDTranslate) <TDTranslateStrategy>

+ (NSString *)languageStringForSearchType:(TDTextTranslateLanguage)type;

@end
