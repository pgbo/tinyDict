//
//  EditLanguageViewController.h
//  tinyDict
//
//  Created by guangbool on 2017/5/31.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditLanguageViewController : UITableViewController

@property (nonatomic, copy) void(^cancelHandler)(UIViewController *viewController);
@property (nonatomic, copy) void(^doneHandler)(UIViewController *viewController, NSArray<NSNumber *> *languages);

- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end
