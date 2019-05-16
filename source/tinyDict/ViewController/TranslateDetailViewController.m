//
//  TranslateDetailViewController.m
//  tinyDict
//
//  Created by guangbool on 2017/5/4.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TranslateDetailViewController.h"
#import <TDKit/TDKit.h>
#import <UITextView+Placeholder/UITextView+Placeholder.h>
#import <YYKeyboardManager/YYKeyboardManager.h>
#import <Aspects/Aspects.h>
#import "TranslateBottomBar.h"
#import "TranslateDetailPreferencePanel.h"
#import "TDOverlayDrawAnimation.h"
#import "ShareEditViewController.h"

@interface TranslateDetailViewController () <UITextViewDelegate, YYKeyboardObserver>

@property (nonatomic) TranslateResultToolBar *translateResultBar;
@property (nonatomic) TranslateBottomBar *translateBottomBar;
@property (nonatomic) UIBarButtonItem *menuRightNavItem;
@property (nonatomic) UIView *preferencePanelOverlayView;
@property (nonatomic) TranslateDetailPreferencePanel *preferencePanel;

@property (nonatomic) UIView *resultBodyView;
@property (nonatomic) UITextView *inputTextView;
@property (nonatomic) UIScrollView *resultScrollView;
@property (nonatomic) UITextView *resultInputDisplayTextView;
@property (nonatomic) UITextView *resultOutputDisplayTextView;
@property (nonatomic) UITapGestureRecognizer *resultInputDisplayTextViewTap;

@property (nonatomic) BOOL inputable;

@property (nonatomic) TodayDataController0012 *dataController;
@property (nonatomic) TDTranslateStoreItem *storeInfo;
@property (nonatomic) BOOL isStarred;
@property (nonatomic) BOOL isTranslating;
// 上一次翻译的 translate id
@property (nonatomic, copy) NSString *lastTimeTranslateId;

@property (nonatomic, copy) NSArray<NSNumber *> *translateOutputLanguageList;
@property (nonatomic) NSUInteger currenOutputLanguageIndex;

@end

@implementation TranslateDetailViewController

- (instancetype)init {
    return [self initWithItemTranslateId:nil];
}

- (instancetype)initWithItemTranslateId:(NSString *)translateId {
    if (self = [super init]) {
        _itemTranslateId = [translateId copy];
    }
    return self;
}

- (instancetype)initWithInitialInputText:(NSString *)initialInputText {
    if (self = [super init]) {
        _initialInputText = [initialInputText copy];
    }
    return self;
}

- (TranslateResultToolBar *)translateResultBar {
    if (!_translateResultBar) {
        __weak typeof(self)weakSelf = self;
        _translateResultBar = [TranslateResultToolBar fromNibWithOutputLanguages:({
            NSArray<NSNumber *> *preferredLangs = weakSelf.translateOutputLanguageList;
            NSMutableArray<NSString *> *langTexts = [NSMutableArray<NSString *> array];
            for (NSNumber *langNum in preferredLangs) {
                NSString *langKey = TDLanguageShortLocalizedKeyForType([langNum integerValue]);
                [langTexts addObject:NSLocalizedStringFromTable(langKey, @"TDBundle", nil)];
            }
            langTexts;
        })];
        _translateResultBar.clipsToBounds = YES;
        
        _translateResultBar.isItemStarred = self.isStarred;
        
        _translateResultBar.outputLanguageItemSelectionBlock = ^(TranslateResultToolBar *bar, NSInteger selectionIndex){
            [weakSelf selectOutputLanguageAtIndex:selectionIndex];
        };
        
        _translateResultBar.starOperateItemClickBlock = ^(TranslateResultToolBar *bar){
            [weakSelf toggleStarred];
        };
        
        _translateResultBar.shareOperateItemClickBlock = ^(TranslateResultToolBar *bar){
            [weakSelf share];
        };
        
        _translateResultBar.copyyOperateItemClickBlock = ^(TranslateResultToolBar *bar){
            [weakSelf copyy];
        };
        
        _translateResultBar.trashOperateItemClickBlock = ^(TranslateResultToolBar *bar){
            [weakSelf moveToTrash];
        };
        
        [_translateResultBar setLayerShadow:[UIColor blackColor] offset:CGSizeMake(0, 3) radius:3];
    }
    return _translateResultBar;
}

