//
//  ShareEditMultiLevelMenuCell.h
//  tinyDict
//
//  Created by guangbool on 2017/5/11.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareEditMultiLevelMenuCell : UITableViewCell

// 是否可展开
@property (nonatomic, readonly) BOOL extensible;

@property (nonatomic, strong) UIImage *menuIcon;
@property (nonatomic, copy) NSArray<NSString *> *secondaryMenuTitles;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, copy) NSString*(^menuTitleGetter)(__kindof UITableViewCell *cell, BOOL expanded);
@property (nonatomic, copy) void(^exitExpandHandler)(__kindof UITableViewCell *cell);
@property (nonatomic, copy) void(^secondaryMenuSelectionHandler)(__kindof UITableViewCell *cell, NSInteger index);

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier extensible:(BOOL)extensible;

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated;

+ (CGFloat)heightWithExpanded:(BOOL)expanded secondaryMenusNumber:(NSUInteger)secondaryMenusNumber;

@end
