//
//  TodayTransparentTransitioningDelegate.m
//  tinyDict
//
//  Created by guangbool on 2017/4/10.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TodayTransparentTransitioningDelegate.h"

@implementation TodayTransparentTransitioningDelegate

- (instancetype)initWithPresentationAnimationDuration:(NSTimeInterval)presentationDuration
                           dismissalAnimationDuration:(NSTimeInterval)dismissalDuration {
    if (self = [super init]) {
        _presentationAnimationDuration = presentationDuration;
        _dismissalAnimationDuration = dismissalDuration;
    }
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    TodayTransparentPresentationAnimationController *presentationAnimationController = [[TodayTransparentPresentationAnimationController alloc] initWithPresentationAnimationDuration:_presentationAnimationDuration];
    return presentationAnimationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    TodayTransparentDismissalAnimationController *dismissalAnimationController = [[TodayTransparentDismissalAnimationController alloc] initWithDismissalAnimationDuration:_dismissalAnimationDuration];
    return dismissalAnimationController;
}

@end


@implementation TodayTransparentPresentationAnimationController

- (instancetype)initWithPresentationAnimationDuration:(NSTimeInterval)presentationDuration {
    if (self = [super init]) {
        _presentationAnimationDuration = presentationDuration;
    }
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
    
    toViewController.view.frame = finalFrame;
    [[transitionContext containerView] addSubview:toViewController.view];
    
    toViewController.view.layer.opacity = 0.0f;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         toViewController.view.layer.opacity = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return _presentationAnimationDuration;
}

@end

@implementation TodayTransparentDismissalAnimationController

- (instancetype)initWithDismissalAnimationDuration:(NSTimeInterval)dismissalDuration {
    if (self = [super init]) {
        _dismissalAnimationDuration = dismissalDuration;
    }
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         fromViewController.view.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return _dismissalAnimationDuration;
}

@end
