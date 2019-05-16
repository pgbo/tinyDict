//
//  AboutViewController.m
//  tinyDict
//
//  Created by guangbool on 2017/5/27.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "AboutViewController.h"
#import <TDKit/Masonry.h>
#import <TDKit/TDSpecs.h>
#import "AcknowledgeViewController.h"

@interface AboutViewController ()

@property (nonatomic, weak) IBOutlet UILabel *sloganLabel;
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;
@property (nonatomic, weak) IBOutlet UIButton *shareButn;
@property (nonatomic, weak) IBOutlet UIButton *thanksButn;

@end

@implementation AboutViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([AboutViewController class]) bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedStringFromTable(@"About tTranslator", @"TinyT", nil);
    self.sloganLabel.text = NSLocalizedStringFromTable(@"about_slogan", @"TinyT", nil);
    self.versionLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [self.shareButn setTitle:NSLocalizedStringFromTable(@"Share to friends", @"TinyT", nil) forState:UIControlStateNormal];
    [self.thanksButn setTitle:NSLocalizedStringFromTable(@"Acknowledge", @"TinyT", nil) forState:UIControlStateNormal];
}

- (IBAction)share:(id)sender {
    NSString *shareTitle = NSLocalizedStringFromTable(@"share_app_title", @"TinyT", nil);
    UIImage *shareImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share_app_logo" ofType:@"png"]];
    NSURL *appShareUrl = [NSURL URLWithString:@"https://itunes.apple.com/app/id1244644794"];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[shareImg, shareTitle, appShareUrl] applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)thanks:(id)sender {
    [self.navigationController pushViewController:[[AcknowledgeViewController alloc] init] animated:YES];
}

@end
