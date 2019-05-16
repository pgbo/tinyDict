//
//  MainViewController.m
//  tinyDict
//
//  Created by guangbool on 2017/4/17.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "MainViewController.h"
#import <TDKit/TDKit.h>
#import "RecordsViewController.h"
#import "TranslatePrefsViewController.h"
#import "TranslateDetailViewController.h"
#import "ShareEditViewController.h"
#import "RecycleBinViewController.h"
#import "AboutViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    
    }
    return self;
}

- (UIBarButtonItem *)quickTranslatorEntryItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_ic"]
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(startQuickTranslate)];
}

- (void)startQuickTranslate {
    TranslateDetailViewController *inputVC = [[TranslateDetailViewController alloc] init];
    __weak typeof(self)weakSelf = self;
    inputVC.movedToTrashHandler = ^(NSString *removedTranslateId){
        if (!weakSelf) return;
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:inputVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationItem.rightBarButtonItem = [self quickTranslatorEntryItem];
    self.navigationItem.title = @"TINY TRANSLATOR";
}

#pragma mark - Table view data source

- (NSString *)sectionTitleForSection:(NSUInteger)section {
    if (section == 0) return NSLocalizedStringFromTable(@"MAIN ENTRANCE", @"TinyT", nil);
    if (section == 1) return NSLocalizedStringFromTable(@"TRANSLATE LIST", @"TinyT", nil);
    if (section == 2) return NSLocalizedStringFromTable(@"OTHER", @"TinyT", nil);
    return nil;
}

- (NSString *)rowTitleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSString *titleKey = nil;
    if (section == 0) {
        if (row == 0) {
            titleKey = @"Translate quickly";
        } else if (row == 1) {
            titleKey = @"Share quickly";
        } else if (row == 2) {
            titleKey = @"Preferences";
        }
    } else if (section == 1) {
        if (row == 0) {
            titleKey = @"Histories";
        } else if (row == 1) {
            titleKey = @"Stars";
        } else if (row == 2) {
            titleKey = @"Recycle bin";
        }
    } else if (section == 2) {
        if (row == 0) {
            titleKey = @"Support tTranslator";
        } else if (row == 1) {
            titleKey = @"About tTranslator";
        } else if (row == 2) {
            titleKey = @"Contact us";
        }
    }
    
    if (titleKey) {
        return NSLocalizedStringFromTable(titleKey, @"TinyT", nil);
    }
    return nil;
}

- (UIImage *)rowImageForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UIImage *image = nil;
    if (section == 0) {
        if (row == 0) {
            image = [UIImage imageNamed:@"search_ic"];
        } else if (row == 1) {
            image = [UIImage imageNamed:@"share_item_ic"];
        } else if (row == 2) {
            image = [UIImage imageNamed:@"preferences_item_ic"];
        }
    } else if (section == 1) {
        if (row == 0) {
            image = [UIImage imageNamed:@"history_item_ic"];
        } else if (row == 1) {
            image = [UIImage imageNamed:@"starred_item_ic"];
        } else if (row == 2) {
            image = [UIImage imageNamed:@"trash_item_ic"];
        }
    } else if (section == 2){
        if (row == 0) {
            image = [UIImage imageNamed:@"support_item_ic"];
        } else if (row == 1) {
            image = [UIImage imageNamed:@"about_item_ic"];
        } else if (row == 2) {
            image = [UIImage imageNamed:@"contact_item_ic"];
        }
    }
    
    return image;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 3;
    if (section == 1) return 3;
    if (section == 2) return 3;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [TDFontSpecs large];
        cell.textLabel.textColor = [TDColorSpecs wd_mainTextColor];
        cell.detailTextLabel.font = [TDFontSpecs regular];
        cell.detailTextLabel.textColor = [TDColorSpecs wd_minorTextColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [TDColorSpecs app_cellColor];
    }
    
    cell.textLabel.text = [self rowTitleForRowAtIndexPath:indexPath];
    cell.imageView.image = [self rowImageForRowAtIndexPath:indexPath];
    
    if ([indexPath section] == 2
        && [indexPath row] == 2) {
        cell.detailTextLabel.text = TDContactUSEmail;
    } else {
        cell.detailTextLabel.text = nil;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self sectionTitleForSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return NSLocalizedStringFromTable(@"Long press to copy info in the line", @"TinyT", nil);
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TDHeight app_prefsCellHeight];
}

// use default footer height, it turns out the best user experience solution
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 50.f;
//}

// use default footer height, it turns out the best user experience solution
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    if (section == 1) return 20.f;
//    return 0.1f;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0) {
        if (row == 0) {
            [self startQuickTranslate];
        } else if (row == 1) {
            [self.navigationController pushViewController:[[ShareEditViewController alloc] init] animated:YES];
        } else if (row == 2) {
            [self.navigationController pushViewController:[[TranslatePrefsViewController alloc] init] animated:YES];
        }
        
    } else if (section == 1) {
        if (row == 0) {
            [self.navigationController pushViewController:[[RecordsViewController alloc] initWithHistorysFlag:YES] animated:YES];
        } else if (row == 1) {
            [self.navigationController pushViewController:[[RecordsViewController alloc] initWithHistorysFlag:NO] animated:YES];
        } else if (row == 2){
            [self.navigationController pushViewController:[[RecycleBinViewController alloc] init] animated:YES];
        }
    } else if (section == 2) {
        if (row == 0) {
            // Support
            // App 评分页
            NSURL *url1 = [NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8&id=1244644794"];
            // app 首页
            NSURL *url2 = [NSURL URLWithString:@"https://itunes.apple.com/app/id1244644794"];
            if ([[UIApplication sharedApplication] canOpenURL:url1]) {
                [self openURL:url1];
            } else {
                [self openURL:url2];
            }
        } else if (row == 1) {
            // About
            [self.navigationController pushViewController:[[AboutViewController alloc] init] animated:YES];
        } else if (row == 2) {
            // Contact us
            [self openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", TDContactUSEmail]]];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 2 && [indexPath row] == 2) {
        return YES;
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if ([indexPath section] == 2
        && [indexPath row] == 2
        && [NSStringFromSelector(action) isEqualToString:@"copy:"]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if ([indexPath section] == 2
        && [indexPath row] == 2
        && [NSStringFromSelector(action) isEqualToString:@"copy:"]) {
        [[UIPasteboard generalPasteboard] setString:TDContactUSEmail];
    }
}

@end
