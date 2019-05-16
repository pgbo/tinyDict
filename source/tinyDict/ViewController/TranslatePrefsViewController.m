//
//  TranslatePrefsViewController.m
//  tinyDict
//
//  Created by guangbool on 2017/4/27.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TranslatePrefsViewController.h"
#import <TDKit/TDKit.h>
#import "PreferenceItemCell.h"
#import "TodayDataController0012.h"
#import "SimpleSectionHeaderFooter.h"
#import "DefaultNavigationController.h"
#import "EditLanguageViewController.h"

static NSString *const TranslatePrefsTableSectionHeader = @"TranslatePrefsTableSectionHeader";
static NSString *const TranslatePrefsTableCommonSectionFooter = @"TranslatePrefsTableCommonSectionFooter";
static NSString *const TranslatePrefsTableLastSectionFooter = @"TranslatePrefsTableLastSectionFooter";

@interface TranslatePrefsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UIView *bodyView;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIButton *prefsRestoreButn;

@end

@implementation TranslatePrefsViewController

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
        [_tableView registerClass:[SimpleSectionHeaderFooter class] forHeaderFooterViewReuseIdentifier:TranslatePrefsTableSectionHeader];
        [_tableView registerClass:[SimpleSectionHeaderFooter class] forHeaderFooterViewReuseIdentifier:TranslatePrefsTableCommonSectionFooter];
        [_tableView registerClass:[SimpleSectionHeaderFooter class] forHeaderFooterViewReuseIdentifier:TranslatePrefsTableLastSectionFooter];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = [TDHeight app_prefsCellHeight];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        _tableView.estimatedSectionHeaderHeight = 50;
        _tableView.sectionFooterHeight = UITableViewAutomaticDimension;
        _tableView.estimatedSectionFooterHeight = 50;
    }
    return _tableView;
}

- (UIButton *)prefsRestoreButn {
    if (!_prefsRestoreButn) {
        _prefsRestoreButn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_prefsRestoreButn setTitle:NSLocalizedStringFromTable(@"Restore preferences", @"TinyT", nil) forState:UIControlStateNormal];
        _prefsRestoreButn.titleLabel.font = [TDFontSpecs largeBold];
        [_prefsRestoreButn setTitleColor:[TDColorSpecs app_tint] forState:UIControlStateNormal];
        [_prefsRestoreButn setLayerShadow:[UIColor blackColor] offset:CGSizeMake(0, 3) radius:3];
        _prefsRestoreButn.backgroundColor = [TDColorSpecs app_cellColor];
        [_prefsRestoreButn addTarget:self action:@selector(restorePrefs:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _prefsRestoreButn;
}

- (void)restorePrefs:(id)sender {
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"TinyT", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"YES, Restore", @"TinyT", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [TDPrefs shared].detectInputLanguageAndTranslateOutputOther = @(TDDefaultValue_detectInputLanguageAndTranslateOutputOther);
        
        [TDPrefs shared].preferredTranslateOutputLanguageList = TDDefaultValue_preferredTranslateOutputLanguageList();
        
        NSInteger defaultLimit = TDDefaultValue_recordsLimit;
        [TDPrefs shared].recordsLimit = @(defaultLimit);
        
        // clear all but reserve the limit
        if (defaultLimit != TDNumberValue_UNLIMITED) {
            [[TodayDataController0012 new] clearAllButReserve:defaultLimit];
        }
        
        [TDPrefs shared].tapticPeekOpened = @(TDDefaultValue_tapticPeekOpened);
        
        [self.tableView reloadData];
    }]];
    
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (PreferenceItemCell *)switchTypeCellDequeued {
    NSString *identifier = NSStringFromSelector(@selector(switchTypeCellDequeued));
    PreferenceItemCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PreferenceItemCell alloc] initWithReuseIdentifier:identifier];
    }
    return cell;
}

- (PreferenceItemCell *)checkmarkTypeCellDequeued {
    NSString *identifier = NSStringFromSelector(@selector(checkmarkTypeCellDequeued));
    PreferenceItemCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PreferenceItemCell alloc] initWithReuseIdentifier:identifier];
    }
    return cell;
}

- (PreferenceItemCell *)movableTypeCellDequeued {
    NSString *identifier = NSStringFromSelector(@selector(movableTypeCellDequeued));
    PreferenceItemCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PreferenceItemCell alloc] initWithReuseIdentifier:identifier];
    }
    return cell;
}

