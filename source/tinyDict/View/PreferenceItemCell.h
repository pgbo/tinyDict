//
//  PreferenceItemCell.h
//  tinyDict
//
//  Created by guangbool on 2017/4/27.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PreferenceItemCellType) {
    // checkmark type
    PreferenceTypeCheckmark = 0,
    // switch type
    PreferenceTypeSwitch,
    // movale type
    PreferenceTypeMovable
};

@class PreferenceItemCellModel;

@interface PreferenceItemCell : UITableViewCell

@property (nonatomic, readonly) PreferenceItemCellModel *model;

@property (nonatomic, assign) BOOL switchOn;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, copy) void(^switchValueChangedBlock)(PreferenceItemCell *cell, BOOL on);

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)configureWithModel:(PreferenceItemCellModel *)model;

@end

@interface PreferenceItemCellModel : NSObject

@property (nonatomic, assign) PreferenceItemCellType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;

@end
