//
//  TDTranslateItem.m
//  tinyDict
//
//  Created by guangbool on 2017/3/31.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TDTranslateItem.h"

@implementation TDTranslateItem

- (instancetype)init {
    return [self initWithInput:nil inputLang:TDTextTranslateLanguage_unkown outputLang:TDTextTranslateLanguage_unkown];
}

- (instancetype)initWithInput:(NSString *)input inputLang:(TDTextTranslateLanguage)inputLang {
    return [self initWithInput:input inputLang:inputLang outputLang:TDTextTranslateLanguage_unkown];
}

- (instancetype)initWithInput:(NSString *)input inputLang:(TDTextTranslateLanguage)inputLang outputLang:(TDTextTranslateLanguage)outputLang {
    if (self = [super init]) {
        self.input = input;
        self.inputLang = inputLang;
        self.outputLang = outputLang;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.input = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(input))];
        self.inputLang = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(inputLang))];
        self.output = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(output))];
        self.outputLang = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(outputLang))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    self.input = [aCoder decodeObjectForKey:NSStringFromSelector(@selector(input))];
    self.inputLang = [aCoder decodeIntegerForKey:NSStringFromSelector(@selector(inputLang))];
    self.output = [aCoder decodeObjectForKey:NSStringFromSelector(@selector(output))];
    self.outputLang = [aCoder decodeIntegerForKey:NSStringFromSelector(@selector(outputLang))];
}

- (id)copyWithZone:(NSZone *)zone {
    TDTranslateItem *cpItem = [[TDTranslateItem allocWithZone:zone] init];
    cpItem.input = self.input;
    cpItem.inputLang = self.inputLang;
    cpItem.output = self.output;
    cpItem.outputLang = self.outputLang;
    return cpItem;
}

@end
