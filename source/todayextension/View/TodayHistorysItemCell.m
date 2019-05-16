//
//  TodayHistorysItemCell.m
//  tinyDict
//
//  Created by guangbool on 2017/4/6.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TodayHistorysItemCell.h"
#import <TDKit/TDSpecs.h>
#import <TDKit/Masonry.h>
#import <TDKit/UIImage+TDKit.h>

@interface TodayHistorysItemCell ()

// 条目 icon 视图
@property (nonatomic) UIImageView *itemIconView;
// 正在查询标示视图
@property (nonatomic) UIActivityIndicatorView *searchingIndicatorView;
// 正在输入标示视图
@property (nonatomic) UIImageView *inputingIndicatorView;
// 输入内容显示视图
@property (nonatomic) UILabel *inputDisplaylabel;

@property (nonatomic) UILongPressGestureRecognizer *longPressRecognizer;

@property (nonatomic) TodayHistoryItemViewModel *viewModel;

@end

@implementation TodayHistorysItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (UIImageView *)itemIconView {
    if (!_itemIconView) {
        _itemIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_item_ic"]];
        _itemIconView.contentMode = UIViewContentModeCenter;
    }
    return _itemIconView;
}

- (UIActivityIndicatorView *)searchingIndicatorView {
    if (!_searchingIndicatorView) {
        _searchingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _searchingIndicatorView.tintColor = [TDColorSpecs wd_tint];
        _searchingIndicatorView.hidesWhenStopped = YES;
    }
    return _searchingIndicatorView;
}

- (UIImageView *)inputingIndicatorView {
    if (!_inputingIndicatorView) {
        _inputingIndicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inputing_indicator_img3"]];
    }
    return _inputingIndicatorView;
}


- (UILabel *)inputDisplaylabel {
    if (!_inputDisplaylabel) {
        _inputDisplaylabel = [UILabel new];
        _inputDisplaylabel.textColor = [TDColorSpecs wd_tint];
        _inputDisplaylabel.font = [TDFontSpecs regularBold];
        _inputDisplaylabel.numberOfLines = 1;
    }
    return _inputDisplaylabel;
}

- (UILongPressGestureRecognizer *)longPressRecognizer {
    if (!_longPressRecognizer) {
        _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    }
    return _longPressRecognizer;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan){
        if (self.longPressedBlock) {
            self.longPressedBlock(self);
        }
    }
}

- (void)setupViews {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.itemIconView];
    [self.contentView addSubview:self.searchingIndicatorView];
    [self.contentView addSubview:self.inputingIndicatorView];
    [self.contentView addSubview:self.inputDisplaylabel];
    __weak typeof(self)weakSelf = self;
    
    [self.itemIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.mas_equalTo(20);
        make.leading.mas_equalTo([TDPadding regular]);
        make.centerY.mas_equalTo(0);
    }];
    
    [self.searchingIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.itemIconView.mas_centerX);
        make.centerY.equalTo(weakSelf.itemIconView.mas_centerY);
    }];
    
    [self.inputingIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.itemIconView.mas_trailing).offset([TDPadding tiny]);
        make.centerY.mas_equalTo(0);
    }];
    
    [self.inputDisplaylabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.inputingIndicatorView.mas_leading);
        make.trailing.mas_equalTo((-1)*[TDPadding regular]);
        make.centerY.mas_equalTo(0);
    }];
    
    // change searching indicator size using `transform`
    self.searchingIndicatorView.transform = CGAffineTransformMakeScale(0.75, 0.75);
    
    // add 
    [self addGestureRecognizer:self.longPressRecognizer];
}

- (void)configureWithViewModel:(TodayHistoryItemViewModel *)viewModel {
    
    self.viewModel = viewModel;
    
    NSString *input = viewModel.input;
    switch (viewModel.cellType) {
        case TodayHistoryItemNormalCell: {
            [self.searchingIndicatorView stopAnimating];
            self.inputingIndicatorView.hidden = YES;
            self.itemIconView.hidden = NO;
            self.inputDisplaylabel.hidden = NO;
            self.inputDisplaylabel.text = input;
            self.longPressRecognizer.enabled = YES;
            break;
        }
        case TodayHistoryItemInputingCell: {
            self.inputDisplaylabel.hidden = YES;
            self.inputDisplaylabel.text = nil;
            [self.searchingIndicatorView stopAnimating];
            self.itemIconView.hidden = NO;
            self.inputingIndicatorView.hidden = NO;
            self.longPressRecognizer.enabled = NO;
            break;
        }
        case TodayHistoryItemSearchingCell: {
            self.inputingIndicatorView.hidden = YES;
            self.itemIconView.hidden = YES;
            self.inputDisplaylabel.hidden = NO;
            self.inputDisplaylabel.text = input;
            [self.searchingIndicatorView startAnimating];
            self.longPressRecognizer.enabled = NO;
            break;
        }
    }
    
    UIImage *itemIc = [UIImage imageNamed:@"list_item_ic"];
    if (viewModel.isStarred) {
        itemIc = [itemIc imageByTintColor:[TDColorSpecs remindColor]];
    }
    [self.itemIconView setImage:itemIc];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end


@implementation TodayHistoryItemViewModel
@end
