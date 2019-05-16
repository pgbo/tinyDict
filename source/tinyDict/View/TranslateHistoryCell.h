//
//  TranslateHistoryCell.h
//  tinyDict
//
//  Created by guangbool on 2017/4/21.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>

@interface TranslateHistoryCell : MGSwipeTableCell

@property (nonatomic, copy) void(^longPressedBlock)(__kindof UITableViewCell *cell);
@property (nonatomic, copy) NSString *inputText;
@property (nonatomic, assign) BOOL starred;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end
