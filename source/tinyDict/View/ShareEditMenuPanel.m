//
//  ShareEditMenuPanel.m
//  tinyDict
//
//  Created by guangbool on 2017/5/11.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "ShareEditMenuPanel.h"
#import <TDKit/TDSpecs.h>
#import <TDKit/TDPrefs.h>
#import <TDKit/Masonry.h>
#import <TDKit/UIView+TDKit.h>
#import <TDKit/BDFYSearch.h>
#import "ShareEditMultiLevelMenuCell.h"
#import "PreferenceItemCell.h"
#import "UITableViewCell+TDApp.h"

static NSString *const ShareEditMenuPanelOneLevelMenuCell = @"oneLevelMenuCell";
static NSString *const ShareEditMenuPanelTwoLevelMenuCell = @"twoLevelMenuCell";
static NSString *const ShareEditMenuPanelAlignmentSwitchMenuCell = @"alignmentSwitchMenuCell";
static NSString *const ShareEditMenuPanelAlignmentOptionCell = @"alignmentOptionCell";


@interface ShareEditMenuPanel () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *table;
@property (nonatomic, copy) NSArray<NSNumber *> *preferredTranslateOutputLanguageList;
@property (nonatomic, copy) NSArray<NSString *> *photoFromMethodNames;

@property (nonatomic) BOOL insertTranslationCellExpanded;
@property (nonatomic) BOOL insertPhotoCellExpanded;

@end

@implementation ShareEditMenuPanel

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
        make.bottom.mas_equalTo(0);
        make.leading.and.trailing.mas_equalTo(0);
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
        _table.delegate = self;
        _table.dataSource = self;
    }
    return _table;
}

- (NSArray<NSNumber *> *)preferredTranslateOutputLanguageList {
    if (!_preferredTranslateOutputLanguageList) {
        NSArray<NSNumber *> *preferredLangs = [TDPrefs shared].preferredTranslateOutputLanguageList?:TDDefaultValue_preferredTranslateOutputLanguageList();
        NSAssert(preferredLangs.count > 0, @"preferredLangs.count must > 0");
        _preferredTranslateOutputLanguageList = [preferredLangs copy];
    }
    return _preferredTranslateOutputLanguageList;
}

- (NSArray<NSString *> *)translateOutputLanguageNames {
    NSArray<NSNumber *> *preferredLangs = [TDPrefs shared].preferredTranslateOutputLanguageList?:TDDefaultValue_preferredTranslateOutputLanguageList();
    NSAssert(preferredLangs.count > 0, @"preferredLangs.count must > 0");
    NSMutableArray<NSString *> *names = [NSMutableArray<NSString *> array];
    for (NSNumber *lang in preferredLangs) {
        NSString *key = TDLanguageFullLocalizedKeyForType(lang.integerValue);
        NSString *name = NSLocalizedStringFromTable(key, @"TinyT", nil);
        [names addObject:name];
    }
    return [names copy];
}

- (NSArray<NSString *> *)photoFromMethodNames {
    if (!_photoFromMethodNames) {
        _photoFromMethodNames = @[NSLocalizedStringFromTable(@"Photo album", @"TinyT", nil),
                                  NSLocalizedStringFromTable(@"Take photo", @"TinyT", nil)];
    }
    return _photoFromMethodNames;
}

- (ShareEditMultiLevelMenuCell *)oneLevelMenuCellDequeued {
    NSString *identifier = ShareEditMenuPanelOneLevelMenuCell;
    ShareEditMultiLevelMenuCell *cell = [_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ShareEditMultiLevelMenuCell alloc] initWithReuseIdentifier:identifier extensible:NO];
    }
    return cell;
}

- (ShareEditMultiLevelMenuCell *)twoLevelMenuCellDequeued {
    NSString *identifier = ShareEditMenuPanelTwoLevelMenuCell;
    ShareEditMultiLevelMenuCell *cell = [_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ShareEditMultiLevelMenuCell alloc] initWithReuseIdentifier:identifier extensible:YES];
    }
    return cell;
}

- (PreferenceItemCell *)alignmentSwitchMenuCellDequeued {
    NSString *identifier = ShareEditMenuPanelAlignmentSwitchMenuCell;
    PreferenceItemCell *cell = [_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PreferenceItemCell alloc] initWithReuseIdentifier:identifier];
        [cell configureWithModel:({
            PreferenceItemCellModel *model = [PreferenceItemCellModel new];
            model.type = PreferenceTypeSwitch;
            model.title = NSLocalizedStringFromTable(@"Align current paragraph only", @"TinyT", nil);
            model.subTitle = nil;
            model;
        })];
        __weak typeof(self)weakSelf = self;
        cell.switchValueChangedBlock = ^(PreferenceItemCell *cell, BOOL on) {
            [weakSelf updateAlignCurrentParagraphOnlyWithValue:on];
            if (weakSelf.alignCurrentParagraphOnlyToggleHandler) {
                weakSelf.alignCurrentParagraphOnlyToggleHandler(weakSelf, on);
            }
        };
    }
    return cell;
}