- (UITableViewCell *)addLanguageCellDequeued {
    NSString *identifier = NSStringFromSelector(@selector(addLanguageCellDequeued));
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [TDFontSpecs large];
        cell.textLabel.textColor = [TDColorSpecs app_tint];
        cell.textLabel.text = NSLocalizedStringFromTable(@"Add language...", @"TinyT", nil);
    }
    return cell;
}

- (void)showLanguageEditPage {
    EditLanguageViewController *editVC = [[EditLanguageViewController alloc] init];
    editVC.cancelHandler = ^(UIViewController *viewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    editVC.doneHandler = ^(UIViewController *viewController, NSArray<NSNumber *> *languages) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                      withRowAnimation:UITableViewRowAnimationNone];
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    DefaultNavigationController *nav = [[DefaultNavigationController alloc] initWithRootViewController:editVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.navigationItem.title = NSLocalizedStringFromTable(@"Preferences", @"TinyT", nil);
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
    [self.bodyView addSubview:self.prefsRestoreButn];
    
    __weak typeof(self)weakSelf = self;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.and.trailing.mas_equalTo(0);
    }];
    [self.prefsRestoreButn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([TDHeight app_bottomBarHeight]);
        make.leading.and.trailing.mas_equalTo(0);
        make.top.equalTo(weakSelf.tableView.mas_bottom);
        make.bottom.mas_equalTo(0);
    }];
    
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.editing = YES;
}

#pragma mark - UITableViewDataSource

- (NSString *)sectionHeaderTitleForSection:(NSUInteger)section {
    if (section == 0) return NSLocalizedStringFromTable(@"MISC", @"TinyT", nil);
    if (section == 1) return NSLocalizedStringFromTable(@"TRANSLATE LANGUAGES ORDER", @"TinyT", nil);
    if (section == 2) return NSLocalizedStringFromTable(@"RECORDS LIMIT", @"TinyT", nil);
    if (section == 3) return NSLocalizedStringFromTable(@"OTHER", @"TinyT", nil);
    return nil;
}

- (NSString *)sectionFooterTitleForSection:(NSUInteger)section {
    if (section == 1) return NSLocalizedStringFromTable(@"Use the first language to translate when can't Auto-Detect", @"TinyT", nil);
    if (section == 2) return NSLocalizedStringFromTable(@"The limitations of history, starred and recycle bin all are setted", @"TinyT", nil);
    return nil;
}

- (NSInteger)recordsLimitValueForRelativeRowAtIndex:(NSUInteger)rowIndex {
    NSInteger rowLimitVal = 0;
    if (rowIndex == 0) {
        rowLimitVal = 50;
    } else if (rowIndex == 1) {
        rowLimitVal = 100;
    } else if (rowIndex == 2) {
        rowLimitVal = 200;
    } else {
        rowLimitVal = TDNumberValue_UNLIMITED;
    }
    return rowLimitVal;
}

- (NSArray<NSNumber *> *)preferredTranslateOutputLanguageList {
    NSArray<NSNumber *> *preferredLangs = [TDPrefs shared].preferredTranslateOutputLanguageList?:TDDefaultValue_preferredTranslateOutputLanguageList();
    NSAssert(preferredLangs.count > 0, @"preferredLangs.count must > 0");
    return preferredLangs;
}

- (NSInteger)preferredRecordsLimit {
    NSInteger val;
    NSNumber *prefer = [TDPrefs shared].recordsLimit;
    if (prefer) {
        val = [prefer integerValue];
    } else {
        val = TDDefaultValue_recordsLimit;
    }
    return val;
}