- (TranslateBottomBar *)translateBottomBar {
    if (!_translateBottomBar) {
        _translateBottomBar = [[TranslateBottomBar alloc] initWithFrame:CGRectMake(0, 0, 320, [TDHeight app_bottomBarHeight])];
        [_translateBottomBar setLayerShadow:[UIColor blackColor] offset:CGSizeMake(0, 3) radius:3];
        
        __weak typeof(self)weakSelf = self;
        _translateBottomBar.translateHandler = ^(TranslateBottomBar *bar){
            [weakSelf actionTranslate];
        };
        _translateBottomBar.cancelHandler = ^(TranslateBottomBar *bar){
            if (!weakSelf) return;
            [weakSelf.inputTextView resignFirstResponder];
            if (weakSelf.storeInfo) {
                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                [UIView animateWithDuration:0.3 animations:^{
                    self.resultBodyView.alpha = 1;
                    weakSelf.inputTextView.alpha = 0;
                } completion:^(BOOL finished) {
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }];
            }
        };
    }
    return _translateBottomBar;
}

- (UITextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[UITextView alloc] init];
        _inputTextView.backgroundColor = [UIColor whiteColor];
        _inputTextView.textContainer.lineFragmentPadding = 0;
        _inputTextView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
        _inputTextView.font = [TDFontSpecs large];
        _inputTextView.textColor = [TDColorSpecs app_mainTextColor];
        _inputTextView.editable = YES;
        _inputTextView.scrollEnabled = YES;
        _inputTextView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
        _inputTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        _inputTextView.spellCheckingType = UITextSpellCheckingTypeNo;
        _inputTextView.enablesReturnKeyAutomatically = YES;
        _inputTextView.placeholder = NSLocalizedStringFromTable(@"Input words to translate...", @"TinyT", nil);
        _inputTextView.placeholderColor = [TDColorSpecs app_minorTextColor];
        _inputTextView.delegate = self;
        _inputTextView.inputAccessoryView = self.translateBottomBar;
        [self adjustCaretRectForTextView:_inputTextView font:_inputTextView.font];
    }
    return _inputTextView;
}

- (void)adjustCaretRectForTextView:(UITextView *)textView font:(UIFont *)font {
    CGFloat fontLineHeight = font.lineHeight;
    [textView aspect_hookSelector:@selector(caretRectForPosition:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
        NSInvocation *invocation = aspectInfo.originalInvocation;
        
        CGRect originalRect;
        [invocation invoke];
        [invocation getReturnValue:&originalRect];
        
        CGRect result = originalRect;
        result.size.height = fontLineHeight;
        [invocation setReturnValue:&result];
        
    } error:nil];
}

- (UIView *)resultBodyView {
    if (!_resultBodyView) {
        _resultBodyView = [[UIView alloc]init];
        _resultBodyView.clipsToBounds = YES;
    }
    return _resultBodyView;
}

