//
//  RecordsViewController.m
//  tinyDict
//
//  Created by guangbool on 2017/4/21.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "RecordsViewController.h"
#import "TranslateHistoryCell.h"
#import "RecordBriefViewController.h"
#import "TranslateDetailViewController.h"
#import <TDKit/TDKit.h>
#import <BOOLoadMoreController/BOOLoadMoreController.h>

static const NSUInteger RecordsViewControllerPageSize = 30;

@interface RecordsViewController () <MGSwipeTableCellDelegate>

@property (nonatomic) TodayDataController0012 *dataController;
@property (nonatomic) NSMutableArray<TodayTranslateHistoryItem *> *records;

@property (nonatomic) BOOLoadMoreController *loadMoreController;
@property (nonatomic) UIActivityIndicatorView *loadMoreActivityIndicator;

// 关闭 item 简明查看页面的定时器
@property (nonatomic) NSTimer *dismissItemBriefTimer;

@end

@implementation RecordsViewController

- (instancetype)initWithHistorysFlag:(BOOL)isHistorys {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _isHistorys = isHistorys;
    }
    return self;
}

- (TodayDataController0012 *)dataController {
    if (!_dataController) {
        _dataController = [[TodayDataController0012 alloc] init];
    }
    return _dataController;
}

- (NSMutableArray<TodayTranslateHistoryItem *> *)records {
    if (!_records) {
        _records = [NSMutableArray<TodayTranslateHistoryItem *> array];
    }
    return _records;
}

- (NSArray<TodayTranslateHistoryItem *> *)loadRecordsWithReferTranslateId:(NSString *)referTranslateId {
    NSArray<TodayTranslateHistoryItem *> *results = nil;
    if (self.isHistorys) {
        results = [self.dataController loadHistoryWithRequest2:^TodayTranslateHistoryRequest2 *{
            TodayTranslateHistoryRequest2 *info = [[TodayTranslateHistoryRequest2 alloc] init];
            info.referTranslateId = referTranslateId;
            info.num = RecordsViewControllerPageSize;
            info.loadStarredState = YES;
            return info;
        }].list;
    } else {
        results = [self.dataController loadStarredListWithRequest2:^TodayTranslateStarListRequest2 *{
            TodayTranslateStarListRequest2 *info = [[TodayTranslateStarListRequest2 alloc] init];
            info.referTranslateId = referTranslateId;
            info.num = RecordsViewControllerPageSize;
            return info;
        }].list;
    }
    return results;
}

- (void)installLoadMoreOrNot:(BOOL)installOrNot {
    
    if (installOrNot) {
        self.loadMoreController = [[BOOLoadMoreController alloc] initWithObservable:self.tableView];
        if (!self.loadMoreActivityIndicator) {
            self.loadMoreActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.loadMoreActivityIndicator.hidesWhenStopped = NO;
        }
        if (!self.loadMoreActivityIndicator.superview) {
            [self.tableView addSubview:self.loadMoreActivityIndicator];
        }
        
        CGFloat indicatorEdgeInset = 8;
        CGFloat indicatorHeight = [self.loadMoreActivityIndicator intrinsicContentSize].height;
        
        self.loadMoreController = [[BOOLoadMoreController alloc] initWithObservable:self.tableView];
        // auto load more, set loadThreshold = 0
        self.loadMoreController.loadThreshold = 0;
        
        self.loadMoreController.extraBottomInsetWhenLoading = indicatorEdgeInset*2 + indicatorHeight;
        __weak typeof(self)weakSelf = self;
        
        self.loadMoreController.stateDidChangedBlock = ^(BOOLoadMoreController *controller, BOOLoadMoreControlState old, BOOLoadMoreControlState currentState) {
            if (controller.state == BOOLoadMoreControlStateIdle) {
                [weakSelf.loadMoreActivityIndicator mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(controller.scrollViewVisiableAreaMaxY + indicatorEdgeInset);
                }];
            }
        };
        
        self.loadMoreController.loadMoreExecuteBlock = ^(BOOLoadMoreController *controller){
            [weakSelf loadMoreRecords];
        };
        
        self.loadMoreController.scrollContentSizeChangedBlock = ^(BOOLoadMoreController *controller){
            if (controller.state == BOOLoadMoreControlStateIdle) {
                [weakSelf.loadMoreActivityIndicator mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(controller.scrollViewVisiableAreaMaxY + indicatorEdgeInset);
                }];
            }
        };
        
        [self.loadMoreActivityIndicator mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(self.loadMoreController.scrollViewVisiableAreaMaxY + indicatorEdgeInset);
        }];
        
    } else {
        _loadMoreController = nil;
        [_loadMoreActivityIndicator removeFromSuperview];
        _loadMoreActivityIndicator = nil;
    }
}