- (NSString *)rowTitleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSString *title = nil;
    
    if (section == 0) {
        
        if (row == 0) {
            title = NSLocalizedStringFromTable(@"Auto-Translate copied text", @"TinyT", nil);
        } else if (row == 1) {
            title = NSLocalizedStringFromTable(@"Auto-Detect translate language", @"TinyT", nil);
        }
        
    } else if (section == 1){
        NSArray<NSNumber *> *preferredLangs = [self preferredTranslateOutputLanguageList];
        if (row < preferredLangs.count) {
            TDTextTranslateLanguage rowLang = [preferredLangs[row] integerValue];
            NSString *nameKey = TDLanguageFullLocalizedKeyForType(rowLang);
            title = NSLocalizedStringFromTable(nameKey, @"TinyT", nil);
        }
    } else if (section == 2) {
        
        NSInteger rowLimitVal = [self recordsLimitValueForRelativeRowAtIndex:row];
        
        if (rowLimitVal != TDNumberValue_UNLIMITED) {
            title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ lines", @"TinyT", nil), @(rowLimitVal)];
        } else {
            title = NSLocalizedStringFromTable(@"Unlimited", @"TinyT", nil);
        }
    } else if (section == 3) {
        if (row == 0) {
            title = NSLocalizedStringFromTable(@"Impact feedback", @"TinyT", nil);
        }
    }
    
    return title;
}

- (BOOL)translateCopyTextAutomatically {
    BOOL val = NO;
    NSNumber *preferred = [TDPrefs shared].translateCopyTextAutomatically;
    if (preferred) {
        val = [preferred boolValue];
    } else {
        val = TDDefaultValue_translateCopyTextAutomatically;
    }
    return val;
}

- (BOOL)detectInputLanguageAndTranslateOutputOther {
    BOOL val = NO;
    NSNumber *preferred = [TDPrefs shared].detectInputLanguageAndTranslateOutputOther;
    if (preferred) {
        val = [preferred boolValue];
    } else {
        val = TDDefaultValue_detectInputLanguageAndTranslateOutputOther;
    }
    return val;
}

