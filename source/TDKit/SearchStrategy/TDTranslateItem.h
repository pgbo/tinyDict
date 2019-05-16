//
//  TDTranslateItem.h
//  tinyDict
//
//  Created by guangbool on 2017/3/31.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDConstants.h"

@interface TDTranslateItem : NSObject <NSCopying, NSCoding>

@property (nonatomic, copy) NSString *input;
@property (nonatomic, assign) TDTextTranslateLanguage inputLang;
@property (nonatomic, copy) NSString *output;
@property (nonatomic, assign) TDTextTranslateLanguage outputLang;

- (instancetype)initWithInput:(NSString *)input inputLang:(TDTextTranslateLanguage)inputLang;
- (instancetype)initWithInput:(NSString *)input inputLang:(TDTextTranslateLanguage)inputLang outputLang:(TDTextTranslateLanguage)outputLang;

@end