- (UIScrollView *)resultScrollView {
    if (!_resultScrollView) {
        _resultScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _resultScrollView.backgroundColor = [UIColor whiteColor];
        _resultScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _resultScrollView;
}

- (UITextView *)resultInputDisplayTextView {
    if (!_resultInputDisplayTextView) {
        _resultInputDisplayTextView = [[UITextView alloc] init];
        _resultInputDisplayTextView.backgroundColor = [UIColor whiteColor];
        _resultInputDisplayTextView.textContainer.lineFragmentPadding = 0;
        _resultInputDisplayTextView.textContainerInset = UIEdgeInsetsMake(24, 20, 16, 20);
        _resultInputDisplayTextView.font = [TDFontSpecs large];
        _resultInputDisplayTextView.textColor = [TDColorSpecs app_mainTextColor];
        _resultInputDisplayTextView.editable = NO;
        _resultInputDisplayTextView.scrollEnabled = NO;
    }
    return _resultInputDisplayTextView;
}

- (UITextView *)resultOutputDisplayTextView {
    if (!_resultOutputDisplayTextView) {
        _resultOutputDisplayTextView = [[UITextView alloc] init];
        _resultOutputDisplayTextView.backgroundColor = [UIColor whiteColor];
        _resultOutputDisplayTextView.textContainer.lineFragmentPadding = 0;
        _resultOutputDisplayTextView.textContainerInset = UIEdgeInsetsMake(0, 20, 20, 20);
        _resultOutputDisplayTextView.font = [TDFontSpecs large];
        _resultOutputDisplayTextView.textColor = [TDColorSpecs app_mainTextColor];
        _resultOutputDisplayTextView.editable = NO;
        _resultOutputDisplayTextView.scrollEnabled = NO;
    }
    return _resultOutputDisplayTextView;
}

- (UIBarButtonItem *)menuRightNavItem {
    if (!_menuRightNavItem) {
        _menuRightNavItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_ic"] style:UIBarButtonItemStylePlain target:self action:@selector(showTranslateSettingPanel)];
    }
    return _menuRightNavItem;
}

- (UIView *)preferencePanelOverlayView {
    if (!_preferencePanelOverlayView) {
        _preferencePanelOverlayView = [UIControl new];
        _preferencePanelOverlayView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        [((UIControl *)_preferencePanelOverlayView) addTarget:self action:@selector(hideTranslateSettingPanel) forControlEvents:UIControlEventTouchDown];
    }
    return _preferencePanelOverlayView;
}

- (TranslateDetailPreferencePanel *)preferencePanel {
    if (!_preferencePanel) {
        _preferencePanel = [[TranslateDetailPreferencePanel alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_preferencePanel setLayerShadow:[UIColor blackColor] offset:CGSizeMake(0, -1) radius:2];
        _preferencePanel.selectOption = [self preferredCopyOption];
        _preferencePanel.onlySaveLastTranslateOn = [self onlySaveLastTranslateInThisPage];
        _preferencePanel.onlySaveLastTranslateToggleBlock = ^(UIView *panel, BOOL isOn){
            [TDPrefs shared].onlySaveLastTranslateInAppTranslatePage = @(isOn);
        };
        _preferencePanel.preferredCopyOptionSelectionBlock = ^(UIView *panel, TDAppTranslateCopyOptionPreference selectedOption){
            [TDPrefs shared].preferredTranslateCopyOptionInAppTranslatePage = @(selectedOption);
        };
    }
    return _preferencePanel;
}

- (CGFloat)preferencePanelTopSpacing {
    CGFloat topSpacing = 0;
    if (self.navigationController.navigationBar.isTranslucent) {
        topSpacing = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + CGRectGetHeight(self.navigationController.navigationBar.frame);
    }
    return topSpacing;
}

- (CGSize)preferencePanelAnimationContainerSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return CGSizeMake(screenSize.width, screenSize.height - [self preferencePanelTopSpacing]);
}

- (void)textView:(UITextView *)textView
         setText:(NSString *)text
       textColor:(nonnull UIColor *)textColor {
    if (text.length == 0) {
        // set paragraph style first if text is empty
        textView.attributedText = [[self class] createTextViewAttributedTextWithSource:@" "
                                                                             textColor:textColor];
        textView.attributedText = [[self class] createTextViewAttributedTextWithSource:@""
                                                                             textColor:textColor];
    } else {
        textView.attributedText = [[self class] createTextViewAttributedTextWithSource:text
                                                                             textColor:textColor];
    }
}

+ (NSAttributedString *)createTextViewAttributedTextWithSource:(NSString *)sourceText
                                                     textColor:(nonnull UIColor *)textColor {
    if (!sourceText) return nil;
    static dispatch_once_t onceToken;
    static NSMutableDictionary *attrs = nil;
    dispatch_once(&onceToken, ^{
        attrs = [NSMutableDictionary dictionary];
        attrs[NSFontAttributeName] = [TDFontSpecs large];
        attrs[NSParagraphStyleAttributeName] = ({
            NSMutableParagraphStyle *info = [[NSMutableParagraphStyle alloc] init];
            info.lineSpacing = 10;
            info.paragraphSpacing = 0;
            info;
        });
    });
    attrs[NSForegroundColorAttributeName] = textColor;
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:sourceText attributes:attrs];
    return attributed;
}

- (TodayDataController0012 *)dataController {
    if (!_dataController) {
        _dataController = [[TodayDataController0012 alloc] init];
    }
    return _dataController;
}

