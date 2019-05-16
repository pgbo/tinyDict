//
//  RecordsViewController.h
//  tinyDict
//
//  Created by guangbool on 2017/4/21.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 记录列表页面
 */
@interface RecordsViewController : UITableViewController

/**
 是否是历史记录页面，否则为收藏页面
 */
@property (nonatomic, readonly) BOOL isHistorys;

- (instancetype)initWithHistorysFlag:(BOOL)isHistorys;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end
