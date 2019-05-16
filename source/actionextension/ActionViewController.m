//
//  ActionViewController.m
//  actionextension
//
//  Created by guangbool on 2017/7/13.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <TDKit/TDKit.h>
#import <TDKit/UITraitCollection+Preference.h>

static const CGFloat ActionExtensionPageCloseThreshold = 80.f;

@interface ActionViewController () <UIScrollViewDelegate>

@property (nonatomic, copy) NSString *inputText;

@property (nonatomic) TranslateResultToolBar *translateResultBar;
@property (nonatomic) UIScrollView *resultScrollView;
@property (nonatomic) UITextView *resultInputDisplayTextView;
@property (nonatomic) UITextView *resultOutputDisplayTextView;
@property (nonatomic) UIButton *closeButn;
@property (nonatomic) UIView *blankBarItemCustomView;
    
@property (nonatomic) TodayDataController0012 *dataController;
@property (nonatomic) BOOL isTranslating;

@property (nonatomic, copy) NSString *translateId;
@property (nonatomic) TDTranslateStoreItem *storeInfo;
@property (nonatomic) BOOL isStarred;

@property (nonatomic, copy) NSArray<NSNumber *> *translateOutputLanguageList;
@property (nonatomic) NSUInteger currenOutputLanguageIndex;

@end

@implementation ActionViewController

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

