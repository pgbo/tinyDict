//
//  TDictItem.m
//  tinyDict
//
//  Created by guangbool on 2017/3/9.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TDictItem.h"

@implementation TDictItem

- (instancetype)initWithSsgText:(NSString *)sggText explains:(NSArray<NSString *> *)explains {
    if (self = [super init]) {
        self.sggText = sggText;
        self.explains = explains;
    }
    return self;
}

- (instancetype)initWithSsgText:(NSString *)sggText explain:(NSString *)explain {
    return [self initWithSsgText:sggText explains:explain?@[explain]:nil];
}

- (instancetype)init {
    return [self initWithSsgText:nil explains:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{sggText: %@, explains: %@}", self.sggText, self.explains];
}

@end
