//
//  NSData+TDKit.h
//  tinyDict
//
//  Created by guangbool on 2017/5/18.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSData (TDKit)


/**
 包装微信的图片分享数据

 @param imageData 图片 data
 @param emoticon 是否为分享为表情
 @param scene 是否分享为朋友圈
 @param appkey appkey
 @return 结果
 */
+ (NSData *)wrapWXShareDataForImageData:(NSData *)imageData
                               emoticon:(BOOL)emoticon
                                  scene:(NSInteger)scene
                                 appkey:(NSString *)appkey;

/**
 Returns a lowercase NSString for md5 hash.
 */
- (NSString *)md5String;

/**
 Returns an NSData for md5 hash.
 */
- (NSData *)md5Data;

@end
