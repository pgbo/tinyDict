//
//  TodayTransparentTransitioningDelegate.h
//  tinyDict
//
//  Created by guangbool on 2017/4/10.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayTransparentTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, readonly) NSTimeInterval presentationAnimationDuration;
@property (nonatomic, readonly) NSTimeInterval dismissalAnimationDuration;

- (instancetype)initWithPresentationAnimationDuration:(NSTimeInterval)presentationDuration
                           dismissalAnimationDuration:(NSTimeInterval)dismissalDuration;

@end


@interface TodayTransparentPresentationAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, readonly) NSTimeInterval presentationAnimationDuration;

- (instancetype)initWithPresentationAnimationDuration:(NSTimeInterval)presentationDuration;

@end

@interface TodayTransparentDismissalAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, readonly) NSTimeInterval dismissalAnimationDuration;

- (instancetype)initWithDismissalAnimationDuration:(NSTimeInterval)dismissalDuration;

@end
