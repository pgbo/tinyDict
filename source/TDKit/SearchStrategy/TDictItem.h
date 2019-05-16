//
//  TDictItem.h
//  tinyDict
//
//  Created by guangbool on 2017/3/9.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDictItem : NSObject

// suggest text
@property (nonatomic, copy) NSString *sggText;

// explain list
@property (nonatomic, copy) NSArray<NSString *> *explains;

- (instancetype)initWithSsgText:(NSString *)sggText explains:(NSArray<NSString *> *)explains;
- (instancetype)initWithSsgText:(NSString *)sggText explain:(NSString *)explain;

@end
