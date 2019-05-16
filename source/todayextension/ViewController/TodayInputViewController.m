//
//  TodayInputViewController.m
//  todayextension
//
//  Created by 彭光波 on 2018/5/6.
//  Copyright © 2018年 bool. All rights reserved.
//

#import "TodayInputViewController.h"
#import <TDKit/TDKit.h>

@interface TodayInputViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UILabel *toInputTipLabel;
@property (nonatomic, weak) IBOutlet UIView *tapToExitPageAreaView;

@end

@implementation TodayInputViewController

- (instancetype)init {
    self = [[UIStoryboard storyboardWithName:@"ViewControllers" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TodayInputViewController class])];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _textField.placeholder = NSLocalizedStringFromTable(@"Enter text for translation...", @"todayextension", nil);
    
    _toInputTipLabel.text = NSLocalizedStringFromTable(@"Click input field to begin input text", @"todayextension", nil);
    
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.spellCheckingType = UITextSpellCheckingTypeNo;
    _textField.returnKeyType = UIReturnKeySearch;
    _textField.font = [TDFontSpecs regularBold];
    _textField.textColor = [TDColorSpecs wd_tint];
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.placeholder = NSLocalizedStringFromTable(@"Input...", @"todayextension", nil);
    _textField.delegate = self;
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    _tapToExitPageAreaView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.001];
    _tapToExitPageAreaView.userInteractionEnabled = YES;
    [_tapToExitPageAreaView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toExitPage:)]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString *)inputText
{
    return _textField.text;
}

- (void)clearInputText {
    _textField.text = nil;
}

- (BOOL)textFieldBecomeFirstResponder {
    return [_textField becomeFirstResponder];
}

- (BOOL)textFieldResignFirstResponder {
    return [_textField resignFirstResponder];
}

- (void)toExitPage:(UITapGestureRecognizer *)sender {
    [self resignFirstResponder];
    if (self.toExitPageBlock) {
        self.toExitPageBlock(self);
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.finishInputBlock) {
        [self resignFirstResponder];
        self.finishInputBlock(self, textField.text);
        return NO;
    }
    return YES;
}

- (void)textFieldDidChange:(id)sender {
    if (self.inputingBlock) {
        self.inputingBlock(self, _textField.text);
    }
}

@end
