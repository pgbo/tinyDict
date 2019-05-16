//
//  TodayViewController0012.m
//  tinyDict
//
//  Created by guangbool on 2017/4/5.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TodayViewController0012.h"

#import <NotificationCenter/NotificationCenter.h>
#import <TDKit/TDKit.h>
#import "TodayHistorysItemCell.h"
#import "TodayInputAccessoryView.h"
#import "TodayDetailViewController.h"
#import "TodayItemBriefViewController.h"
#import "TodayTransparentTransitioningDelegate.h"
#import "UIDevice+TDKit.h"
#import "TodayInputViewController.h"


static const CGFloat TodayViewControllerExpanded_height = 186.f;
static const CGFloat TodayViewController_topBarContainerHeight = 76.f;
static const CGFloat TodayViewController_barSeperatorHeight = 0.5f;
static const NSUInteger TodayViewControllerHistoryListDisplayNumber = 3;
static const CGFloat TodayViewController_historyItemCellHeight = 36.5f;


@interface TodayViewController0012 () <NCWidgetProviding, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarContainerHeight;
@property (weak, nonatomic) IBOutlet UIView *topBarContainer;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *pageUpButton;
@property (weak, nonatomic) IBOutlet UIButton *pageDownButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *listSegment;
@property (weak, nonatomic) IBOutlet UILabel *searchTipLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *barSeperatorHeight;
@property (weak, nonatomic) IBOutlet UIView *barSeperator;

@property (weak, nonatomic) IBOutlet UIView *bodyContainer;
@property (weak, nonatomic) IBOutlet UITableView *recordsTable;
@property (weak, nonatomic) IBOutlet UILabel *usageTipLabel;

@property (nonatomic) TodayInputViewController *inputVC;


@property (nonatomic) TodayDataController0012 *dataController;
@property (nonatomic) NSArray<TodayTranslateHistoryItem *> *historys;
@property (nonatomic) NSArray<TodayTranslateHistoryItem *> *starreds;
// 是否正在输入
@property (nonatomic) BOOL inputing;
// 正在进行翻译的文字
@property (nonatomic, copy) NSString *translatingInput;

@property (nonatomic) TodayTransparentTransitioningDelegate *transparentTransitioningDelegate;

// 关闭 item 简明查看页面的定时器
@property (nonatomic) NSTimer *dismissItemBriefTimer;

@property (nonatomic) NSUInteger widgetActiveDisplayModeDidChangeCallNum;

@end

@implementation TodayViewController0012

- (TodayDataController0012 *)dataController {
    if (!_dataController) {
        _dataController = [[TodayDataController0012 alloc] init];
    }
    return _dataController;
}

- (void)setRecordsTableHidden:(BOOL)hidden {
    self.recordsTable.hidden = hidden;
    self.usageTipLabel.hidden = !hidden;
}

- (void)displayHistoryListIfNeed {
    
    if ([self.listSegment selectedSegmentIndex] != 0)
        return;
    
    if (self.historys.count == 0) {
        self.historys = [self.dataController loadHistoryWithRequest2:^TodayTranslateHistoryRequest2 *{
            TodayTranslateHistoryRequest2 *info = [[TodayTranslateHistoryRequest2 alloc] init];
            info.referTranslateId = nil;
            info.num = TodayViewControllerHistoryListDisplayNumber;
            info.loadStarredState = YES;
            return info;
        }].list;
    }
    
    if (self.historys.count > 0) {
        [self setRecordsTableHidden:NO];
    } else {
        [self setRecordsTableHidden:YES];
    }
    
    [self.recordsTable reloadData];
}

