//
//  SharePreviewViewController.m
//  tinyDict
//
//  Created by guangbool on 2017/5/16.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "SharePreviewViewController.h"
#import <TDKit/Masonry.h>
#import <TDKit/UIImage+TDKit.h>
#import <TDKit/NSData+TDKit.h>
#import <TDkit/NSObject+TDKit.h>
#import <TDKit/UITraitCollection+Preference.h>
#import <TDKit/UIViewController+TDKit.h>
#import "ShareOptionsPanel.h"

static NSString *const WechatMyAppKey = @"wx2f9f0eb35938adfb";

@interface SharePreviewViewController ()

@property (nonatomic) UIImage *previewImage;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) ShareOptionsPanel *shareOptionPanel;

@property (nonatomic) NSUInteger didLayoutSubviewsNum;
@property (nonatomic) NSUInteger viewWillAppearNum;

@end

@implementation SharePreviewViewController

- (instancetype)initWithPreviewImage:(UIImage *)image {
    if (self = [super init]) {
        self.previewImage = image;
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        
    }
    return _imageView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor blackColor];
        [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOperateItemsHidden)]];
    }
    return _scrollView;
}

- (ShareOptionsPanel *)shareOptionPanel {
    if (!_shareOptionPanel) {
        _shareOptionPanel = [[ShareOptionsPanel alloc] init];
        _shareOptionPanel.preferredMaxLayoutWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 2*16.f;
        
        __weak typeof(self)weakSelf = self;
        _shareOptionPanel.wechatClickHandler = ^(ShareOptionsPanel *panel) {
            [weakSelf shareToWechat];
        };
        _shareOptionPanel.wx_momentClickHandler = ^(ShareOptionsPanel *panel) {
            [weakSelf shareToWXMoment];
        };
        _shareOptionPanel.importClickHandler = ^(ShareOptionsPanel *panel) {
            [weakSelf saveToPhotosAlbum];
        };
        _shareOptionPanel.moreClickHandler = ^(ShareOptionsPanel *panel) {
            [weakSelf shareWithActivityViewController];
        };
    }
    return _shareOptionPanel;
}

- (void)close:(id)sender {
    if (self.closeHandler) {
        self.closeHandler(self);
    }
}

- (void)shareToWechatForData:(NSData *)data {
    if (!data) return;
    
    [[UIPasteboard generalPasteboard] setData:data forPasteboardType:@"content"];
    // weixin://app/appkey/sendreq/?
    [self openURL:[NSURL URLWithString:[NSString stringWithFormat:@"weixin://app/%@/sendreq/?", WechatMyAppKey]]];
}

- (void)shareToWechat {
    if (!self.previewImage) return;
    
    [self.traitCollection tapticPeekIfPossible];
    
    NSData *imageData = UIImageJPEGRepresentation(self.previewImage, 1);
    NSData *shareData = [NSData wrapWXShareDataForImageData:imageData emoticon:NO scene:NO appkey:WechatMyAppKey];
    [self shareToWechatForData:shareData];
}

- (void)shareToWXMoment {
    if (!self.previewImage) return;
    
    [self.traitCollection tapticPeekIfPossible];
    
    NSData *imageData = UIImageJPEGRepresentation(self.previewImage, 1);
    NSData *shareData = [NSData wrapWXShareDataForImageData:imageData emoticon:NO scene:YES appkey:WechatMyAppKey];
    [self shareToWechatForData:shareData];
}

- (void)saveToPhotosAlbum {
    if (!self.previewImage) return;
    
    [self.traitCollection tapticPeekIfPossible];
    
    UIImage *savingImage = [self.previewImage copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImageWriteToSavedPhotosAlbum(savingImage, nil, nil, nil);
    });
}

- (void)shareWithActivityViewController {
    if (!self.previewImage) return;
    
    [self.traitCollection tapticPeekIfPossible];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[self.previewImage] applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)toggleOperateItemsHidden {
    
    // navigation bar
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    BOOL shareOptionPanelShowing = CGRectContainsRect(self.view.bounds, _shareOptionPanel.frame);
    [self animatedSetShareOptionPanelHidden:shareOptionPanelShowing];
}

- (void)animatedSetShareOptionPanelHidden:(BOOL)hidden {
    if (!_shareOptionPanel) return;
    
    __weak typeof(self)weakSelf = self;
    [self.view layoutIfNeeded];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.5 animations:^{
        [weakSelf.shareOptionPanel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.removeExisting = YES;
            make.centerX.mas_equalTo(0);
            if (hidden) {
                make.top.equalTo(weakSelf.view.mas_bottom).offset(10);
            } else {
                make.bottom.mas_equalTo(-30);
            }
        }];
        [weakSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (void)animatedShowOperateItems {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self animatedSetShareOptionPanelHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = NSLocalizedStringFromTable(@"Preview", @"TinyT", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close_ic"] style:UIBarButtonItemStylePlain target:self action:@selector(close:)];

    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.view addSubview:self.shareOptionPanel];
    __weak typeof(self)weakSelf = self;
    [self.shareOptionPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(weakSelf.view.mas_bottom).offset(10);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.viewWillAppearNum ++;
    BOOL hideNavigationBar = YES;
    if (self.viewWillAppearNum != 1) {
        NSNumber *navigationBarHidden = [self getAssociatedValueForKey:@"navigationBarHidden"];
        hideNavigationBar = [navigationBarHidden boolValue];
    }
    [self.navigationController setNavigationBarHidden:hideNavigationBar animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setAssociateValue:@(self.navigationController.navigationBarHidden) withKey:@"navigationBarHidden"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.didLayoutSubviewsNum ++;
    if (self.didLayoutSubviewsNum == 1 && self.previewImage && !self.imageView.superview) {
        
        CGFloat sourceImgWidth = self.previewImage.size.width;
        CGFloat sourceImgHeight = self.previewImage.size.height;
        
        CGFloat scrollViewWidth = CGRectGetWidth(self.scrollView.frame);
        CGFloat scrollViewHeight = CGRectGetHeight(self.scrollView.frame);
        
        CGFloat previewImgWidth = sourceImgWidth<scrollViewWidth?sourceImgWidth:scrollViewWidth;
        CGFloat previewImgHeight = sourceImgHeight * (previewImgWidth/sourceImgWidth);
        
        UIImage *realPreviewImg = [self.previewImage imageByResizeToSize:CGSizeMake(previewImgWidth, previewImgHeight)];
        
        self.imageView.image = realPreviewImg;
        [self.scrollView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            CGFloat leading = (scrollViewWidth - previewImgWidth)/2;
            CGFloat top = scrollViewHeight>previewImgHeight?((scrollViewHeight-previewImgHeight)/2):0;
            make.leading.mas_equalTo(leading);
            make.width.mas_equalTo(previewImgWidth);
            make.top.mas_equalTo(top);
            make.height.mas_equalTo(previewImgHeight);
        }];
        
        self.scrollView.contentSize = CGSizeMake(scrollViewWidth, MAX(previewImgHeight, scrollViewHeight));
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