- (UITableViewCell *)alignmentOptionCellDequeued {
    NSString *identifier = ShareEditMenuPanelAlignmentOptionCell;
    UITableViewCell *cell = [_table dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell textLabelConfigureDefault];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = NSLocalizedStringFromTable(@"Alignment", @"TinyT", nil);
        cell.accessoryView = ({
            NSArray *items = @[[UIImage imageNamed:@"left_align_ic"],
                               [UIImage imageNamed:@"center_align_ic"],
                               [UIImage imageNamed:@"right_align_ic"]];
            UISegmentedControl *optionView = [[UISegmentedControl alloc] initWithItems:items];
            optionView.tintColor = [TDColorSpecs app_minorTextColor];
            optionView.momentary = YES;
            [optionView addTarget:self action:@selector(alignOptionChanged:) forControlEvents:UIControlEventValueChanged];
            optionView;
        });
    }
    return cell;
}

- (void)alignOptionChanged:(UISegmentedControl *)optionView {
    NSInteger idx = optionView.selectedSegmentIndex;
    if (self.alignOptionHandler) {
        NSTextAlignment alignment = NSTextAlignmentLeft;
        if (idx == 1) alignment = NSTextAlignmentCenter;
        else if (idx == 2) alignment = NSTextAlignmentRight;
        
        self.alignOptionHandler(self, alignment);
    }
}

- (void)updateAlignCurrentParagraphOnlyWithValue:(BOOL)value {
    _alignCurrentParagraphOnly = value;
}

