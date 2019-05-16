//
//  TodayInputAccessoryView.h
//  tinyDict
//
//  Created by guangbool on 2017/4/10.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayInputAccessoryView : UIView

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) void(^cancelItemClickBlock)();
@property (nonatomic, copy) void(^inputingBlock)(NSString *text);
@property (nonatomic, copy) void(^finishInputBlock)(NSString *text);

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

- (void)clearText;

- (BOOL)becomeFirstResponder;

- (BOOL)resignFirstResponder;

@end
