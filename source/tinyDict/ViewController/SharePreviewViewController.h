//
//  SharePreviewViewController.h
//  tinyDict
//
//  Created by guangbool on 2017/5/16.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharePreviewViewController : UIViewController

@property (nonatomic, readonly) UIImage *previewImage;
@property (nonatomic, copy) void(^closeHandler)(UIViewController *viewController);

/**
 初始化方法
 
 @param image 预览的图片
 */
- (instancetype)initWithPreviewImage:(UIImage *)image;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (void)animatedShowOperateItems;

@end
