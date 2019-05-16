//
//  TodayInputViewController.h
//  todayextension
//
//  Created by 彭光波 on 2018/5/6.
//  Copyright © 2018年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayInputViewController : UIViewController

@property (nonatomic, readonly) NSString *inputText;
@property (nonatomic, copy) void(^toExitPageBlock)(TodayInputViewController *pageCtrl);
@property (nonatomic, copy) void(^inputingBlock)(TodayInputViewController *pageCtrl, NSString *text);
@property (nonatomic, copy) void(^finishInputBlock)(TodayInputViewController *pageCtrl, NSString *text);

- (instancetype)init;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (void)clearInputText;

- (BOOL)textFieldBecomeFirstResponder;

- (BOOL)textFieldResignFirstResponder;

@end
