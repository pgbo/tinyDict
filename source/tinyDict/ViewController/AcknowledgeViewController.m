//
//  AcknowledgeViewController.m
//  tinyDict
//
//  Created by 彭光波 on 2017/5/30.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "AcknowledgeViewController.h"
#import <TDKit/OrderedDictionary.h>
#import <SafariServices/SafariServices.h>
#import "UITableViewCell+TDApp.h"

static MutableOrderedDictionary<NSString *, NSString *> *AcknowledgeItems;

@interface AcknowledgeViewController ()

@end

@implementation AcknowledgeViewController

+ (void)initialize {
    AcknowledgeItems = [[MutableOrderedDictionary alloc] init];
    AcknowledgeItems[@"Masonry"] = @"https://github.com/SnapKit/Masonry";
    AcknowledgeItems[@"MMWormhole"] = @"https://github.com/mutualmobile/MMWormhole";
    AcknowledgeItems[@"GDataXML-HTML"] = @"https://github.com/graetzer/GDataXML-HTML";
    AcknowledgeItems[@"Aspects"] = @"https://github.com/steipete/Aspects";
    AcknowledgeItems[@"BOOLoadMoreController"] = @"https://github.com/pgbo/BOOLoadMoreController";
    AcknowledgeItems[@"MGSwipeTableCell"] = @"https://github.com/MortimerGoro/MGSwipeTableCell";
    AcknowledgeItems[@"UIApplication-ViewControllerHandy"] = @"https://github.com/pgbo/UIApplication-ViewControllerHandy";
    AcknowledgeItems[@"UITextView+Placeholder"] = @"https://github.com/devxoul/UITextView-Placeholder";
    AcknowledgeItems[@"WDScrollableSegmentedControl"] = @"https://github.com/Wildog/WDScrollableSegmentedControl";
    AcknowledgeItems[@"YYKeyboardManager"] = @"https://github.com/ibireme/YYKeyboardManager";
}

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedStringFromTable(@"Acknowledge", @"TinyT", nil);
}

#pragma mark - Table view data source

- (UITableViewCell *)cellDequeued {
    NSString *identifier = NSStringFromSelector(@selector(cellDequeued));
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell textLabelConfigureDefault];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return AcknowledgeItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self cellDequeued];
    cell.textLabel.text = AcknowledgeItems.allKeys[indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedStringFromTable(@"VERY APPRECIATE FOR BELOW PROJECTS", @"TinyT", nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *url = AcknowledgeItems[indexPath.row];
    if (url.length > 0) {
        [self presentViewController:[[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]] animated:YES
                         completion:nil];
    }
}

@end
