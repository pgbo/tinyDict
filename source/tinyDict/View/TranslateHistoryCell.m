//
//  TranslateHistoryCell.m
//  tinyDict
//
//  Created by guangbool on 2017/4/21.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TranslateHistoryCell.h"
#import <TDKit/TDSpecs.h>
#import <TDKit/UIImage+TDKit.h>
#import "UITableViewCell+TDApp.h"

@interface TranslateHistoryCell ()

@property (nonatomic) UILongPressGestureRecognizer *longPressRecognizer;

@end

@implementation TranslateHistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self configureViews];
    }
    return self;
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

- (void)configureViews {
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.backgroundColor = [TDColorSpecs app_cellColor];
    
    [self textLabelConfigureDefault];
    self.imageView.image = nil;
    
    [self addGestureRecognizer:self.longPressRecognizer];
}

- (void)setInputText:(NSString *)inputText {
    _inputText = [inputText copy];
    self.textLabel.text = inputText;
}

- (void)setStarred:(BOOL)starred {
    _starred = starred;
    self.imageView.image = starred?[[UIImage imageNamed:@"list_item_ic"] imageByTintColor:[TDColorSpecs remindColor]]:nil;
}

@end
