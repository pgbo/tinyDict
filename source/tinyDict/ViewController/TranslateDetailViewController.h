//
//  TranslateDetailViewController.h
//  tinyDict
//
//  Created by guangbool on 2017/5/4.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TranslateDetailViewController : UIViewController

/**
 如果翻译 id 为空，则展示为翻译输入页面
 */
@property (nonatomic, copy, readonly) NSString *itemTranslateId;
@property (nonatomic, copy, readonly) NSString *initialInputText;
@property (nonatomic, copy) void(^starOrNotHandler)(NSString *optTranslateId, BOOL isStarred);
@property (nonatomic, copy) void(^movedToTrashHandler)(NSString *removedTranslateId);

- (instancetype)initWithItemTranslateId:(NSString *)translateId;
- (instancetype)initWithInitialInputText:(NSString *)initialInputText;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end
