//
//  TDictItem+TDPrettyOutput.h
//  tinyDict
//
//  Created by guangbool on 2017/3/29.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <TDKit/TDKit.h>

@interface TDictItem (TDPrettyOutput)

- (NSString *)prettyOutput;

+ (NSString *)prettyOutputForItems:(NSArray<TDictItem *> *)items;

@end