- (void)displayStarredListIfNeed {
    
    if ([self.listSegment selectedSegmentIndex] != 1)
        return;
    
    // always refresh starred list when displays it.
    self.starreds = [self.dataController loadStarredListWithRequest2:^TodayTranslateStarListRequest2 *{
        TodayTranslateStarListRequest2 *info = [[TodayTranslateStarListRequest2 alloc] init];
        info.referTranslateId = nil;
        info.num = TodayViewControllerHistoryListDisplayNumber;
        return info;
    }].list;
    
    if (self.starreds.count > 0) {
        [self setRecordsTableHidden:NO];
    } else {
        [self setRecordsTableHidden:YES];
    }
    
    [self.recordsTable reloadData];
}

- (void)updateWidgetPreferredContentSizeIfNeed {
    
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    
    if (self.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeExpanded) {
        CGSize modeSize = [self.extensionContext widgetMaximumSizeForDisplayMode:NCWidgetDisplayModeExpanded];
        modeSize.height = TodayViewControllerExpanded_height;
        self.preferredContentSize = modeSize;
    } else {
        CGSize modeSize = [self.extensionContext widgetMaximumSizeForDisplayMode:NCWidgetDisplayModeCompact];
        self.preferredContentSize = modeSize;
    }
}

- (void)listSegmentValueChanged:(id)sender {
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    if ([self.listSegment selectedSegmentIndex] == 0) {
        [self displayHistoryListIfNeed];
    } else {
        [self displayStarredListIfNeed];
    }
}

- (NSArray<TodayTranslateHistoryItem *> *)loadRecordsAutomaticallyWithSpecificNumbers:(NSUInteger)specificNumbers referTranslateItem:(TodayTranslateHistoryItem *)referTranslateItem isStarredList:(BOOL)isStarredList {
    if (specificNumbers == 0) return nil;
    
    TodayTranslateListResponse<TodayTranslateHistoryItem *> *(^loadRecords)(NSString *referId, NSInteger num, BOOL isStars) = ^TodayTranslateListResponse<TodayTranslateHistoryItem *> *(NSString *referId, NSInteger num, BOOL isStars){
        if (isStars) {
            return [self.dataController loadStarredListWithRequest2:^TodayTranslateStarListRequest2 *{
                TodayTranslateStarListRequest2 *info = [[TodayTranslateStarListRequest2 alloc] init];
                info.referTranslateId = referId;
                info.num = num;
                return info;
            }];
        } else {
            return [self.dataController loadHistoryWithRequest2:^TodayTranslateHistoryRequest2 *{
                TodayTranslateHistoryRequest2 *info = [[TodayTranslateHistoryRequest2 alloc] init];
                info.referTranslateId = referId;
                info.num = num;
                info.loadStarredState = YES;
                return info;
            }];
        }
    };
    
    NSMutableArray<TodayTranslateHistoryItem *> *newList = [NSMutableArray<TodayTranslateHistoryItem *> array];
    
    NSString *referTid = referTranslateItem.translateId;
    TodayTranslateListResponse<TodayTranslateHistoryItem *> *forwardResp = nil;
    forwardResp = loadRecords(referTid, specificNumbers, isStarredList);
    if (forwardResp.referTranslateId && forwardResp.referItemIfExist) {
        [newList addObject:referTranslateItem];
    }
    if (forwardResp.list .count > 0) {
        [newList addObjectsFromArray:forwardResp.list];
    }
    
    if (newList.count < specificNumbers) {
        NSUInteger restGap = specificNumbers - newList.count;
        TodayTranslateListResponse<TodayTranslateHistoryItem *> *reverseResp = nil;
        reverseResp = loadRecords(referTid, -1 * restGap, isStarredList);
        if (reverseResp.list.count > 0) {
            NSIndexSet *indexSet = nil;
            indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, reverseResp.list.count)];
            [newList insertObjects:reverseResp.list
                         atIndexes:indexSet];
        }
    } else if (newList.count > specificNumbers) {
        [newList removeObjectsInRange:NSMakeRange(specificNumbers, newList.count - specificNumbers)];
    }
    
    return newList;
}