- (BOOL)tapticPeekOpened {
    BOOL val = NO;
    NSNumber *preferred = [TDPrefs shared].tapticPeekOpened;
    if (preferred) {
        val = [preferred boolValue];
    } else {
        val = TDDefaultValue_tapticPeekOpened;
    }
    return val;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 2;
    if (section == 1) return ([self preferredTranslateOutputLanguageList].count + 1);
    if (section == 2) return 4;
    if (section == 3) return 1;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            
            PreferenceItemCell *cell = [self switchTypeCellDequeued];
            cell.switchValueChangedBlock = ^(PreferenceItemCell *cell, BOOL on){
                [TDPrefs shared].translateCopyTextAutomatically = @(on);
            };
            
            [cell configureWithModel:({
                PreferenceItemCellModel *model = [PreferenceItemCellModel new];
                model.type = PreferenceTypeSwitch;
                model.title = [self rowTitleForRowAtIndexPath:indexPath];
                model.subTitle = NSLocalizedStringFromTable(@"Translate copied text automatically when display widget", @"TinyT", nil);
                model;
            })];
            
            cell.switchOn = [self translateCopyTextAutomatically];
            
            return cell;
            
        } else if (row == 1) {
            
            PreferenceItemCell *cell = [self switchTypeCellDequeued];
            cell.switchValueChangedBlock = ^(PreferenceItemCell *cell, BOOL on){
                [TDPrefs shared].detectInputLanguageAndTranslateOutputOther = @(on);
            };
            
            [cell configureWithModel:({
                PreferenceItemCellModel *model = [PreferenceItemCellModel new];
                model.type = PreferenceTypeSwitch;
                model.title = [self rowTitleForRowAtIndexPath:indexPath];
                model;
            })];
            
            cell.switchOn = [self detectInputLanguageAndTranslateOutputOther];
            
            return cell;
        }
    }
    
    if (section == 1) {
        if (row == [self preferredTranslateOutputLanguageList].count) {
            return [self addLanguageCellDequeued];
        } else {
            PreferenceItemCell *cell = [self movableTypeCellDequeued];
            [cell configureWithModel:({
                PreferenceItemCellModel *model = [PreferenceItemCellModel new];
                model.type = PreferenceTypeMovable;
                model.title = [self rowTitleForRowAtIndexPath:indexPath];
                model;
            })];
            return cell;
        }
    }
    
    if (section == 2) {
        PreferenceItemCell *cell = [self checkmarkTypeCellDequeued];
        [cell configureWithModel:({
            PreferenceItemCellModel *model = [PreferenceItemCellModel new];
            model.type = PreferenceTypeCheckmark;
            model.title = [self rowTitleForRowAtIndexPath:indexPath];
            model;
        })];
        
        NSInteger rowLimit = [self recordsLimitValueForRelativeRowAtIndex:indexPath.row];
        cell.checked = (rowLimit == [self preferredRecordsLimit]);
        
        return cell;
    }
    
    if (section == 3 && row == 0) {
        PreferenceItemCell *cell = [self switchTypeCellDequeued];
        cell.switchValueChangedBlock = ^(PreferenceItemCell *cell, BOOL on){
            if (on) {
                // 触感振动
                [self.traitCollection tapticPeekVibrate];
            }
            [TDPrefs shared].tapticPeekOpened = @(on);
        };
        
        [cell configureWithModel:({
            PreferenceItemCellModel *model = [PreferenceItemCellModel new];
            model.type = PreferenceTypeSwitch;
            model.title = [self rowTitleForRowAtIndexPath:indexPath];
            model;
        })];
        
        cell.switchOn = [self tapticPeekOpened];
        
        return cell;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self sectionHeaderTitleForSection:section];
    
    CGFloat insetTop = 30;
    if (section > 0) {
        NSString *upperSectionFooterTitle = [self sectionFooterTitleForSection:section - 1];
        if (upperSectionFooterTitle.length == 0) {
            insetTop -= 17.5f;
        }
    }
    
    SimpleSectionHeaderFooter *header = nil;
    header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:TranslatePrefsTableSectionHeader];
    header.textEdgeInset = UIEdgeInsetsMake(insetTop, [TDPadding large], title.length > 0?[TDPadding small]:0, [TDPadding large]);
    header.text = title;
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSString *title = [self sectionFooterTitleForSection:section];
    
    SimpleSectionHeaderFooter *footer = nil;
    if (section == ([self numberOfSectionsInTableView:tableView] - 1)) {
        footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:TranslatePrefsTableLastSectionFooter];
        footer.textEdgeInset = UIEdgeInsetsMake(title.length > 0?[TDPadding small]:0, [TDPadding large], 30, [TDPadding large]);
    } else {
        footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:TranslatePrefsTableCommonSectionFooter];
        footer.textEdgeInset = UIEdgeInsetsMake(title.length > 0?[TDPadding small]:0, [TDPadding large], 0, [TDPadding large]);
    }
    
    footer.text = title;
    return footer;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 1 && indexPath.row < [self preferredTranslateOutputLanguageList].count);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row < [self preferredTranslateOutputLanguageList].count) return YES;
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray<NSNumber *> *orderingLangs = [NSMutableArray arrayWithArray:[self preferredTranslateOutputLanguageList]];
    NSNumber *soureLang = orderingLangs[sourceIndexPath.row];
    [orderingLangs removeObjectAtIndex:sourceIndexPath.row];
    [orderingLangs insertObject:soureLang atIndex:destinationIndexPath.row];
    [TDPrefs shared].preferredTranslateOutputLanguageList = orderingLangs;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.section == 1 && proposedDestinationIndexPath.row < [self preferredTranslateOutputLanguageList].count) {
        return proposedDestinationIndexPath;
    }
    return sourceIndexPath;
}

//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [self sectionHeaderTitleForSection:section];
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//    return [self sectionFooterTitleForSection:section];
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [TDHeight app_prefsCellHeight];
//}

// use default footer height, it turns out the best user experience solution
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 50.f;
//}

// use default footer height, it turns out the best user experience solution 
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    if (section != 0) {
//        return 0.f;
//    }
//    return 0.1f;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    if (section == 1 && row == [self preferredTranslateOutputLanguageList].count) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        // Go to add language page
        [self showLanguageEditPage];
    }
    
    if (section == 2) {
        NSInteger rowLimit = [self recordsLimitValueForRelativeRowAtIndex:row];
        if ([self preferredRecordsLimit] == rowLimit) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } else {
            UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil
                                                                               message:NSLocalizedStringFromTable(@"Some limited records will be cleared, are you sure to change?", @"TinyT", nil)
                                                                        preferredStyle:UIAlertControllerStyleAlert];
            [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"TinyT", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }]];
            [alertCtrl addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"I am Sure", @"TinyT", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [TDPrefs shared].recordsLimit = @(rowLimit);
                
                // clear all but reserve the limit
                if (rowLimit != TDNumberValue_UNLIMITED) {
                    [[TodayDataController0012 new] clearAllButReserve:rowLimit];
                }
                
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
            }]];
            
            [self presentViewController:alertCtrl animated:YES completion:nil];
        }
    }
}

@end
