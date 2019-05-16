//
//  ShareEditMultiLevelMenuCell.m
//  tinyDict
//
//  Created by guangbool on 2017/5/11.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "ShareEditMultiLevelMenuCell.h"
#import <TDKit/TDSpecs.h>
#import <TDKit/Masonry.h>
#import "NSBundle+TDApp.h"

static NSString *const ShareEditSecondaryMenuCell = @"ShareEditSecondaryMenuCell";
static const CGFloat ShareEditMultiLevelMenuCellShrinkHeight = 55;
static const CGFloat ShareEditMultiLevelMenuCellSecondaryMenuHeight = 40;
static const CGFloat ShareEditMultiLevelMenuCellBottomPadding = (55.f-40.f)/2;

@interface ShareEditMultiLevelMenuCell () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UIView *shrinkStateContainer;
@property (nonatomic) UIImageView *menuIconView;
@property (nonatomic) UILabel *menuTitleLabel;
@property (nonatomic) UIButton *cancelButn;
@property (nonatomic) UIImageView *arrowAccessoryView;
@property (nonatomic) UITableView *optionTable;

@end

@implementation ShareEditMultiLevelMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [self initWithReuseIdentifier:reuseIdentifier extensible:NO];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier extensible:(BOOL)extensible {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        _extensible = extensible;
        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    
    self.backgroundColor = [TDColorSpecs app_cellColor];
    
    self.clipsToBounds = YES;
    
    if (self.extensible) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    [self.contentView addSubview:self.shrinkStateContainer];
    [self.shrinkStateContainer addSubview:self.menuIconView];
    [self.shrinkStateContainer addSubview:self.menuTitleLabel];
    if (self.extensible) {
        [self.shrinkStateContainer addSubview:self.cancelButn];
    }
    [self.shrinkStateContainer addSubview:self.arrowAccessoryView];
    self.arrowAccessoryView.image = self.extensible?[NSBundle arrowDownIcon]:[NSBundle arrowRightIcon];
    
    if (self.extensible) {
        [self.contentView addSubview:self.optionTable];
    }
    
    
    [self.shrinkStateContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(ShareEditMultiLevelMenuCellShrinkHeight);
        make.leading.and.trailing.mas_equalTo(0);
    }];
    
    [self.menuIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.leading.mas_equalTo([TDPadding large]);
    }];
    
    __weak typeof(self)weakSelf = self;
    [self.menuTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.leading.equalTo(weakSelf.menuIconView.mas_trailing).offset([TDPadding large]);
    }];
    
    [_cancelButn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.trailing.mas_equalTo(-[TDPadding large]);
    }];
    
    [self.arrowAccessoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.trailing.mas_equalTo(-[TDPadding large]);
    }];
    
    
    if (self.extensible) {
        CGFloat tableHeight = [self caculateOptionTableHeight];
        [_optionTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.shrinkStateContainer.mas_bottom);
            make.leading.equalTo(weakSelf.menuIconView.mas_trailing);
            make.trailing.mas_equalTo(0);
            make.height.mas_equalTo(tableHeight);
        }];
    }
    
    [self _setExpanded:NO animated:NO];
}

- (UIView *)shrinkStateContainer {
    if (!_shrinkStateContainer) {
        _shrinkStateContainer = [UIView new];
    }
    return _shrinkStateContainer;
}

- (UIImageView *)menuIconView {
    if (!_menuIconView) {
        _menuIconView = [[UIImageView alloc] init];
    }
    return _menuIconView;
}

- (UILabel *)menuTitleLabel {
    if (!_menuTitleLabel) {
        _menuTitleLabel = [UILabel new];
        _menuTitleLabel.font = [TDFontSpecs large];
        _menuTitleLabel.textColor = [TDColorSpecs app_mainTextColor];
        if (self.menuTitleGetter) {
            _menuTitleLabel.text = self.menuTitleGetter(self, self.expanded);
        }
    }
    return _menuTitleLabel;
}