- (UIScrollView *)resultScrollView {
    if (!_resultScrollView) {
        _resultScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _resultScrollView.backgroundColor = [UIColor whiteColor];
        _resultScrollView.showsHorizontalScrollIndicator = NO;
        _resultScrollView.delegate = self;
        _resultScrollView.alwaysBounceVertical = YES;
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
    NSString *inputText = [self.inputText stringByTrim];
    if (inputText.length == 0) return;
    
    [self.translateResultBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    self.translateResultBar.alpha = 0;
    [self.view layoutIfNeeded];
    [self textView:self.resultOutputDisplayTextView setText:nil textColor:[TDColorSpecs app_mainTextColor]];
    
    __weak typeof(self)weakSelf = self;
    [self translateForInput:inputText completeHandler:^{
        if (!weakSelf) return;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.translateResultBar mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo([TDHeight app_bottomBarHeight]);
            }];
            [weakSelf.view layoutIfNeeded];
            weakSelf.translateResultBar.alpha = 1;
        } completion:nil];
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
            
            TodayTranslateCheckExistResponse *checkResp = [weakSelf loadExistTranslateWithId:resp.translateId];
            
            weakSelf.translateId = resp.translateId;
            weakSelf.storeInfo = checkResp.existItemInHistory?:checkResp.existItemInStarred;
            weakSelf.isStarred = checkResp.existItemInStarred?YES:NO;
            
            [weakSelf displayCurrentTranslateLanguage];
            [weakSelf displayStarredState];
            
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

- (void)toggleStarred {
    if (!self.storeInfo) return;
    
    NSString *translateId = self.translateId;
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
}

- (void)copyy {
    if (!self.translateId || !self.storeInfo) return;
    
    NSString *currentTranslateOutput = [self currentOutputLanguageTranslateResult].output;
    if (currentTranslateOutput.length != 0) {
        [[UIPasteboard generalPasteboard] setString:currentTranslateOutput];
        
        // 记录该次拷贝的翻译结果，防止反向翻译
        [self.dataController setLastCopiedTranslate:({
            TodayCopiedTranslateMeta *meta = [TodayCopiedTranslateMeta new];
            meta.translateId = self.translateId;
            meta.copiedString = currentTranslateOutput;
            meta;
        })];
        
        // 顺序更新到第一
        [self.dataController updateOrderToFirst:self.translateId];
    }
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
}

- (void)share {
    if (!self.translateId) return;
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    [self openURL:TDSharePageURLComposer(self.translateId, [self currentOutputLanguage])];
    [self closePage];
}

- (void)moveToTrash {
    if (!self.translateId) return;
    
    NSString *translateId = self.translateId;
    [self.dataController moveToTrashWithRequest:^TodayTranslateMoveToTrashRequest *{
        TodayTranslateMoveToTrashRequest *info = [[TodayTranslateMoveToTrashRequest alloc] init];
        info.translateId = translateId;
        info.deleteExistInHistory = YES;
        info.deleteExistInStarred = YES;
        return info;
    }];
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    [self closePage];
}

/**
 Parse input text.

 @param handler handler
 @return Whether has ability to parse input text
 */
- (BOOL)parseInputText:(void(^)(NSString *inputText))handler {
    
    BOOL textFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            NSString *typeIdentifier = nil;
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]) {
                typeIdentifier = (NSString *)kUTTypeText;
            } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePlainText]) {
                typeIdentifier = (NSString *)kUTTypePlainText;
            }
            
            if (typeIdentifier) {
                // This is an text. We'll load it, then place it in our image view.
                [itemProvider loadItemForTypeIdentifier:typeIdentifier options:nil completionHandler:^(NSString *text, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (handler) handler(text);
                    });
                }];
                
                textFound = YES;
                break;
            }
        }
        
        if (textFound) {
            // We only handle one image, so stop looking for more.
            break;
        }
    }
    return textFound;
}

    
- (void)closePage {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.translateOutputLanguageList = [TDPrefs shared].preferredTranslateOutputLanguageList?:TDDefaultValue_preferredTranslateOutputLanguageList();
    self.currenOutputLanguageIndex = 0;
    
    self.navigationItem.title = @"TINY TRANSLATOR";
    
    UIImage *closeImg = [UIImage imageNamed:@"close_ic"];
    self.blankBarItemCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, closeImg.size.width, closeImg.size.height)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.blankBarItemCustomView];
    
    self.closeButn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButn setImage:[closeImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.closeButn setTintColor:[TDColorSpecs app_tint]];
    [self.closeButn addTarget:self action:@selector(closePage) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.view addSubview:self.closeButn];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.resultScrollView];
    [self.resultScrollView addSubview:self.resultInputDisplayTextView];
    [self.resultScrollView addSubview:self.resultOutputDisplayTextView];
    
    [self.view addSubview:self.translateResultBar];
    
    __weak typeof(self)weakSelf = self;
    
    [self.resultScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.mas_topLayoutGuide);
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
    
    [self displayCurrentTranslateLanguage];
    [self displayStarredState];
    [self updateLayoutOfResultScrollContentViews];
    
    [self parseInputText:^(NSString *inputText) {
        // Parsed input text
        // Configure views
        if (!weakSelf) return;
        weakSelf.inputText = inputText;
        
        // 存在初始需要翻译的文字，马上进行翻译
        if (weakSelf.inputText.length > 0) {
            [self textView:self.resultInputDisplayTextView
                   setText:weakSelf.inputText
                 textColor:[TDColorSpecs app_mainTextColor]];
            [self actionTranslate];
        }
        
    }];
    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.closeButn.frame = [self.navigationController.view convertRect:self.blankBarItemCustomView.bounds fromView:self.blankBarItemCustomView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat dragGap = (contentOffset.y + scrollView.contentInset.top);
    BOOL dragging = scrollView.isDragging;
    CGFloat rotateGap = dragGap;
    if (rotateGap > 0) {
        rotateGap = 0;
    } else if (rotateGap < -ActionExtensionPageCloseThreshold) {
        rotateGap = -ActionExtensionPageCloseThreshold;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation((M_PI/4)*((-rotateGap)/ActionExtensionPageCloseThreshold));
    [self.closeButn setTransform:transform];
    
    if (!dragging) {
        if (dragGap < -ActionExtensionPageCloseThreshold) {
            scrollView.delegate = nil;
            [scrollView setContentOffset:contentOffset];
            [self closePage];
        }
    }
}

@end