- (void)pageUp:(id)sender {
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    BOOL segHistorys = [self.listSegment selectedSegmentIndex] == 0;
    NSArray<TodayTranslateHistoryItem *> *holder = segHistorys?self.historys:self.starreds;
    NSString *referTranslateId = holder.firstObject.translateId;
    
    if (!referTranslateId) {
        [self shakesAtTop:YES bottom:NO];
        return;
    }
    
    NSUInteger pageSize = TodayViewControllerHistoryListDisplayNumber;
    NSArray<TodayTranslateHistoryItem *> *queryResults = nil;
    if (segHistorys) {
        queryResults = [self.dataController loadHistoryWithRequest2:^TodayTranslateHistoryRequest2 *{
            TodayTranslateHistoryRequest2 *info = [[TodayTranslateHistoryRequest2 alloc] init];
            info.referTranslateId = referTranslateId;
            info.num = pageSize*(-1);
            info.loadStarredState = YES;
            return info;
        }].list;
    } else {
        queryResults = [self.dataController loadStarredListWithRequest2:^TodayTranslateStarListRequest2 *{
            TodayTranslateStarListRequest2 *info = [[TodayTranslateStarListRequest2 alloc] init];
            info.referTranslateId = referTranslateId;
            info.num = pageSize*(-1);
            return info;
        }].list;
    }
    
    NSMutableArray *newResults = [NSMutableArray array];
    if (queryResults.count > 0) {
        [newResults addObjectsFromArray:queryResults];
    }
    if (holder.count > 0) {
        [newResults addObjectsFromArray:holder];
    }
    if (newResults.count > pageSize) {
        holder = [newResults subarrayWithRange:NSMakeRange(0, pageSize)];
    } else {
        holder = [newResults copy];
    }
    
    if (segHistorys) {
        self.historys = holder;
    } else {
        self.starreds = holder;
    }
    [self.recordsTable reloadData];
    
    // 如果返回的 num == 0，可以抖动以提示到头了
    if (queryResults.count == 0) {
        [self shakesAtTop:YES bottom:NO];
    }
}

- (void)pageDown:(id)sender {
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    NSUInteger pageSize = TodayViewControllerHistoryListDisplayNumber;
    BOOL segHistorys = [self.listSegment selectedSegmentIndex] == 0;
    NSArray<TodayTranslateHistoryItem *> *holder = segHistorys?self.historys:self.starreds;
    NSString *referTranslateId = ({
        TodayTranslateHistoryItem *referItem = nil;
        if (holder.count < pageSize) {
            referItem = holder.lastObject;
        } else {
            referItem = holder[pageSize - 1];
        }
        referItem.translateId;
    });
    
    NSArray<TodayTranslateHistoryItem *> *queryResults = nil;
    if (segHistorys) {
        queryResults = [self.dataController loadHistoryWithRequest2:^TodayTranslateHistoryRequest2 *{
            TodayTranslateHistoryRequest2 *info = [[TodayTranslateHistoryRequest2 alloc] init];
            info.referTranslateId = referTranslateId;
            info.num = pageSize;
            info.loadStarredState = YES;
            return info;
        }].list;
    } else {
        queryResults = [self.dataController loadStarredListWithRequest2:^TodayTranslateStarListRequest2 *{
            TodayTranslateStarListRequest2 *info = [[TodayTranslateStarListRequest2 alloc] init];
            info.referTranslateId = referTranslateId;
            info.num = pageSize;
            return info;
        }].list;
    }
    
    NSMutableArray *newResults = [NSMutableArray array];
    if (holder.count > 0) {
        [newResults addObjectsFromArray:holder];
    }
    if (queryResults.count > 0) {
        [newResults addObjectsFromArray:queryResults];
    }
    
    if (newResults.count > pageSize) {
        holder = [newResults subarrayWithRange:NSMakeRange(newResults.count - pageSize, pageSize)];
    } else {
        holder = [newResults copy];
    }
    
    if (segHistorys) {
        self.historys = holder;
    } else {
        self.starreds = holder;
    }
    [self.recordsTable reloadData];
    
    // 如果返回的 num == 0，可以抖动以提示没有更多了
    if (queryResults.count == 0) {
        [self shakesAtTop:NO bottom:YES];
    }
}

