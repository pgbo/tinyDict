//
//  YDFYSearch.h
//  tinyDict
//
//  Created by guangbool on 2017/3/9.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDSearchStrategy.h"

// 查询
@interface YDFYSearch : NSObject <TDSearchStrategy>

@end

// TODO: 翻译接口
@interface YDFYSearch (TDTranslate) <TDTranslateStrategy>

@end
