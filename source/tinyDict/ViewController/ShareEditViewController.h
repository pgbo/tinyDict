//
//  ShareEditViewController.h
//  tinyDict
//
//  Created by guangbool on 2017/4/17.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TDKit/TDConstants.h>

@interface ShareEditViewController : UIViewController

@property (nonatomic, copy, readonly) NSString *tid;
@property (nonatomic, assign, readonly) TDTextTranslateLanguage init_lang;


/**
 初始化方法

 @param tid Translate id, 如果为 nil, 则显示空的分享，并且隐藏和翻译相关的操作选项
 @param init_lang 初始显示翻译结果的语言
 */
- (instancetype)initWithTid:(NSString *)tid init_lang:(TDTextTranslateLanguage)init_lang;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end