- (void)loadMoreRecords {
    
    NSString *referTranslateId = [self.records lastObject].translateId;
    NSArray<TodayTranslateHistoryItem *> *results = [self loadRecordsWithReferTranslateId:referTranslateId];
    
    [_loadMoreController finishLoadingWithDelay:0];
    
    [self installLoadMoreOrNot:(results.count >= RecordsViewControllerPageSize)];
    
    NSUInteger originCount = self.records.count;
    __block NSMutableArray<NSIndexPath *> *addingIndexPaths = [NSMutableArray<NSIndexPath *> array];
    [results enumerateObjectsUsingBlock:^(TodayTranslateHistoryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [addingIndexPaths addObject:[NSIndexPath indexPathForRow:(originCount + idx) inSection:0]];
    }];
    
    [self.records addObjectsFromArray:results];
    [self.tableView insertRowsAtIndexPaths:addingIndexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)startDismissItemBriefTimer {
    [self stopDismissItemBriefTimer];
    
    __weak typeof(self)weakSelf = self;
    self.dismissItemBriefTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf stopDismissItemBriefTimer];
        if ([weakSelf.presentedViewController isKindOfClass:[RecordBriefViewController class]]) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)stopDismissItemBriefTimer {
    [_dismissItemBriefTimer invalidate];
    _dismissItemBriefTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedStringFromTable(self.isHistorys?@"Histories":@"Stars", @"TinyT", nil);
    
    [self.tableView registerClass:[TranslateHistoryCell class] forCellReuseIdentifier:NSStringFromClass([TranslateHistoryCell class])];
    
    [self loadMoreRecords];
}

