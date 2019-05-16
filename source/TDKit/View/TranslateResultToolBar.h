//
//  TranslateResultToolBar.h
//  tinyDict
//
//  Created by guangbool on 2017/4/28.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TranslateResultToolBar : UIView

@property (nonatomic, readonly) NSArray<NSString *> *outputLanguages;
@property (nonatomic, copy) void(^outputLanguageItemSelectionBlock)(TranslateResultToolBar *bar, NSInteger selectionIndex);
@property (nonatomic, assign) NSUInteger selectionOutputLanguageIndex;
@property (nonatomic, assign, setter=setItemStarred:) BOOL isItemStarred;
@property (nonatomic, copy) void(^starOperateItemClickBlock)(TranslateResultToolBar *bar);
@property (nonatomic, copy) void(^shareOperateItemClickBlock)(TranslateResultToolBar *bar);
@property (nonatomic, copy) void(^copyyOperateItemClickBlock)(TranslateResultToolBar *bar);
@property (nonatomic, copy) void(^trashOperateItemClickBlock)(TranslateResultToolBar *bar);

+ (instancetype)fromNibWithOutputLanguages:(NSArray<NSString *> *)outputLanguages;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (void)setItemStarred:(BOOL)starred;

@end
