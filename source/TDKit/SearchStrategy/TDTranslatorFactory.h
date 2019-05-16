//
//  TDTranslatorFactory.h
//  tinyDict
//
//  Created by guangbool on 2017/3/31.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDSearchStrategy.h"

@interface TDTranslatorFactory : NSObject

+ (id<TDTranslateStrategy>)translatorWithProviderCode:(NSInteger)providerCode;

@end