- (void)dealloc {
    [self installLoadMoreOrNot:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.records.count>0?1:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TranslateHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TranslateHistoryCell class])
                                                                 forIndexPath:indexPath];
    
    TodayTranslateHistoryItem *item = self.records[indexPath.row];
    cell.inputText = item.item.input;
    cell.starred = item.starred;
    
    __weak typeof(self)weakSelf = self;
    cell.longPressedBlock = ^(TranslateHistoryCell *optCell){
        [weakSelf.traitCollection tapticPeekIfPossible];
        RecordBriefViewController *brief = [[RecordBriefViewController alloc] initWithInput:item.item.input];
        brief.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [weakSelf presentViewController:brief animated:YES completion:^{
            [weakSelf startDismissItemBriefTimer];
        }];
    };
    
    //configure right buttons
    NSArray<NSString *> *optItems = @[NSLocalizedStringFromTable(@"Delete", @"TinyT", nil),
                                      NSLocalizedStringFromTable(@"Copy", @"TinyT", nil),
                                      NSLocalizedStringFromTable(item.starred?@"Unstar":@"Star", @"TinyT", nil)];
    NSMutableArray<MGSwipeButton *> *rightButtons = [NSMutableArray<MGSwipeButton *> array];
    [optItems enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIColor *backColor = (idx==0)?[TDColorSpecs remindColor]:[TDColorSpecs app_tint];
        MGSwipeButton *button = [MGSwipeButton buttonWithTitle:obj
                                                          icon:nil
                                               backgroundColor:backColor];
        [button iconTintColor:[UIColor whiteColor]];
        button.titleLabel.font = [TDFontSpecs regular];
        [rightButtons addObject:button];
    }];
    cell.rightButtons = rightButtons;
    cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
    cell.delegate = self;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 设置分割线边距
    // reference: http://stackoverflow.com/questions/25770119/ios-8-uitableview-separator-inset-0-not-working
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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
//    return 20.f;
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedStringFromTable(@"SWIPE LEFT TO EDIT", @"TinyT", nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TodayTranslateHistoryItem *selectTranslate = self.records[indexPath.row];
    TranslateDetailViewController *detailVC
        = [[TranslateDetailViewController alloc] initWithItemTranslateId:selectTranslate.translateId];
    __weak typeof(self)weakSelf = self;
    
    detailVC.starOrNotHandler = ^(NSString *optTranslateId, BOOL isStarred){
        if ([optTranslateId isEqualToString:selectTranslate.translateId]) {
            selectTranslate.starred = isStarred;
            if (!weakSelf.isHistorys && !isStarred) {
                // remove from list if it is starred list
                [weakSelf.records removeObject:selectTranslate];
                if (weakSelf.records.count == 0) {
                    [weakSelf.tableView reloadData];
                } else {
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
            } else {
                ((TranslateHistoryCell *)[weakSelf.tableView cellForRowAtIndexPath:indexPath]).starred = isStarred;
            }
        }
    };
    
    detailVC.movedToTrashHandler = ^(NSString *removedTranslateId){
        if (!weakSelf) return;
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
        if ([removedTranslateId isEqualToString:selectTranslate.translateId]) {
            if ([weakSelf.records containsObject:selectTranslate]) {
                [weakSelf.records removeObject:selectTranslate];
                [weakSelf.tableView reloadData];
            }
        } else {
            NSArray<TodayTranslateHistoryItem *> *refreshResults = [weakSelf loadRecordsWithReferTranslateId:nil];
            [weakSelf.records removeAllObjects];
            [weakSelf.records addObjectsFromArray:refreshResults?:@[]];
            
            [weakSelf installLoadMoreOrNot:(refreshResults.count >= RecordsViewControllerPageSize)];
            [weakSelf.tableView reloadData];
        }
    };
    
    [_loadMoreController finishLoadingWithDelay:0];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - MGSwipeTableCellDelegate

-(BOOL)swipeTableCell:(TranslateHistoryCell*) cell canSwipe:(MGSwipeDirection) direction {
    return direction == MGSwipeDirectionRightToLeft;
}

-(BOOL)swipeTableCell:(TranslateHistoryCell*) cell
  tappedButtonAtIndex:(NSInteger)index
            direction:(MGSwipeDirection)direction
        fromExpansion:(BOOL) fromExpansion {
    
    NSIndexPath *optIndexPath = [self.tableView indexPathForCell:cell];
    if (!optIndexPath)
        return YES;
    
    TodayTranslateHistoryItem *item = self.records[optIndexPath.row];
    
    if (index == 0) {
        // Delete
        
        // 触感振动
        [self.traitCollection tapticPeekIfPossible];
        
        [self.dataController moveToTrashWithRequest:^TodayTranslateMoveToTrashRequest *{
            TodayTranslateMoveToTrashRequest *info = [[TodayTranslateMoveToTrashRequest alloc] init];
            info.translateId = item.translateId;
            info.deleteExistInHistory = self.isHistorys;
            info.deleteExistInStarred = !info.deleteExistInHistory;
            return info;
        }];
        [self.records removeObject:item];
        if (self.records.count == 0) {
            [self.tableView reloadData];
        } else {
            [self.tableView deleteRowsAtIndexPaths:@[optIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        return YES;
    }
    
    if (index == 1) {
        // Copy
        [[UIPasteboard generalPasteboard] setString:item.item.input];
       
        // 记录该次拷贝的翻译，防止反向翻译
        [self.dataController setLastCopiedTranslate:({
            TodayCopiedTranslateMeta *info = [[TodayCopiedTranslateMeta alloc] init];
            info.translateId = item.translateId;
            info.copiedString = item.item.input;
            info;
        })];
        
        // 顺序更新到第一
        [self.dataController updateOrderToFirst:item.translateId];
        
        // 触感振动
        [self.traitCollection tapticPeekIfPossible];
        
        MGSwipeButton *optButn = (MGSwipeButton *)cell.rightButtons[index];
        [optButn setTitle:NSLocalizedStringFromTable(@"copied", @"TDBundle", nil) forState:UIControlStateNormal];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!weakSelf) return;
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [optButn setTitle:NSLocalizedStringFromTable(@"Copy", @"TinyT", nil) forState:UIControlStateNormal];
            [cell hideSwipeAnimated:YES];
        });
        
        return NO;
        
    } else if (index == 2) {
        // Star/Unstar
        
        // 触感振动
        [self.traitCollection tapticPeekIfPossible];
        
        BOOL tarState = !item.starred;
        [self.dataController starOrNotWithRequest:^TodayTranslateStarRequest *{
            TodayTranslateStarRequest *info = [[TodayTranslateStarRequest alloc] init];
            info.translateId = item.translateId;
            info.isToStarOrNot = tarState;
            return info;
        }];
        item.starred = tarState;
        
        MGSwipeButton *optButn = (MGSwipeButton *)cell.rightButtons[index];
        [optButn setTitle:NSLocalizedStringFromTable(tarState?@"Unstar":@"Star", @"TinyT", nil) forState:UIControlStateNormal];
        
        [self.tableView reloadRowsAtIndexPaths:@[optIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        return YES;
    }
    
    return YES;
}

@end