/**
 在某一个方向抖动
 
 @param top 是否在 top 抖动
 @param bottom 是否在 bottom 抖动
 */
- (void)shakesAtTop:(BOOL)top
             bottom:(BOOL)bottom {
    
    CGRect tableBounds = self.bodyContainer.bounds;
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.05
          initialSpringVelocity:20
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            CGRect animBounds = tableBounds;
                            if (top) {
                                animBounds.origin.y -= 2;
                            } else if (bottom) {
                                animBounds.origin.y += 2;
                            }
                            self.bodyContainer.bounds = animBounds;
                        } completion:^(BOOL finished) {
                            self.bodyContainer.bounds = tableBounds;
                        }];
}

- (void)startDismissItemBriefTimer {
    [self stopDismissItemBriefTimer];
    
    __weak typeof(self)weakSelf = self;
    self.dismissItemBriefTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf stopDismissItemBriefTimer];
        if ([weakSelf.presentedViewController isKindOfClass:[TodayItemBriefViewController class]]) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)stopDismissItemBriefTimer {
    [_dismissItemBriefTimer invalidate];
    _dismissItemBriefTimer = nil;
}

- (TodayTransparentTransitioningDelegate *)transparentTransitioningDelegate {
    if (!_transparentTransitioningDelegate) {
        _transparentTransitioningDelegate = [[TodayTransparentTransitioningDelegate alloc] initWithPresentationAnimationDuration:0.3 dismissalAnimationDuration:0.1];
    }
    return _transparentTransitioningDelegate;
}

- (void)showInputKeyboard {
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    if (_inputVC) {
        [_inputVC clearInputText];
    } else {
        _inputVC = [[TodayInputViewController alloc] init];
        _inputVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        __weak typeof(self)weakSelf = self;
        _inputVC.toExitPageBlock = ^(TodayInputViewController *pageCtrl) {
            // 触感振动
            [weakSelf.traitCollection tapticPeekIfPossible];
            
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            
            weakSelf.searchTipLabel.text = NSLocalizedStringFromTable(@"Enter text for translation...", @"todayextension", nil);
            weakSelf.inputing = NO;
            [weakSelf.recordsTable reloadData];
        };
        
        _inputVC.inputingBlock = ^(TodayInputViewController *pageCtrl, NSString *text) {
            if (text.length > 0 && !weakSelf.inputing) {
                weakSelf.searchTipLabel.text = NSLocalizedStringFromTable(@"Inputing...", @"todayextension", nil);
                weakSelf.inputing = YES;
                [weakSelf.recordsTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                             withRowAnimation:UITableViewRowAnimationFade];
                
            } else if (text.length == 0 && weakSelf.inputing){
                weakSelf.inputing = NO;
                [weakSelf.recordsTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                             withRowAnimation:UITableViewRowAnimationFade];
            }
        };
        
        _inputVC.finishInputBlock = ^(TodayInputViewController *pageCtrl, NSString *text) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            
            // do translate
            weakSelf.inputing = NO;
            NSString *input = [text stringByTrim];
            if (input.length == 0) {
                return;
            }
            
            weakSelf.searchTipLabel.text = input;
            [weakSelf translateForInput:input completeHandler:^(NSString *translateId){
                [weakSelf.inputVC clearInputText];
                weakSelf.searchTipLabel.text = NSLocalizedStringFromTable(@"Enter text for translation...", @"todayextension", nil);
            }];
        };
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:_inputVC animated:YES completion:^{
            [_inputVC textFieldBecomeFirstResponder];
        }];
    });
}