- (void)showTranslateSettingPanel {
    
    [_inputTextView resignFirstResponder];
    
    
    // show panel
    
    if (!self.preferencePanelOverlayView.superview) {
        [self.view addSubview:self.preferencePanelOverlayView];
    }
    CGFloat panelTopSpacing = [self preferencePanelTopSpacing];
    [self.preferencePanelOverlayView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(panelTopSpacing);
        make.leading.and.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.view bringSubviewToFront:self.preferencePanelOverlayView];
    
    if (!self.preferencePanel.superview) {
        [self.preferencePanelOverlayView addSubview:self.preferencePanel];
    }
    self.preferencePanel.maxIntrinsicContentHeight = CGRectGetHeight([UIScreen mainScreen].bounds) - panelTopSpacing;
    [self.preferencePanel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.and.trailing.mas_equalTo(0);
    }];
    
    [self.view layoutIfNeeded];
    
    // Store interactivePopGestureRecognizer state
    [self setAssociateValue:@(self.navigationController.interactivePopGestureRecognizer.enabled) withKey:@"interactivePopGestureRecognizerEnabledBeforeShowPanel"];
    
    TDOverlayDrawAnimation *drawAnimation = [[TDOverlayDrawAnimation alloc] init];
    drawAnimation.drawStyle = TDOverlayDrawAnimationDrawFromTop;
    drawAnimation.drawView = self.preferencePanel;
    drawAnimation.overlayBackgroudView = self.preferencePanelOverlayView;
    drawAnimation.animationContainerSize = [self preferencePanelAnimationContainerSize];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [drawAnimation animate:({
        TDOverlayDrawAnimationContext *ctx = [TDOverlayDrawAnimationContext new];
        ctx.fromVisible = NO;
        ctx.toVisible = YES;
        ctx.duration = 0.3;
        ctx.animationFinishedHandler = ^(BOOL finished, BOOL fromVisible, BOOL toVisible){
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            self.navigationItem.title = NSLocalizedStringFromTable(@"Preferences", @"TinyT", nil);
            self.navigationItem.rightBarButtonItem
                = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close_ic"]
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(hideTranslateSettingPanel)];
            [self.navigationItem setHidesBackButton:YES];
            // Set interactivePopGestureRecognizer disabled
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        };
        ctx;
    })];
}

- (void)hideTranslateSettingPanel {
    
    if (!_preferencePanel && !_preferencePanelOverlayView) {
        return;
    }
    
    TDOverlayDrawAnimation *drawAnimation = [[TDOverlayDrawAnimation alloc] init];
    drawAnimation.drawStyle = TDOverlayDrawAnimationDrawFromTop;
    drawAnimation.drawView = _preferencePanel;
    drawAnimation.overlayBackgroudView = _preferencePanelOverlayView;
    drawAnimation.animationContainerSize = [self preferencePanelAnimationContainerSize];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [drawAnimation animate:({
        TDOverlayDrawAnimationContext *ctx = [TDOverlayDrawAnimationContext new];
        ctx.fromVisible = YES;
        ctx.toVisible = NO;
        ctx.duration = 0.3;
        ctx.animationFinishedHandler = ^(BOOL finished, BOOL fromVisible, BOOL toVisible){
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            self.navigationItem.title = [self navTitle];
            self.navigationItem.rightBarButtonItem = self.menuRightNavItem;
            [self.navigationItem setHidesBackButton:NO];
            
            // Restore interactivePopGestureRecognizer state
            self.navigationController.interactivePopGestureRecognizer.enabled = ((NSNumber *)[self getAssociatedValueForKey:@"interactivePopGestureRecognizerEnabledBeforeShowPanel"]).boolValue;
        };
        ctx;
    })];
}

- (void)tapResultInputDisplayLabel:(id)sender {
    // 显示输入框，隐藏结果视图
    if (!self.inputable) return;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.3 animations:^{
        self.resultBodyView.alpha = 0;
        self.inputTextView.alpha = 1;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
    [self.inputTextView becomeFirstResponder];
}

- (NSString *)navTitle {
    return NSLocalizedStringFromTable(self.inputable?@"Translate":@"Translate Detail", @"TinyT", nil);
}

- (TDTranslateResultStoreItem *)currentOutputLanguageTranslateResult {
    
    if (self.translateOutputLanguageList.count <= self.currenOutputLanguageIndex) {
        return nil;
    }
    
    TDTextTranslateLanguage currentOutputLang = [self.translateOutputLanguageList[self.currenOutputLanguageIndex] integerValue];
    return [self.storeInfo translateResultForOutputLang:currentOutputLang];
}

- (TDTextTranslateLanguage)currentOutputLanguage {
    if (self.translateOutputLanguageList.count <= self.currenOutputLanguageIndex) {
        return TDTextTranslateLanguage_unkown;
    }
    
    NSNumber *currentLangNumber = self.translateOutputLanguageList[self.currenOutputLanguageIndex];
    return [currentLangNumber integerValue];
}

- (CGFloat)heightOfResultInputDisplayTextView {
    CGFloat h = 0;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    h = [_resultInputDisplayTextView sizeThatFits:screenSize].height;
    return h;
}

- (CGFloat)heightOfResultOutputDisplayTextView {
    CGFloat h = 0;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    h = [_resultOutputDisplayTextView sizeThatFits:screenSize].height;
    return h;
}

- (CGSize)contentSizeOfResultScrollView {
    CGFloat h = 0;
    h += [self heightOfResultInputDisplayTextView];
    h += [self heightOfResultOutputDisplayTextView];
    return CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), h);
}