- (UIButton *)cancelButn {
    if (!_cancelButn) {
        _cancelButn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButn.titleLabel.font = [TDFontSpecs regular];
        [_cancelButn setTitleColor:[TDColorSpecs app_minorTextColor] forState:UIControlStateNormal];
        [_cancelButn setTitle:NSLocalizedStringFromTable(@"Cancel", @"TinyT", nil) forState:UIControlStateNormal];
        [_cancelButn addTarget:self action:@selector(exitExpand:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButn;
}

- (UIImageView *)arrowAccessoryView {
    if (!_arrowAccessoryView) {
        _arrowAccessoryView = [[UIImageView alloc] init];
    }
    return _arrowAccessoryView;
}

- (UITableView *)optionTable {
    if (!_optionTable) {
        _optionTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStylePlain];
        _optionTable.backgroundColor = [UIColor clearColor];
        _optionTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _optionTable.scrollEnabled = NO;
        [_optionTable registerClass:[UITableViewCell class] forCellReuseIdentifier:ShareEditSecondaryMenuCell];
        _optionTable.delegate = self;
        _optionTable.dataSource = self;
    }
    return _optionTable;
}

- (void)exitExpand:(id)sender {
    [self setExpanded:NO animated:YES];
    if (self.exitExpandHandler) {
        self.exitExpandHandler(self);
    }
}

- (CGFloat)caculateOptionTableHeight {
    CGFloat tableHeight = 0;
    if (self.expanded && self.secondaryMenuTitles.count > 0) {
        tableHeight = [self.class secondaryMenuTableHeightWithMenuNumber:self.secondaryMenuTitles.count];
    }
    return tableHeight;
}

- (void)setMenuIcon:(UIImage *)menuIcon {
    _menuIcon = menuIcon;
    _menuIconView.image = menuIcon;
    [self setNeedsLayout];
}

- (void)setSecondaryMenuTitles:(NSArray<NSString *> *)secondaryMenuTitles {
    _secondaryMenuTitles = [secondaryMenuTitles copy];
    
    CGFloat tableHeight = [self caculateOptionTableHeight];
    [_optionTable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tableHeight);
    }];
    
    [_optionTable reloadData];
}

- (void)setMenuTitleGetter:(NSString *(^)(__kindof UITableViewCell *, BOOL))menuTitleGetter {
    _menuTitleGetter = [menuTitleGetter copy];
    _menuTitleLabel.text = _menuTitleGetter?_menuTitleGetter(self, self.expanded):nil;
}

- (void)_setExpanded:(BOOL)expanded animated:(BOOL)animated {
    _expanded = expanded;
    
    CGFloat tarTableHeight = 0;
    if (self.extensible) {
        tarTableHeight = [self caculateOptionTableHeight];
    }
    
    _menuTitleLabel.text = self.menuTitleGetter?self.menuTitleGetter(self, expanded):nil;
    
    if (expanded) {
        _cancelButn.hidden = NO;
        _arrowAccessoryView.hidden = YES;
    } else {
        _cancelButn.hidden = YES;
        _arrowAccessoryView.hidden = NO;
    }
    
    if (self.extensible) {
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^{
                self.optionTable.hidden = !expanded;
                [self.optionTable mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(tarTableHeight);
                }];
            } completion:^(BOOL finished) {
                [self.optionTable reloadData];
            }];
        } else {
            self.optionTable.hidden = !expanded;
            [self.optionTable mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(tarTableHeight);
            }];
        }
    }
}

- (void)setExpanded:(BOOL)expanded {
    [self setExpanded:expanded animated:NO];
}

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated {
    if (!self.extensible) {
        NSAssert(NO, @"Can set 'expanded' when 'extensible' is false.");
        return;
    }
    
    [self _setExpanded:expanded animated:animated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.secondaryMenuTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ShareEditSecondaryMenuCell
                                                            forIndexPath:indexPath];
    cell.textLabel.font = [TDFontSpecs large];
    cell.textLabel.textColor = [TDColorSpecs app_mainTextColor];
    
    static NSInteger topSeparatorTag = 100;
    UIView *topSeparator = [cell.contentView viewWithTag:topSeparatorTag];
    if (!topSeparator) {
        topSeparator = [self.class createSeperatorView];
        topSeparator.tag = topSeparatorTag;
        [cell.contentView addSubview:topSeparator];
        [topSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.leading.and.trailing.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
    }
    
    cell.textLabel.text = self.secondaryMenuTitles[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ShareEditMultiLevelMenuCellSecondaryMenuHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.secondaryMenuSelectionHandler) {
        self.secondaryMenuSelectionHandler(self, [indexPath row]);
    }
}

+ (UIView *)createSeperatorView {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 8, 0.5);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [path moveToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetHeight(rect)/2)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetHeight(rect)/2)];
    [path setLineWidth:CGRectGetHeight(rect)];
    double dash[] = {2, 2};
    [path setLineDash:dash count:2 phase:0];
    
    [[TDColorSpecs app_separator] setStroke];
    [path stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    image = [image resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    return imageView;
}

+ (CGFloat)secondaryMenuTableHeightWithMenuNumber:(NSUInteger)num {
    return num * ShareEditMultiLevelMenuCellSecondaryMenuHeight;
}

+ (CGFloat)heightWithExpanded:(BOOL)expanded secondaryMenusNumber:(NSUInteger)secondaryMenusNumber {
    
    CGFloat height = 0;
    height += ShareEditMultiLevelMenuCellShrinkHeight;
    if (expanded && secondaryMenusNumber > 0) {
        height += [self secondaryMenuTableHeightWithMenuNumber:secondaryMenusNumber];
        height += ShareEditMultiLevelMenuCellBottomPadding;
    }
    
    return height;
}

@end