- (void)widgetActiveDisplayModeDidChangeWhenInitial {
    if (self.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeCompact) {
        self.usageTipLabel.text = NSLocalizedStringFromTable(@"usage guide when compact", @"todayextension", nil);
    } else {
        self.usageTipLabel.text = NSLocalizedStringFromTable(@"usage guide when expanded", @"todayextension", nil);
    }
}

- (void)widgetActiveDisplayModeDidChangeByManual {
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    if (self.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeCompact) {
        self.inputing = NO;
        self.translatingInput = nil;
        self.usageTipLabel.text = NSLocalizedStringFromTable(@"usage guide when compact", @"todayextension", nil);
    } else {
        self.usageTipLabel.text = NSLocalizedStringFromTable(@"usage guide when expanded", @"todayextension", nil);
    }
    
    // dismiss all presented view controllers
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // update widget content size
    [self updateWidgetPreferredContentSizeIfNeed];
    
    if (self.historys.count > 0 || self.inputing || self.translatingInput) {
        [self setRecordsTableHidden:NO];
    } else {
        [self setRecordsTableHidden:YES];
    }
    [self.recordsTable reloadData];
    
    if (self.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeCompact) {
        
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.4 animations:^{
            self.topBarContainer.alpha = 0;
            self.topBarContainerHeight.constant = 0;
            
            self.barSeperator.alpha = 0;
            self.barSeperatorHeight.constant = 0;
            
            [self.view layoutIfNeeded];
        }];
        
    } else {
        
        self.topBarContainer.alpha = 0;
        self.barSeperator.alpha = 0;
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.4 animations:^{
            self.topBarContainer.alpha = 1;
            self.topBarContainerHeight.constant = TodayViewController_topBarContainerHeight;
            
            self.barSeperator.alpha = 1;
            self.barSeperatorHeight.constant = TodayViewController_barSeperatorHeight;
            
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)showTranslateDetailWithTranslateId:(NSString *)translateId completeHandler:(void(^)())completeHandler {
    
    TodayDetailViewController *detailVC
        = [[TodayDetailViewController alloc] initWithWidgetDisplayMode:self.extensionContext.widgetActiveDisplayMode
                                                       itemTranslateId:translateId];
    detailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    __weak typeof(self)weakSelf = self;
    detailVC.cancelHandler = ^(TodayTranslateHistoryItem *newestInfo){
    
        {
            // 更新 historys
            TodayTranslateHistoryItem *referItem = weakSelf.historys.firstObject;
            if ([referItem.translateId isEqualToString:newestInfo.translateId]) {
                referItem = newestInfo;
            }
            weakSelf.historys =  [weakSelf loadRecordsAutomaticallyWithSpecificNumbers:TodayViewControllerHistoryListDisplayNumber referTranslateItem:referItem isStarredList:NO];
        }
        
        {
            // 更新 starreds
            TodayTranslateHistoryItem *referItem = weakSelf.starreds.firstObject;
            if ([referItem.translateId isEqualToString:newestInfo.translateId]) {
                referItem = newestInfo;
            }
            weakSelf.starreds = [weakSelf loadRecordsAutomaticallyWithSpecificNumbers:TodayViewControllerHistoryListDisplayNumber referTranslateItem:referItem
                                                                        isStarredList:YES];
        }
        
        [weakSelf.recordsTable reloadData];
        
        BOOL segHistorys = ([weakSelf.listSegment selectedSegmentIndex] == 0);
        BOOL hiddenTable = (segHistorys && weakSelf.historys.count == 0) || (!segHistorys && weakSelf.starreds.count == 0);
        [weakSelf setRecordsTableHidden:hiddenTable];
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    
    detailVC.shareHandler = ^(NSString *translateId, TDTextTranslateLanguage init_lang, BOOL starred){
        // route to container app
        if (translateId.length == 0) return;
        
        [weakSelf.extensionContext openURL:TDSharePageURLComposer(translateId, init_lang) completionHandler:nil];
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    
    detailVC.movedToTrashHandler = ^(NSString *translateId){

        // 更新 historys
        if (weakSelf.historys.count > 0
            && [weakSelf.historys.firstObject.translateId isEqualToString:translateId]) {
            weakSelf.historys = [weakSelf.historys subarrayWithRange:NSMakeRange(1, weakSelf.historys.count - 1)];
        }
        
        weakSelf.historys =  [weakSelf loadRecordsAutomaticallyWithSpecificNumbers:TodayViewControllerHistoryListDisplayNumber
                                                                referTranslateItem:weakSelf.historys.firstObject
                                                                     isStarredList:NO];
        
        // 更新 starreds
        if (weakSelf.starreds.count > 0
            && [weakSelf.starreds.firstObject.translateId isEqualToString:translateId]) {
            weakSelf.starreds = [weakSelf.starreds subarrayWithRange:NSMakeRange(1, weakSelf.starreds.count - 1)];
        }
        weakSelf.starreds = [weakSelf loadRecordsAutomaticallyWithSpecificNumbers:TodayViewControllerHistoryListDisplayNumber
                                                               referTranslateItem:weakSelf.starreds.firstObject
                                                                    isStarredList:YES];
        
        [weakSelf.recordsTable reloadData];
        
        BOOL segHistorys = ([weakSelf.listSegment selectedSegmentIndex] == 0);
        BOOL hiddenTable = (segHistorys && weakSelf.historys.count == 0) || (!segHistorys && weakSelf.starreds.count == 0);
        [weakSelf setRecordsTableHidden:hiddenTable];
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:detailVC animated:YES completion:completeHandler];
    });
}

- (void)translateForInput:(NSString *)input completeHandler:(void(^)(NSString *translateId))completeHandler {
    if (input.length == 0) return;
    
    [self setRecordsTableHidden:NO];
    self.translatingInput = input;
    [self.recordsTable reloadData];
    
    UIViewController *avoidInteractVC = [[UIViewController alloc] init];
    avoidInteractVC.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.001];
    avoidInteractVC.modalPresentationStyle = UIModalPresentationCustom;
    avoidInteractVC.transitioningDelegate = self.transparentTransitioningDelegate;
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf) return;
        [weakSelf presentViewController:avoidInteractVC animated:NO completion:^{
            [weakSelf.dataController translateForInput:input destLanguage:TDTextTranslateLanguage_unkown completeHandler:^(TodayTranslateResponse *resp, NSError *error) {
                if (!weakSelf) return;
                
                // dismiss avoidInteractVC
                [weakSelf dismissViewControllerAnimated:NO completion:^{
                    if (!weakSelf) return;
                    
                    // change to history list if need
                    if ([weakSelf.listSegment selectedSegmentIndex] != 0) {
                        [weakSelf.listSegment setSelectedSegmentIndex:0];
                    }
                    
                    // reload history list
                    weakSelf.translatingInput = nil;
                    weakSelf.historys = [weakSelf.dataController loadHistoryWithRequest2:^TodayTranslateHistoryRequest2 *{
                        TodayTranslateHistoryRequest2 *info = [[TodayTranslateHistoryRequest2 alloc] init];
                        info.referTranslateId = nil;
                        info.num = TodayViewControllerHistoryListDisplayNumber;
                        info.loadStarredState = YES;
                        return info;
                    }].list;
                    
                    [weakSelf.recordsTable reloadData];
                    
                    // show details
                    [weakSelf showTranslateDetailWithTranslateId:resp.translateId completeHandler:^{
                        if (completeHandler) completeHandler(resp.translateId);
                    }];
                }];
            }];
        }];
    });
}