- (void)updateLayoutOfResultScrollContentViews {
    __weak typeof(self)weakSelf = self;
    [_resultInputDisplayTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([weakSelf heightOfResultInputDisplayTextView]);
    }];
    
    [_resultOutputDisplayTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([weakSelf heightOfResultOutputDisplayTextView]);
    }];
    
    [self updateScrollViewContentSize];
}

- (void)updateScrollViewContentSize {
    _resultScrollView.contentSize = [self contentSizeOfResultScrollView];
}

- (void)resultScrollViewScrollToBottomWithAnimated:(BOOL)animated {
    CGSize scrollContentSize = _resultScrollView.contentSize;
    [_resultScrollView scrollRectToVisible:CGRectMake(scrollContentSize.width - 1, scrollContentSize.height - 1, 1, 1) animated:animated];
}

- (void)resultScrollViewScrollToOutputDisplayTextViewTopWithAnimated:(BOOL)animated {
    CGPoint outputTextViewOrigin = [_resultOutputDisplayTextView convertPoint:CGPointZero toView:_resultScrollView];
    [_resultScrollView scrollRectToVisible:CGRectMake(-1, outputTextViewOrigin.y-1, 1, 1) animated:animated];
    
    CGSize scrollContentSize = _resultScrollView.contentSize;
    [_resultScrollView scrollRectToVisible:CGRectMake(scrollContentSize.width - 1, scrollContentSize.height - 1, 1, 1) animated:animated];
}

- (void)displayCurrentTranslateLanguage {
    [_translateResultBar setSelectionOutputLanguageIndex:[self currenOutputLanguageIndex]];
}

- (void)displayStarredState {
    [_translateResultBar setItemStarred:self.isStarred];
}

- (void)actionTranslate {
    NSString *inputText = [_inputTextView.attributedText.string stringByTrim];
    
    [self.view endEditing:YES];
    
    if (inputText.length == 0) {
        return;
    }
    
    [self.translateResultBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    [self.view layoutIfNeeded];
    [self textView:self.resultOutputDisplayTextView setText:nil textColor:[TDColorSpecs app_mainTextColor]];
    [UIView animateWithDuration:0.3 animations:^{
        self.inputTextView.alpha = 0;
        self.resultBodyView.alpha = 1;
        self.resultScrollView.alpha = 1;
    } completion:^(BOOL finished) {
        self.resultInputDisplayTextViewTap.enabled = NO;
        __weak typeof(self)weakSelf = self;
        [self translateForInput:inputText completeHandler:^{
            if (!weakSelf) return;
            
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.translateResultBar.alpha = 1;
                weakSelf.resultOutputDisplayTextView.alpha = 1;
                [weakSelf.translateResultBar mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo([TDHeight app_bottomBarHeight]);
                }];
                [weakSelf.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                weakSelf.resultInputDisplayTextViewTap.enabled = YES;
            }];
        }];
    }];
}

- (TDAppTranslateCopyOptionPreference)preferredCopyOption {
    NSNumber *val = [TDPrefs shared].preferredTranslateCopyOptionInAppTranslatePage;
    if (val) {
        return [val integerValue];
    }
    return TDAppDefaultValue_preferredTranslateCopyOptionInTranslatePage;
}

- (BOOL)onlySaveLastTranslateInThisPage {
    NSNumber *val = [TDPrefs shared].onlySaveLastTranslateInAppTranslatePage;
    if (val) {
        return [val boolValue];
    }
    return TDAppDefaultValue_onlySaveLastTranslateInTranslatePage;
}

- (void)removeLastTimeTranslateInThisPageAfterNewTranslateWithId:(NSString *)newTranslateWithId {
    if (!newTranslateWithId) return;
    if (!self.lastTimeTranslateId) return;
    if (![self onlySaveLastTranslateInThisPage]) return;
    
    if ([newTranslateWithId isEqualToString:self.lastTimeTranslateId]) {
        // 忽略当前翻译和上一次相同的翻译
        return;
    }
    
    // clear last translate
    TodayTranslateMoveToTrashRequest *removeReq = [TodayTranslateMoveToTrashRequest new];
    removeReq.translateId = self.lastTimeTranslateId;
    removeReq.deleteExistInHistory = YES;
    removeReq.deleteExistInStarred = YES;
    removeReq.disrestorable = YES;
    [self.dataController moveToTrashWithRequest:^TodayTranslateMoveToTrashRequest *{
        return removeReq;
    }];
    
}