- (void)setAlignCurrentParagraphOnly:(BOOL)alignCurrentParagraphOnly {
    _alignCurrentParagraphOnly = alignCurrentParagraphOnly;
    
    [_table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setShowTranslationEditOptions:(BOOL)showTranslationEditOptions {
    _showTranslationEditOptions = showTranslationEditOptions;
    
    [_table reloadData];
    [self invalidateIntrinsicContentSize];
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

- (void)judgeNumberOfRowsInSectionInsert:(NSUInteger *)rowNumInSectionInsert
                        sectionAlignment:(NSUInteger *)rowNumInSectionAlignment
                            sectionOther:(NSUInteger *)rowNumInSectionOther {
    
    NSUInteger  rowInSectionInsert = 0,
                rowInSectionAlignment = 0,
                rowInSectionOther = 0;

    // insert source row
    rowInSectionInsert += _showTranslationEditOptions?1:0;
    // insert translation row
    rowInSectionInsert += _showTranslationEditOptions?1:0;
    // insert photo row
    rowInSectionInsert += 1;

    // align setting rows
    rowInSectionAlignment += 2;
    
    // reset row
    rowInSectionOther += _showTranslationEditOptions?1:0;
    // preview row
    rowInSectionOther += 1;
    
    if (rowNumInSectionInsert != NULL) {
        *rowNumInSectionInsert = rowInSectionInsert;
    }
    if (rowNumInSectionAlignment != NULL) {
        *rowNumInSectionAlignment = rowInSectionAlignment;
    }
    if (rowNumInSectionOther != NULL) {
        *rowNumInSectionOther = rowInSectionOther;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 3;
    if (section == 1) return 2;
    if (section == 2) return 2;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    if (section == 0) {
        // section 'Insert'
        
        if (row == 0) {
            ShareEditMultiLevelMenuCell *menuCell = [self oneLevelMenuCellDequeued];
            [self configureOneLevelCell:menuCell atIndexPath:indexPath withTitle:NSLocalizedStringFromTable(@"Insert source", @"TinyT", nil) iconImage:[UIImage imageNamed:@"movable_acc"]];
            return menuCell;
        } else if (row == 1) {
            ShareEditMultiLevelMenuCell *menuCell = [self twoLevelMenuCellDequeued];
            [self configureInsertTranslationRowCell:menuCell atIndexPath:indexPath];
            return menuCell;
        } else if (row == 2) {
            ShareEditMultiLevelMenuCell *menuCell = [self twoLevelMenuCellDequeued];
            [self configureInsertPhotoRowCell:menuCell atIndexPath:indexPath];
            return menuCell;
        }
    }
    
    if (section == 1) {
        // section 'Alignment'
        if (row == 0) {
            PreferenceItemCell *menuCell = [self alignmentSwitchMenuCellDequeued];
            menuCell.switchOn = self.alignCurrentParagraphOnly;
            return menuCell;
        } else if (row ==1) {
            UITableViewCell *menuCell = [self alignmentOptionCellDequeued];
            return menuCell;
        }
    }
    
    if (section == 2) {
        // section 'other'
        
        ShareEditMultiLevelMenuCell *menuCell = [self oneLevelMenuCellDequeued];
        UIImage *menuIcon = nil;
        NSString *menuTitle = nil;
        if (row == 0) {
            menuIcon = [UIImage imageNamed:@"arrange_menu_ic"];
            menuTitle = NSLocalizedStringFromTable(@"Reset", @"TinyT", nil);
        } else if (row == 1) {
            menuIcon = [UIImage imageNamed:@"expand_menu_ic"];
            menuTitle = NSLocalizedStringFromTable(@"Preview", @"TinyT", nil);
        }
        [self configureOneLevelCell:menuCell atIndexPath:indexPath withTitle:menuTitle iconImage:menuIcon];
        return menuCell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if (section == 0) {
        // section 'Insert'
        
        if (row == 1) {
            [(ShareEditMultiLevelMenuCell *)cell setExpanded:self.insertTranslationCellExpanded animated:YES];
        } else if (row == 2) {
            [(ShareEditMultiLevelMenuCell *)cell setExpanded:self.insertPhotoCellExpanded animated:YES];
        }
    }
    
}

- (void)configureInsertTranslationRowCell:(ShareEditMultiLevelMenuCell *)menuCell atIndexPath:(NSIndexPath *)indexPath {

    menuCell.menuIcon = [UIImage imageNamed:@"translate_menu_ic"];
    menuCell.secondaryMenuTitles = self.translateOutputLanguageNames;
    
    menuCell.menuTitleGetter = ^NSString *(ShareEditMultiLevelMenuCell *cell, BOOL expanded) {
        return NSLocalizedStringFromTable(expanded?@"Select one translation":@"Insert translation", @"TinyT", nil);
    };
    
    __weak typeof(self)weakSelf = self;
    menuCell.exitExpandHandler = ^(ShareEditMultiLevelMenuCell *cell){
        weakSelf.insertTranslationCellExpanded = NO;
        [weakSelf.table reloadRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    };
    
    menuCell.secondaryMenuSelectionHandler = ^(ShareEditMultiLevelMenuCell *cell, NSInteger index){
        if (weakSelf.translationInsertHandler) {
            weakSelf.translationInsertHandler(weakSelf,
                                              weakSelf.preferredTranslateOutputLanguageList[index].integerValue);
        }
    };
}

- (void)configureInsertPhotoRowCell:(ShareEditMultiLevelMenuCell *)menuCell atIndexPath:(NSIndexPath *)indexPath {
    
    menuCell.menuIcon = [UIImage imageNamed:@"image_menu_ic"];
    menuCell.secondaryMenuTitles = self.photoFromMethodNames;
    
    menuCell.menuTitleGetter = ^NSString *(ShareEditMultiLevelMenuCell *cell, BOOL expanded) {
        return NSLocalizedStringFromTable(expanded?@"Select picture from":@"Insert picture", @"TinyT", nil);;
    };
    
    __weak typeof(self)weakSelf = self;
    menuCell.exitExpandHandler = ^(ShareEditMultiLevelMenuCell *cell){
        weakSelf.insertPhotoCellExpanded = NO;
        [weakSelf.table reloadRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    };
    
    menuCell.secondaryMenuSelectionHandler = ^(ShareEditMultiLevelMenuCell *cell, NSInteger index){
        if (weakSelf.photoInsertHandler) {
            weakSelf.photoInsertHandler(weakSelf,
                                        index == 0,
                                        index == 1);
        }
    };
}

- (void)configureOneLevelCell:(ShareEditMultiLevelMenuCell *)menuCell
                  atIndexPath:(NSIndexPath *)indexPath
                    withTitle:(NSString *)title
                    iconImage:(UIImage *)iconImage {
    menuCell.menuIcon = iconImage;
    menuCell.menuTitleGetter = ^NSString *(ShareEditMultiLevelMenuCell *cell, BOOL expanded) {
        return title;
    };
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    if (section == 0 ) {
        if (row == 0 && !_showTranslationEditOptions) return 0;
        if (row == 1 && !_showTranslationEditOptions) return 0;
    } else if (section == 2) {
        if (row == 0 && !_showTranslationEditOptions) return 0;
    }
    
    if (section == 0 && row == 1) {
        return [ShareEditMultiLevelMenuCell heightWithExpanded:self.insertTranslationCellExpanded
                                          secondaryMenusNumber:[self preferredTranslateOutputLanguageList].count];
    }
    
    if (section == 0 && row == 2) {
        return [ShareEditMultiLevelMenuCell heightWithExpanded:self.insertPhotoCellExpanded
                                          secondaryMenusNumber:[self photoFromMethodNames].count];
    }
    
    return [ShareEditMultiLevelMenuCell heightWithExpanded:NO secondaryMenusNumber:0];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return NSLocalizedStringFromTable(@"INSERT", @"TinyT", nil);
    if (section == 1) return NSLocalizedStringFromTable(@"ALIGNMENT", @"TinyT", nil);
    if (section == 2) return NSLocalizedStringFromTable(@"OTHER", @"TinyT", nil);
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    if (section == 0) {
        if (row == 0 && self.sourceInsertHandler) {
            self.sourceInsertHandler(self);
        } else if (row == 1 && !self.insertTranslationCellExpanded) {
            self.insertTranslationCellExpanded = !self.insertTranslationCellExpanded;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else if (row == 2 && !self.insertPhotoCellExpanded) {
            self.insertPhotoCellExpanded = !self.insertPhotoCellExpanded;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        return;
    }
    
    if (section == 2) {
        if (row == 0 && self.resetHandler) {
            self.resetHandler(self);
        } else if (row ==1 && self.previewHandler) {
            self.previewHandler(self);
        }
    }
}

@end
