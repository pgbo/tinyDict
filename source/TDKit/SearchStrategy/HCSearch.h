//
//  HCSearch.h
//  tinyDict
//
//  Created by guangbool on 2017/3/8.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDSearchStrategy.h"

// 搜索
@interface HCSearch : NSObject <TDSearchStrategy>

@end

// 翻译
@interface HCSearch (TDTranslate) <TDTranslateStrategy>

@end