- (void)translateForInput:(NSString *)inputText completeHandler:(void(^)())completeHandler {

    if (self.isTranslating)
        return;
    
    self.isTranslating = YES;
    [self textView:self.resultInputDisplayTextView
           setText:inputText
         textColor:[TDColorSpecs app_mainTextColor]];
    [self textView:self.resultOutputDisplayTextView
           setText:NSLocalizedStringFromTable(@"Translating...", @"TDBundle", nil)
         textColor:[TDColorSpecs app_minorTextColor]];
    [self updateLayoutOfResultScrollContentViews];
    [self resultScrollViewScrollToBottomWithAnimated:NO];
    
    __weak typeof(self)weakSelf = self;
    [self.dataController translateForInput:inputText destLanguage:[self currentOutputLanguage] completeHandler:^(TodayTranslateResponse *resp, NSError *error) {
        if (!weakSelf) return;
        weakSelf.isTranslating = NO;
        
        if (error || !resp || !resp.translateId) {
            // 出错
            [weakSelf textView:weakSelf.resultOutputDisplayTextView
                       setText:NSLocalizedStringFromTable(@"Sorry, can't translate it!", @"TDBundle", nil)
                     textColor:[TDColorSpecs app_minorTextColor]];
            [weakSelf updateLayoutOfResultScrollContentViews];
            
        } else {
            [weakSelf removeLastTimeTranslateInThisPageAfterNewTranslateWithId:resp.translateId];
            // alter `lastTimeTranslateId`
            weakSelf.lastTimeTranslateId = resp.translateId;
            
            if (weakSelf.storeInfo.input && [weakSelf.storeInfo.input isEqualToString:inputText]) {
                TDTranslateResultStoreItem *newTranslateResult = [[TDTranslateResultStoreItem alloc] initWithTranslateItem:resp.result];
                newTranslateResult.providerName = resp.providerName;
                NSMutableArray *newTranslateResults = [NSMutableArray array];
                
                NSArray<TDTranslateResultStoreItem *> *originItems = weakSelf.storeInfo.translateResults;
                if (originItems) {
                    [newTranslateResults addObjectsFromArray:originItems];
                
                    for (TDTranslateResultStoreItem *rmitem in originItems) {
                        if(rmitem.outputLang == newTranslateResult.outputLang) {
                            [newTranslateResults removeObject:rmitem];
                        }
                    }
                }
                [newTranslateResults addObject:newTranslateResult];
                
                weakSelf.storeInfo.translateResults = newTranslateResults;
            } else {
                TodayTranslateCheckExistResponse *checkResp = [weakSelf loadExistTranslateWithId:resp.translateId];
                weakSelf.storeInfo = checkResp.existItemInHistory?:checkResp.existItemInStarred;
                weakSelf.isStarred = checkResp.existItemInStarred?YES:NO;
                [weakSelf displayCurrentTranslateLanguage];
                [weakSelf displayStarredState];
            }
            
            [weakSelf textView:weakSelf.resultOutputDisplayTextView
                       setText:[weakSelf currentOutputLanguageTranslateResult].output
                     textColor:[TDColorSpecs app_mainTextColor]];
            [weakSelf updateLayoutOfResultScrollContentViews];
            [weakSelf resultScrollViewScrollToOutputDisplayTextViewTopWithAnimated:YES];
        }
        
        if (completeHandler) {
            completeHandler();
        }
    }];
}

- (TodayTranslateCheckExistResponse *)loadExistTranslateWithId:(NSString *)translateId {
    TodayTranslateCheckExistResponse *checkResp
    = [self.dataController checkExistWithRequest:^TodayTranslateCheckExistRequest *{
        TodayTranslateCheckExistRequest *info = [[TodayTranslateCheckExistRequest alloc] init];
        info.translateId = translateId;
        info.checkExistInHistory = YES;
        info.checkExistInStarred = YES;
        return info;
    }];
    return checkResp;
}

