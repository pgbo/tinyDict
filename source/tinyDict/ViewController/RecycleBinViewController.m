//
//  RecycleBinViewController.m
//  tinyDict
//
//  Created by guangbool on 2017/5/25.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "RecycleBinViewController.h"
#import "TranslateHistoryCell.h"
#import "RecordBriefViewController.h"
#import "TranslateDetailViewController.h"
#import <TDKit/TDKit.h>
#import <BOOLoadMoreController/BOOLoadMoreController.h>

static const NSUInteger RecycleBinViewControllerRecordsPageSize = 30;

@interface RecycleBinViewController () <UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate>

@property (nonatomic) UIView *bodyView;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIButton *clearAllButn;

@property (nonatomic) TodayDataController0012 *dataController;
@property (nonatomic) NSMutableArray<TodayTranslateHistoryItem *> *trashRecords;

@property (nonatomic) BOOLoadMoreController *loadMoreController;
@property (nonatomic) UIActivityIndicatorView *loadMoreActivityIndicator;

@end

@implementation RecycleBinViewController

- (UIView *)bodyView {
    if (!_bodyView) {
        _bodyView = [[UIView alloc]init];
        _bodyView.clipsToBounds = YES;
    }
    return _bodyView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = [TDHeight app_prefsCellHeight];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView registerClass:[TranslateHistoryCell class] forCellReuseIdentifier:NSStringFromClass([TranslateHistoryCell class])];
    }
    return _tableView;
}

- (UIButton *)clearAllButn {
    if (!_clearAllButn) {
        _clearAllButn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearAllButn setTitle:NSLocalizedStringFromTable(@"Clear all", @"TinyT", nil) forState:UIControlStateNormal];
        _clearAllButn.titleLabel.font = [TDFontSpecs largeBold];
        [_clearAllButn setTitleColor:[TDColorSpecs app_tint] forState:UIControlStateNormal];
        [_clearAllButn setLayerShadow:[UIColor blackColor] offset:CGSizeMake(0, 3) radius:3];
        _clearAllButn.backgroundColor = [TDColorSpecs app_cellColor];
        [_clearAllButn addTarget:self action:@selector(clearAll:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearAllButn;
}

- (void)clearAll:(id)sender {

    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"TinyT", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"YES, clear all", @"TinyT", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self.dataController clearAllFromTrash];
        [self.trashRecords removeAllObjects];
        
        [self.tableView reloadData];
    }]];
    
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (TodayDataController0012 *)dataController {
    if (!_dataController) {
        _dataController = [[TodayDataController0012 alloc] init];
    }
    return _dataController;
}

- (NSMutableArray<TodayTranslateHistoryItem *> *)trashRecords {
    if (!_trashRecords) {
        _trashRecords = [NSMutableArray<TodayTranslateHistoryItem *> array];
    }
    return _trashRecords;
}

- (NSArray<TodayTranslateHistoryItem *> *)loadTrashRecordsWithReferTranslateId:(NSString *)referTranslateId {
    NSArray<TodayTranslateHistoryItem *> *results = nil;
    results = [self.dataController loadTrashedListWithRequest2:^TodayTrashedListRequest2 *{
        TodayTrashedListRequest2 *info = [[TodayTrashedListRequest2 alloc] init];
        info.referTranslateId = referTranslateId;
        info.num = RecycleBinViewControllerRecordsPageSize;
        return info;
    }].list;
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
    
    NSString *referTranslateId = [self.trashRecords lastObject].translateId;
    NSArray<TodayTranslateHistoryItem *> *results = [self loadTrashRecordsWithReferTranslateId:referTranslateId];
    
    [_loadMoreController finishLoadingWithDelay:0];
    
    [self installLoadMoreOrNot:(results.count >= RecycleBinViewControllerRecordsPageSize)];
    
    NSUInteger originCount = self.trashRecords.count;
    __block NSMutableArray<NSIndexPath *> *addingIndexPaths = [NSMutableArray<NSIndexPath *> array];
    [results enumerateObjectsUsingBlock:^(TodayTranslateHistoryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [addingIndexPaths addObject:[NSIndexPath indexPathForRow:(originCount + idx) inSection:0]];
    }];
    
    [self.trashRecords addObjectsFromArray:results];
    [self.tableView insertRowsAtIndexPaths:addingIndexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (MGSwipeButton *)createDeleteSwipeButton {
    MGSwipeButton *deleteButn = [MGSwipeButton buttonWithTitle:NSLocalizedStringFromTable(@"Delete", @"TinyT", nil) icon:nil backgroundColor:[TDColorSpecs remindColor]];
    [deleteButn iconTintColor:[UIColor whiteColor]];
    deleteButn.titleLabel.font = [TDFontSpecs regular];
    return deleteButn;
}

- (MGSwipeButton *)createRestoreSwipeButton {
    MGSwipeButton *restoreButn = [MGSwipeButton buttonWithTitle:NSLocalizedStringFromTable(@"Restore", @"TinyT", nil) icon:nil backgroundColor:[TDColorSpecs app_tint]];
    [restoreButn iconTintColor:[UIColor whiteColor]];
    restoreButn.titleLabel.font = [TDFontSpecs regular];
    return restoreButn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.navigationItem.title = NSLocalizedStringFromTable(@"Recycle bin", @"TinyT", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.bodyView];
    [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.top.equalTo(self.view.mas_safeAreaLayoutGuide);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.top.equalTo(self.mas_topLayoutGuide);
            make.leading.and.trailing.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }
    }];
    [self.bodyView addSubview:self.tableView];
    [self.bodyView addSubview:self.clearAllButn];
    
    __weak typeof(self)weakSelf = self;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.and.trailing.mas_equalTo(0);
    }];
    [self.clearAllButn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([TDHeight app_bottomBarHeight]);
        make.leading.and.trailing.mas_equalTo(0);
        make.top.equalTo(weakSelf.tableView.mas_bottom);
        make.bottom.mas_equalTo(0);
    }];
    
    [self loadMoreRecords];
}

- (void)dealloc {
    [self installLoadMoreOrNot:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.trashRecords.count>0?1:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trashRecords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TranslateHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TranslateHistoryCell class])
                                                                 forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TodayTranslateHistoryItem *item = self.trashRecords[indexPath.row];
    cell.inputText = item.item.input;
    cell.starred = item.starred;
    
    cell.longPressedBlock = nil;
    
    //configure right buttons
    cell.rightButtons = @[[self createDeleteSwipeButton], [self createRestoreSwipeButton]];
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

// use default footer height, it turns out the best user experience solution

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedStringFromTable(@"SWIPE LEFT TO EDIT", @"TinyT", nil);
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
    
    TodayTranslateHistoryItem *item = self.trashRecords[optIndexPath.row];
    
    if (index == 0) {
        // Delete
        
        // 触感振动
        [self.traitCollection tapticPeekIfPossible];
        
        [self.dataController clearFromTrashWithTranslateId:item.translateId];
        [self.trashRecords removeObject:item];
        if (self.trashRecords.count == 0) {
            [self.tableView reloadData];
        } else {
            [self.tableView deleteRowsAtIndexPaths:@[optIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        return YES;
        
    } else if (index == 1) {
        // Restore
        
        // 触感振动
        [self.traitCollection tapticPeekIfPossible];
        
        [self.dataController restoreToHistoryFromTrashWithTranslateId:item.translateId];
        [self.trashRecords removeObject:item];
        if (self.trashRecords.count == 0) {
            [self.tableView reloadData];
        } else {
            [self.tableView deleteRowsAtIndexPaths:@[optIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        return YES;
    }
    
    return YES;
}

@end
