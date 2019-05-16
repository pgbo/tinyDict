//
//  TranslateDetailPreferencePanel.m
//  tinyDict
//
//  Created by guangbool on 2017/5/9.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TranslateDetailPreferencePanel.h"
#import "PreferenceItemCell.h"
#import <TDKit/TDSpecs.h>
#import <TDKit/Masonry.h>

static NSString *TranslateDetailPreferenceSwitchTypeCellDequeued = @"switchTypeCellDequeued";
static NSString *TranslateDetailPreferenceCheckmarkTypeCellDequeued = @"checkmarkTypeCellDequeued";

@interface TranslateDetailPreferencePanel () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *table;

@end

@implementation TranslateDetailPreferencePanel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureViews];
    }
    return self;
}

- (void)dealloc {
    [_table removeObserver:self forKeyPath:@"contentSize"];
}

- (void)configureViews {
    [self addSubview:self.table];
    
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.and.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.table reloadData];
    
    [_table addObserver:self
             forKeyPath:@"contentSize"
                options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self didObservedContentSizeChanged];
    }
}

- (void)didObservedContentSizeChanged {
    [self invalidateIntrinsicContentSize];
}

- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
        _table.backgroundColor = [TDColorSpecs app_pageBackground];
        _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _table.separatorColor = [TDColorSpecs app_separator];
        [_table registerClass:[PreferenceItemCell class] forCellReuseIdentifier:TranslateDetailPreferenceSwitchTypeCellDequeued];
        [_table registerClass:[PreferenceItemCell class] forCellReuseIdentifier:TranslateDetailPreferenceCheckmarkTypeCellDequeued];
        _table.delegate = self;
        _table.dataSource = self;
        
        // Caculate cell height automatically
        _table.estimatedRowHeight = [TDHeight app_prefsCellHeight];
        _table.rowHeight = UITableViewAutomaticDimension;
    }
    return _table;
}

- (void)setOnlySaveLastTranslateOn:(BOOL)onlySaveLastTranslateOn {
    _onlySaveLastTranslateOn = onlySaveLastTranslateOn;
    [_table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setSelectOption:(TDAppTranslateCopyOptionPreference)selectOption {
    _selectOption = selectOption;
    [_table reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setMaxIntrinsicContentHeight:(CGFloat)maxIntrinsicContentHeight {
    _maxIntrinsicContentHeight = maxIntrinsicContentHeight;
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    
    UIEdgeInsets tableContentInset = _table.contentInset;
    CGFloat contentHeight = _table.contentSize.height + tableContentInset.top + tableContentInset.bottom;
    
    CGRect frame = self.frame;
    CGFloat intrinsicHeight = MIN(contentHeight, self.maxIntrinsicContentHeight);
    return CGSizeMake(CGRectGetWidth(frame), intrinsicHeight);
}

- (NSString *)copyOptionRowTitleAtIndex:(NSUInteger)index {
    NSString *localizedKey = nil;
    if (index == 0) {
        localizedKey = @"Copy source only";
    } else if (index == 1) {
        localizedKey = @"Copy translated result only";
    } else if (index == 2) {
        localizedKey = @"Copy source and result together";
    }
    if (localizedKey) {
        return NSLocalizedStringFromTable(localizedKey, @"TinyT", nil);
    }
    return nil;
}

- (TDAppTranslateCopyOptionPreference)copyOptionForRowAtIndex:(NSUInteger)index {
    if (index == 0) return TDAppTranslateCopyInputOnly;
    if (index == 1) return TDAppTranslateCopyOutputOnly;
    if (index == 2) return TDAppTranslateCopyAll;
    return TDAppTranslateCopyInputOnly;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 1;
    if (section == 1) return 3;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        PreferenceItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TranslateDetailPreferenceSwitchTypeCellDequeued forIndexPath:indexPath];
        [self configureSaveLastTranslateSwitchCell:cell forRowAtIndexPath:indexPath];
        return cell;
    }
    
    if (section == 1) {
        PreferenceItemCell *cell = [tableView dequeueReusableCellWithIdentifier:TranslateDetailPreferenceCheckmarkTypeCellDequeued forIndexPath:indexPath];
        
        [cell configureWithModel:({
            PreferenceItemCellModel *model = [PreferenceItemCellModel new];
            model.type = PreferenceTypeCheckmark;
            model.title = [self copyOptionRowTitleAtIndex:row];
            model.subTitle = nil;
            model;
        })];
        
        cell.checked = (self.selectOption == [self copyOptionForRowAtIndex:row]);
        return cell;
    }
    
    return nil;
}

- (void)configureSaveLastTranslateSwitchCell:(PreferenceItemCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [cell configureWithModel:({
        PreferenceItemCellModel *model = [PreferenceItemCellModel new];
        model.type = PreferenceTypeSwitch;
        model.title = NSLocalizedStringFromTable(@"Save last translation only", @"TinyT", nil);
        model.subTitle = NSLocalizedStringFromTable(@"If translate repeatedly in this page, save the last one only", @"TinyT", nil);
        model;
    })];
    
    cell.switchOn = self.onlySaveLastTranslateOn;
    __weak typeof(self)weakSelf = self;
    cell.switchValueChangedBlock = ^(PreferenceItemCell *cell, BOOL on){
        if (weakSelf.onlySaveLastTranslateToggleBlock) {
            weakSelf.onlySaveLastTranslateToggleBlock(self, on);
        }
    };
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if (section == 0) {
        title = NSLocalizedStringFromTable(@"TRANSLATE", @"TinyT", nil);
    } else if (section == 1) {
        title = NSLocalizedStringFromTable(@"COPY", @"TinyT", nil);
    }
    return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        self.selectOption = [self copyOptionForRowAtIndex:indexPath.row];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        if (self.preferredCopyOptionSelectionBlock) {
            self.preferredCopyOptionSelectionBlock(self, self.selectOption);
        }
    }
}

@end