- (void)selectOutputLanguageAtIndex:(NSInteger)selectionIndex {
    if (selectionIndex == self.currenOutputLanguageIndex)
        return;
    
    BOOL navigationToNext = (selectionIndex > self.currenOutputLanguageIndex);
    
    self.currenOutputLanguageIndex = selectionIndex;
    
    CGRect scrollViewFrame = self.resultScrollView.frame;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect holder = scrollViewFrame;
        if (navigationToNext) {
            holder.origin.x -= holder.size.width;
        } else {
            holder.origin.x += holder.size.width;
        }
        self.resultScrollView.frame = holder;
        self.resultScrollView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        self.resultScrollView.frame = scrollViewFrame;
        [self textView:self.resultOutputDisplayTextView
               setText:[self currentOutputLanguageTranslateResult].output
             textColor:[TDColorSpecs app_mainTextColor]];
        [self updateLayoutOfResultScrollContentViews];
        [self resultScrollViewScrollToOutputDisplayTextViewTopWithAnimated:NO];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.resultScrollView.alpha = 1;
        } completion:^(BOOL finished) {
            [self didSelectedOutputLanguage];
        }];
    }];
}

- (void)didSelectedOutputLanguage {
    TDTranslateResultStoreItem *existLangStoreItem = [self currentOutputLanguageTranslateResult];
    if (existLangStoreItem) {
        [self textView:self.resultOutputDisplayTextView
               setText:existLangStoreItem.output
             textColor:[TDColorSpecs app_mainTextColor]];
        [self updateLayoutOfResultScrollContentViews];
        [self resultScrollViewScrollToOutputDisplayTextViewTopWithAnimated:YES];
    } else {
        NSString *inputText = self.storeInfo.input;
        if (inputText.length == 0)
            return;
        [self translateForInput:inputText completeHandler:nil];
    }
}

- (NSString *)operateTranslateId {
    return self.itemTranslateId?:self.lastTimeTranslateId;
}

- (void)toggleStarred {
    if (!self.storeInfo) return;
    
    NSString *translateId = [self operateTranslateId];
    if (!translateId) return;
    
    BOOL isToStarOrNot = !self.isStarred;
    
    [self.dataController starOrNotWithRequest:^TodayTranslateStarRequest *{
        TodayTranslateStarRequest *info = [[TodayTranslateStarRequest alloc] init];
        info.translateId = translateId;
        info.isToStarOrNot = isToStarOrNot;
        return info;
    }];
    
    self.isStarred = isToStarOrNot;
    [self displayStarredState];
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    if (self.starOrNotHandler) {
        self.starOrNotHandler(translateId, self.isStarred);
    }
}

- (void)copyy {
    
    NSString *copyString = nil;
    
    TDAppTranslateCopyOptionPreference copyOption = [self preferredCopyOption];
    switch (copyOption) {
        case TDAppTranslateCopyInputOnly:
            copyString = [self.storeInfo input];
            break;
        case TDAppTranslateCopyOutputOnly:
            copyString = [self currentOutputLanguageTranslateResult].output;
            break;
        case TDAppTranslateCopyAll: {
            NSString *input = [self.storeInfo input];
            NSString *output = [self currentOutputLanguageTranslateResult].output;
            NSMutableString *tmp = [NSMutableString string];
            if (input.length > 0) [tmp appendString:input];
            if (output.length > 0) {
                if (tmp.length > 0) [tmp appendString:@"\n"];
                [tmp appendString:output];
            }
            copyString = tmp;
            break;
        }
    }
    
    
    if (copyString.length != 0) {
        [[UIPasteboard generalPasteboard] setString:copyString];
        
        // 记录该次拷贝的翻译，防止反向翻译
        [self.dataController setLastCopiedTranslate:({
            TodayCopiedTranslateMeta *meta = [TodayCopiedTranslateMeta new];
            meta.translateId = [self operateTranslateId];
            meta.copiedString = copyString;
            meta;
        })];
        
        // 顺序更新到第一
        [self.dataController updateOrderToFirst:self.itemTranslateId];
    }
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
}

- (void)share {
    
    ShareEditViewController *shareVC = [[ShareEditViewController alloc] initWithTid:[self operateTranslateId] init_lang:[self currentOutputLanguage]];
    [self.navigationController pushViewController:shareVC animated:YES];
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
}

