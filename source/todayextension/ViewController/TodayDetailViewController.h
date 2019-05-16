//
//  TodayDetailViewController.h
//  tinyDict
//
//  Created by guangbool on 2017/4/10.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NotificationCenter/NotificationCenter.h>
#import <TDKit/TDConstants.h>
@class TodayTranslateHistoryItem;

@interface TodayDetailViewController : UIViewController

@property (nonatomic, readonly) NCWidgetDisplayMode widgetDisplayMode;
@property (nonatomic, copy, readonly) NSString *itemTranslateId;

@property (nonatomic, copy) void(^cancelHandler)(TodayTranslateHistoryItem *newestTranslateInfo);
@property (nonatomic, copy) void(^shareHandler)(NSString *itemTranslateId, TDTextTranslateLanguage init_lang, BOOL isStarred);
@property (nonatomic, copy) void(^movedToTrashHandler)(NSString *itemTranslateId);

- (instancetype)initWithWidgetDisplayMode:(NCWidgetDisplayMode)widgetDisplayMode
                          itemTranslateId:(NSString *)translateId;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end