- (BOOL)translateCopyTextAutomatically {
    BOOL val = NO;
    NSNumber *valNum = [TDPrefs shared].translateCopyTextAutomatically;
    if (valNum) {
        val = [valNum boolValue];
    } else {
        val = TDDefaultValue_translateCopyTextAutomatically;
    }
    return val;
}

- (NSString *)shouldTranslateForClipboardString {

    if (![self translateCopyTextAutomatically]) return nil;
    
    NSString *clipboardString = [[UIPasteboard generalPasteboard].string stringByTrim];
    if (clipboardString.length == 0) return nil;
    
    // 检查是否是上一次拷贝的结果
    TodayCopiedTranslateResponse *lastCopied = [self.dataController lastCopiedTranslate];
    NSString *lastCopiedTranslateOutput = [lastCopied.meta.copiedString stringByTrim];
    if (lastCopiedTranslateOutput && [clipboardString isEqualToString:lastCopiedTranslateOutput]) {
        return nil;
    }
    
    // 查询记录是否存在
    TDTranslateStoreItem *existHistoryItem
    = [self.dataController checkExistWithRequest:^TodayTranslateCheckExistRequest *{
        TodayTranslateCheckExistRequest *info = [[TodayTranslateCheckExistRequest alloc] init];
        info.input = clipboardString;
        info.checkExistInHistory = YES;
        return info;
    }].existItemInHistory;
    
    if (!existHistoryItem) {
        return clipboardString;
    }
    return nil;
}

