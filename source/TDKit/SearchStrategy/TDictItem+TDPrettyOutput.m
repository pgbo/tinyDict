//
//  TDictItem+TDPrettyOutput.m
//  tinyDict
//
//  Created by guangbool on 2017/3/29.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TDictItem+TDPrettyOutput.h"

@implementation TDictItem (TDPrettyOutput)

- (NSString *)prettyOutput {
    
    NSMutableString *output = [NSMutableString string];
    
    if (self.sggText.length > 0) {
        [output appendString:self.sggText];
    }
    
    for (NSString *explain in self.explains) {
        if (output.length > 0) {
            [output appendString:@"\n"];
        }
        [output appendString:explain];
    }
    
    return output;
}

+ (NSString *)prettyOutputForItems:(NSArray<TDictItem *> *)items {
    NSMutableString *output = [NSMutableString string];
    for (TDictItem *item in items) {
        NSString *itemOutput = [item prettyOutput];
        if (itemOutput.length == 0) {
            continue;
        }
        if (output.length > 0) {
            [output appendString:@"\n\n"];
        }
        [output appendString:itemOutput];
    }
    return output;
}

@end