- (void)moveToTrash {
    
    NSString *translateId = self.itemTranslateId;
    [self.dataController moveToTrashWithRequest:^TodayTranslateMoveToTrashRequest *{
        TodayTranslateMoveToTrashRequest *info = [[TodayTranslateMoveToTrashRequest alloc] init];
        info.translateId = translateId;
        info.deleteExistInHistory = YES;
        info.deleteExistInStarred = YES;
        return info;
    }];
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    if (self.movedToTrashHandler) {
        self.movedToTrashHandler(translateId);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.itemTranslateId.length > 0) {
        TodayTranslateCheckExistResponse *checkResp = [self loadExistTranslateWithId:self.itemTranslateId];
        self.storeInfo = checkResp.existItemInHistory?:checkResp.existItemInStarred;
        self.isStarred = checkResp.existItemInStarred?YES:NO;
    }
    
    NSArray<NSNumber *> *defaultPreferredLangList = [TDPrefs shared].preferredTranslateOutputLanguageList?:TDDefaultValue_preferredTranslateOutputLanguageList();
    if (self.storeInfo) {
        self.translateOutputLanguageList = [self.storeInfo preferredOutputLanguagesOrderWithDefault:defaultPreferredLangList];
    } else {
        self.translateOutputLanguageList = defaultPreferredLangList;
    }
    self.currenOutputLanguageIndex = ({
        __block NSUInteger findIdx = 0;
        if (self.storeInfo) {
            TDTextTranslateLanguage initialDisplayLang = self.storeInfo.translateResults.firstObject.outputLang;
            
            [self.translateOutputLanguageList enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj integerValue] == initialDisplayLang) {
                    findIdx = idx;
                    *stop = YES;
                }
            }];
        }
        findIdx;
    });
    
    self.inputable = (self.storeInfo == nil);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = [self navTitle];
    self.navigationItem.rightBarButtonItem = self.menuRightNavItem;
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.inputable) {
        [self.view addSubview:self.inputTextView];
        [self textView:self.inputTextView
               setText:@""
             textColor:[TDColorSpecs app_mainTextColor]];
    } else {
        [self textView:self.resultInputDisplayTextView
               setText:self.storeInfo.input
             textColor:[TDColorSpecs app_mainTextColor]];
        [self textView:self.resultOutputDisplayTextView
               setText:[self currentOutputLanguageTranslateResult].output
             textColor:[TDColorSpecs app_mainTextColor]];
    }
    
    [self.view addSubview:self.resultBodyView];
    [self.resultBodyView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    
    [self.resultBodyView addSubview:self.resultScrollView];
    [self.resultScrollView addSubview:self.resultInputDisplayTextView];
    [self.resultScrollView addSubview:self.resultOutputDisplayTextView];
    
    if (self.inputable) {
        self.resultInputDisplayTextViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResultInputDisplayLabel:)];
        [self.resultInputDisplayTextView addGestureRecognizer:self.resultInputDisplayTextViewTap];
    }

    [self.resultBodyView addSubview:self.translateResultBar];
    
    __weak typeof(self)weakSelf = self;
    
    if (self.inputable) {
        [_inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.mas_topLayoutGuide);
            make.leading.and.trailing.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
    
    [self.resultScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.and.trailing.mas_equalTo(0);
    }];
    
    [self.resultInputDisplayTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.trailing.equalTo(weakSelf.view.mas_trailing);
        make.height.mas_equalTo([weakSelf heightOfResultInputDisplayTextView]);
    }];
    
    [self.resultOutputDisplayTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.resultInputDisplayTextView.mas_bottom);
        make.leading.mas_equalTo(0);
        make.trailing.equalTo(weakSelf.view.mas_trailing);
        make.height.mas_equalTo([weakSelf heightOfResultOutputDisplayTextView]);
    }];
    
    [self.translateResultBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.mas_equalTo(0);
        make.top.equalTo(weakSelf.resultScrollView.mas_bottom);
        make.height.mas_equalTo([TDHeight app_bottomBarHeight]);
        make.bottom.mas_equalTo(0);
    }];
    
    if (self.inputable) {
        self.resultBodyView.alpha = 0;
    }
    
    [self displayCurrentTranslateLanguage];
    [self displayStarredState];
    [self updateLayoutOfResultScrollContentViews];
    
    // 存在初始需要翻译的文字，马上进行翻译
    if (self.initialInputText.length > 0) {
        [self textView:self.inputTextView
               setText:self.initialInputText
             textColor:[TDColorSpecs app_mainTextColor]];
        [self actionTranslate];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[YYKeyboardManager defaultManager] addObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[YYKeyboardManager defaultManager] removeObserver:self];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {

    if (![textView isEqual:_inputTextView]) return;
    
    NSUInteger selectedRangeLocation = textView.selectedRange.location;
    if(selectedRangeLocation != NSNotFound ) {
        // scroll to bottom
        [textView scrollRangeToVisible:NSMakeRange(selectedRangeLocation, 0)];
    }
}

#pragma mark - YYKeyboardObserver 

- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {

    if (transition.toVisible) {
        CGRect kbFrame = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
            [_inputTextView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-CGRectGetHeight(kbFrame));
            }];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    } else if (transition.fromVisible && !transition.toVisible) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
            [_inputTextView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0);
            }];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }
}

@end