- (void)updateViewsIfNeedWithCompleteHandler:(void(^)())completeHandler {
    
    NSString *needTranslateClipboardString = [self shouldTranslateForClipboardString];
    
    self.historys = [self.dataController loadHistoryWithRequest2:^TodayTranslateHistoryRequest2 *{
        TodayTranslateHistoryRequest2 *info = [[TodayTranslateHistoryRequest2 alloc] init];
        info.referTranslateId = nil;
        info.num = TodayViewControllerHistoryListDisplayNumber;
        info.loadStarredState = YES;
        return info;
    }].list;
    
    if (self.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeCompact) {
        self.topBarContainer.alpha = 0;
        self.topBarContainerHeight.constant = 0;
        
        self.barSeperator.alpha = 0;
        self.barSeperatorHeight.constant = 0;
    } else {
        self.topBarContainer.alpha = 1;
        self.topBarContainerHeight.constant = TodayViewController_topBarContainerHeight;
        
        self.barSeperator.alpha = 1;
        self.barSeperatorHeight.constant = TodayViewController_barSeperatorHeight;
    }
    
    if (self.historys.count > 0) {
        [self setRecordsTableHidden:NO];
    } else {
        [self setRecordsTableHidden:YES];
    }
    
    if (needTranslateClipboardString) {
        __weak typeof(self)weakSelf = self;
        [self translateForInput:needTranslateClipboardString completeHandler:^(NSString *translateId){
            if (!weakSelf) return;
            if (translateId) {
                // 记录该次拷贝信息，防止再次翻译
                [weakSelf.dataController setLastCopiedTranslate:({
                    TodayCopiedTranslateMeta *info = [[TodayCopiedTranslateMeta alloc] init];
                    info.translateId = translateId;
                    info.copiedString = needTranslateClipboardString;
                    info;
                })];
            }
            if (completeHandler) completeHandler();
        }];
    } else {
        [self.recordsTable reloadData];
        if (completeHandler) {
            completeHandler();
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.recordsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.recordsTable registerClass:[TodayHistorysItemCell class]
              forCellReuseIdentifier:NSStringFromClass([TodayHistorysItemCell class])];
    self.recordsTable.delegate = self;
    self.recordsTable.dataSource = self;
    
    [self.searchButton addTarget:self action:@selector(showInputKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    [self.listSegment setTitle:NSLocalizedStringFromTable(@"Records", @"todayextension", nil)
             forSegmentAtIndex:0];
    [self.listSegment setTitle:NSLocalizedStringFromTable(@"Stars", @"todayextension", nil)
             forSegmentAtIndex:1];
    [self.listSegment addTarget:self
                         action:@selector(listSegmentValueChanged:)
               forControlEvents:UIControlEventValueChanged];
    [self.pageUpButton addTarget:self action:@selector(pageUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.pageDownButton addTarget:self action:@selector(pageDown:) forControlEvents:UIControlEventTouchUpInside];
    
    self.searchTipLabel.text = NSLocalizedStringFromTable(@"Enter text for translation...", @"todayextension", nil);
    self.searchTipLabel.userInteractionEnabled = YES;
    [self.searchTipLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(showInputKeyboard)]];
    
}

#pragma mark - NCWidgetProviding

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    [self updateWidgetPreferredContentSizeIfNeed];
    [self updateViewsIfNeedWithCompleteHandler:^{
        completionHandler(NCUpdateResultNewData);
    }];
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    
    self.widgetActiveDisplayModeDidChangeCallNum ++;
    if (self.widgetActiveDisplayModeDidChangeCallNum == 1) {
        // 第一次自动调用该方法
        [self widgetActiveDisplayModeDidChangeWhenInitial];
    } else {
        // 手动改变 widget 模式
        [self widgetActiveDisplayModeDidChangeByManual];
    }
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    
    BOOL existInputingOrTranslatingCell = self.inputing || (self.translatingInput != nil);
    num += existInputingOrTranslatingCell?1:0;
    
    if ([self.listSegment selectedSegmentIndex] == 0) {
        num += self.historys.count;
    } else {
        num += self.starreds.count;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TodayHistorysItemCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TodayHistorysItemCell class]) forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(TodayHistorysItemCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL existInputingOrTranslatingCell = self.inputing || (self.translatingInput != nil);
    
    NSInteger row = indexPath.row;
    
    TodayHistoryItemViewModel *model = [[TodayHistoryItemViewModel alloc] init];
    model.cellType = TodayHistoryItemNormalCell;
    
    if (self.inputing && row == 0) {
        model.cellType = TodayHistoryItemInputingCell;
        model.isStarred = NO;
    } else if (self.translatingInput && row == 0) {
        model.cellType = TodayHistoryItemSearchingCell;
        model.input = self.translatingInput;
        model.isStarred = NO;
    } else {
        NSString *input = nil;
        BOOL isStarred = NO;
        NSInteger idx = row - (existInputingOrTranslatingCell?1:0);
        if ([self.listSegment selectedSegmentIndex] == 0 && self.historys.count > idx) {
            TodayTranslateHistoryItem *item = self.historys[idx];
            input = item.item.input;
            isStarred = item.starred;
        } else if (self.starreds.count > idx){
            TodayTranslateHistoryItem *item = self.starreds[idx];
            input = item.item.input;
            isStarred = YES;
        }
        model.input = input;
        model.isStarred = isStarred;
    }
    
    [cell configureWithViewModel:model];
    
    __weak typeof(self)weakSelf = self;
    cell.longPressedBlock = ^(TodayHistorysItemCell *optCell){
        if (optCell.viewModel.input.length > 0) {
            
            // 触感振动
            [self.traitCollection tapticPeekIfPossible];
            
            TodayItemBriefViewController *brief = [[TodayItemBriefViewController alloc] initWithInput:optCell.viewModel.input];
            brief.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [weakSelf presentViewController:brief animated:YES completion:^{
                [weakSelf startDismissItemBriefTimer];
            }];
        }
    };
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TodayViewController_historyItemCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;
    
    TodayTranslateHistoryItem *selectItem = nil;
    if ([self listSegment].selectedSegmentIndex == 0) {
        selectItem = self.historys[row];
    } else {
        selectItem = self.starreds[row];
    }
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    [self showTranslateDetailWithTranslateId:selectItem.translateId completeHandler:nil];
}

@end
