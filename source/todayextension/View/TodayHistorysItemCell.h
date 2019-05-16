//
//  TodayHistorysItemCell.h
//  tinyDict
//
//  Created by guangbool on 2017/4/6.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TodayHistoryItemViewModel;


/**
 today widget 历史条目 cell
 */
@interface TodayHistorysItemCell : UITableViewCell

@property (nonatomic, readonly) TodayHistoryItemViewModel *viewModel;
@property (nonatomic, copy) void(^longPressedBlock)(__kindof UITableViewCell *cell);

- (void)configureWithViewModel:(TodayHistoryItemViewModel *)viewModel;

@end


/**
 历史条目 cell 类型

 - TodayHistoryItemNormalCell: 一般类型，显示 input
 - TodayHistoryItemInputingCell: 正在输入
 - TodayHistoryItemSearchingCell: 正在搜索
 */
typedef NS_ENUM(NSUInteger, TodayHistoryItemCellType) {
    TodayHistoryItemNormalCell = 0,
    TodayHistoryItemInputingCell,
    TodayHistoryItemSearchingCell,
};

@interface TodayHistoryItemViewModel : NSObject

@property (nonatomic, assign) TodayHistoryItemCellType cellType;
@property (nonatomic, copy) NSString *input;
@property (nonatomic, assign) BOOL isStarred;

@end
