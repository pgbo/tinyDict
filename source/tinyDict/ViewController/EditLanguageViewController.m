//
//  EditLanguageViewController.m
//  tinyDict
//
//  Created by guangbool on 2017/5/31.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "EditLanguageViewController.h"
#import <TDKit/TDKit.h>
#import "UITableViewCell+TDApp.h"

static NSString *const EditLanguageViewController_editCell = @"EditLanguageViewController_editCell";
static NSString *const EditLanguageViewController_addCell = @"EditLanguageViewController_addCell";
static NSString *const EditLanguageViewController_disableAddCell = @"EditLanguageViewController_disableAddCell";

@interface EditLanguageViewController ()

@property (nonatomic) NSMutableArray<NSNumber *> *selectedLanguages;
@property (nonatomic) NSMutableArray<NSNumber *> *unselectedLanguages;

@end

@implementation EditLanguageViewController

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    
    }
    return self;
}

- (NSArray<NSNumber *> *)preferredTranslateOutputLanguageList {
    NSArray<NSNumber *> *preferredLangs = [TDPrefs shared].preferredTranslateOutputLanguageList?:TDDefaultValue_preferredTranslateOutputLanguageList();
    NSAssert(preferredLangs.count > 0, @"preferredLangs.count must > 0");
    return preferredLangs;
}

- (NSMutableArray<NSNumber *> *)selectedLanguages {
    if (!_selectedLanguages) {
        _selectedLanguages = [NSMutableArray<NSNumber *> array];
    }
    return _selectedLanguages;
}

- (NSMutableArray<NSNumber *> *)unselectedLanguages {
    if (!_unselectedLanguages) {
        _unselectedLanguages = [NSMutableArray<NSNumber *> array];
    }
    return _unselectedLanguages;
}

- (void)cancel:(id)sender {
    if (self.cancelHandler) {
        self.cancelHandler(self);
    }
}

- (void)done:(id)sender {
    
    [TDPrefs shared].preferredTranslateOutputLanguageList = self.selectedLanguages;
    
    if (self.doneHandler) {
        self.doneHandler(self, [self.selectedLanguages copy]);
    }
}

- (NSString *)languageDisplayText:(TDTextTranslateLanguage)lang {
    NSString *localizedKey = TDLanguageFullLocalizedKeyForType(lang);
    return NSLocalizedStringFromTable(localizedKey, @"TinyT", nil);
}

- (void)deleteLanguageInEditCellRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] != 0) return;
    if (self.selectedLanguages.count <= [indexPath row]) return;
    if (self.selectedLanguages.count == 1) return;
    
    NSNumber *optLang = self.selectedLanguages[[indexPath row]];
    [self.selectedLanguages removeObject:optLang];
    [self.unselectedLanguages insertObject:optLang atIndex:0];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]
                  withRowAnimation:UITableViewRowAnimationFade];
}

- (void)addLanguageInAddCellRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath section] != 1) return;
    if (self.unselectedLanguages.count <= [indexPath row]) return;
    if (self.selectedLanguages.count >= TD_preferredTranslateOutputLanguageListMaxCount) return;
    
    NSNumber *optLang = self.unselectedLanguages[[indexPath row]];
    [self.unselectedLanguages removeObject:optLang];
    [self.selectedLanguages addObject:optLang];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.selectedLanguages addObjectsFromArray:self.preferredTranslateOutputLanguageList];
    [self.unselectedLanguages addObjectsFromArray:({
        NSArray<NSNumber *> *all = TDTextTranslateLanguage_All();
        NSMutableArray<NSNumber *> *unselects = [NSMutableArray<NSNumber *> array];
        if (all.count > 0) [unselects addObjectsFromArray:all];
        for (NSNumber *selectLang in self.selectedLanguages) {
            [unselects removeObject:selectLang];
        }
        unselects;
    })];
    
    self.navigationItem.title = NSLocalizedStringFromTable(@"Edit language order", @"TinyT", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"TinyT", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromTable(@"Done", @"TinyT", nil) style:UIBarButtonItemStylePlain target:self action:@selector(done:)];
    
    self.tableView.allowsSelectionDuringEditing = NO;
    self.tableView.editing = YES;
}

#pragma mark - Table view data source

- (UITableViewCell *)editCellDequeued {
    NSString *identifier = EditLanguageViewController_editCell;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell textLabelConfigureDefault];
    }
    return cell;
}

- (UITableViewCell *)addCellDequeued {
    NSString *identifier = EditLanguageViewController_addCell;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell textLabelConfigureDefault];
    }
    return cell;
}

- (UITableViewCell *)disableAddCellDequeued {
    NSString *identifier = EditLanguageViewController_disableAddCell;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [TDFontSpecs large];
        cell.textLabel.textColor = [TDColorSpecs app_minorTextColor];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return self.selectedLanguages.count;
    if (section == 1) return self.unselectedLanguages.count;
    return 0;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if (section == 0) {
        UITableViewCell *cell = [self editCellDequeued];
        cell.textLabel.text = [self languageDisplayText:self.selectedLanguages[row].integerValue];
        return cell;
    }
    
    if (section == 1) {
        UITableViewCell *cell = nil;
        if (self.selectedLanguages.count >= TD_preferredTranslateOutputLanguageListMaxCount) {
            cell = [self disableAddCellDequeued];
        } else {
            cell = [self addCellDequeued];
        }
        cell.textLabel.text = [self languageDisplayText:self.unselectedLanguages[row].integerValue];
        return cell;
    }
    
    return nil;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger selectedCount = [self.selectedLanguages count];
    NSInteger section = [indexPath section];
    
    if (selectedCount <= 1 && section == 0) {
        return NO;
    }
    
    if (selectedCount >= TD_preferredTranslateOutputLanguageListMaxCount && section == 1) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = [indexPath section];
    
    if (section == 0 && editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteLanguageInEditCellRowAtIndexPath:indexPath];
        return;
    }
    
    if (section == 1 && editingStyle == UITableViewCellEditingStyleInsert) {
        [self addLanguageInAddCellRowAtIndexPath:indexPath];
        return;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    NSUInteger fromIdx = [fromIndexPath row];
    NSUInteger toIdx = [toIndexPath row];
    
    NSNumber *fromIdxObj = self.selectedLanguages[fromIdx];
    NSNumber *toIdxObj = self.selectedLanguages[toIdx];
    
    NSMutableArray<NSNumber *> *opt = [self.selectedLanguages mutableCopy];
    [opt replaceObjectAtIndex:fromIdx withObject:toIdxObj];
    [opt replaceObjectAtIndex:toIdx withObject:fromIdxObj];
    
    self.selectedLanguages = opt;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.section == 0) {
        return proposedDestinationIndexPath;
    }
    return sourceIndexPath;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([indexPath section] == 0);
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return NSLocalizedStringFromTable(@"SELECTED LANGUAGES", @"TinyT", nil);
    if (section == 1) return NSLocalizedStringFromTable(@"MORE...", @"TinyT", nil);
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        NSUInteger selectedCount = self.selectedLanguages.count;
        NSUInteger limit = TD_preferredTranslateOutputLanguageListMaxCount;
        NSUInteger remains = limit - selectedCount;
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ languages is limited, %@ remains", @"TinyT", nil), @(limit), @(remains)];
    }
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger selectedCount = [self.selectedLanguages count];
    NSInteger section = [indexPath section];
    
    if (selectedCount > 1 && section == 0) {
        return UITableViewCellEditingStyleDelete;
    }
    
    if (selectedCount < TD_preferredTranslateOutputLanguageListMaxCount && section == 1) {
        return UITableViewCellEditingStyleInsert;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
