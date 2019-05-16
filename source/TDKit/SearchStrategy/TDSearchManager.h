//
//  TDSearchManager.h
//  tinyDict
//
//  Created by guangbool on 2017/3/28.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDSearchStrategy.h"

@interface TDSearchManager : NSObject <TDSearchStrategy>

@end

@interface TDSearchManager (TDTranslate) <TDTranslateStrategy>

@end
