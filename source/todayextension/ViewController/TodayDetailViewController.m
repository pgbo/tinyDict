//
//  TodayDetailViewController.m
//  tinyDict
//
//  Created by guangbool on 2017/4/10.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TodayDetailViewController.h"
#import <TDKit/TDKit.h>

const CGFloat TodayDetailBottomBarHeight = 38.f;

@interface TodayDetailViewController ()

@property (weak, nonatomic) IBOutlet UIStackView *expandedModeContentOperateItemsStackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *expandedModecontentOperateItemsStackViewWidth;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentContainerWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentContainerHeight;
@property (weak, nonatomic) IBOutlet UIView *inputContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputContainerHeight;
@property (weak, nonatomic) IBOutlet UILabel *inputDisplayLabel;
@property (weak, nonatomic) IBOutlet UIView *translateResultContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *translateResultContainerTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *translateResultContainerHeight;
@property (weak, nonatomic) IBOutlet UITextView *resultDisplayTextView;

@property (weak, nonatomic) IBOutlet UIView *bottomBarContainer;
@property (weak, nonatomic) IBOutlet UIView *compactModeContentOperateOptionsContainer;
@property (weak, nonatomic) IBOutlet UIStackView *compactModeContentOperateOptionsStackView;
@property (weak, nonatomic) IBOutlet UIView *itemOperateOptionsContainer;
@property (weak, nonatomic) IBOutlet UIStackView *itemOperateOptionsStackView;
@property (weak, nonatomic) IBOutlet UIButton *starButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *copyyButton;
@property (weak, nonatomic) IBOutlet UIButton *trashButton;
@property (weak, nonatomic) IBOutlet UIView *languageOptionsContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *languageOptionsContainerLeading;
@property (weak, nonatomic) IBOutlet UIStackView *languageOptionsStackView;
@property (weak, nonatomic) IBOutlet UIButton *navPreLangButton;
@property (weak, nonatomic) IBOutlet UILabel *currentLangDisplayLabel;
@property (weak, nonatomic) IBOutlet UIButton *navNextLangButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (nonatomic) UIButton *contentExpandButton;
@property (nonatomic) UIButton *contentPageUpButton;
@property (nonatomic) UIButton *contentPageDownButton;

@property (nonatomic) UILabel *copiedTipLabel;

@property (nonatomic) TodayDataController0012 *dataController;
@property (nonatomic) TDTranslateStoreItem *storeInfo;
@property (nonatomic) BOOL isStarred;
@property (nonatomic) BOOL isTranslating;

@property (nonatomic, copy) NSArray<NSNumber *> *translateOutputLanguageList;
@property (nonatomic) NSUInteger currenOutputLanguageIndex;


// 内容是否展开
@property (nonatomic) BOOL isContentExpanded;

@property (nonatomic) NSUInteger viewDidLayoutSubviewsCallNum;

@end

@implementation TodayDetailViewController

- (instancetype)initWithWidgetDisplayMode:(NCWidgetDisplayMode)widgetDisplayMode
                          itemTranslateId:(NSString *)translateId {
    self = [[UIStoryboard storyboardWithName:@"ViewControllers" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TodayDetailViewController class])];
    if (self) {
        _widgetDisplayMode = widgetDisplayMode;
        _itemTranslateId = [translateId copy];
    }
    return self;
}

- (TodayDataController0012 *)dataController {
    if (!_dataController) {
        _dataController = [[TodayDataController0012 alloc] init];
    }
    return _dataController;
}

+ (void)roundStyleForView:(UIView *)view {
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 4;
    view.layer.borderColor = [TDColorSpecs wd_separator].CGColor;
    view.layer.borderWidth = 0.5f;
}

- (void)cancelClick:(id)sender {
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    if (self.cancelHandler) {
        TodayTranslateHistoryItem *info = [[TodayTranslateHistoryItem alloc] init];
        info.translateId = self.itemTranslateId;
        info.item = self.storeInfo;
        info.starred = self.isStarred;
        self.cancelHandler(info);
    }
}

- (CGFloat)scrollContentWidth {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat scrollContentWidth = width - self.expandedModecontentOperateItemsStackViewWidth.constant;
    return scrollContentWidth;
}

- (CGFloat)inputDisplayLabelMaxLayoutWidth {
    CGFloat textMaxLayoutWidth = [self scrollContentWidth] - 32;
    return textMaxLayoutWidth;
}

- (void)updateScrollContentViewsConstraints {
    
    // 计算 input container 的高度
    CGFloat inputContainerHeight = 0;
    {
        BOOL needCaculateHeight = YES;
        if (self.isContentExpanded) {
            self.inputDisplayLabel.numberOfLines = 0;
        } else {
            // 收缩
            self.inputDisplayLabel.numberOfLines = 1;
            if (self.widgetDisplayMode == NCWidgetDisplayModeCompact) {
                needCaculateHeight = NO;
            }
        }
        if (needCaculateHeight) {
            inputContainerHeight = MAX(36, 8*2 + [self.inputDisplayLabel intrinsicContentSize].height);
        }
    }
    
    // 计算 result container top
    CGFloat resultContainerTop = 0;
    if (inputContainerHeight == 0) {
        resultContainerTop = 8;
    }
    
    // 计算 result container 的高度
    CGFloat resultContainerHeight = 0;
    {
        resultContainerHeight = [self.resultDisplayTextView sizeThatFits:CGSizeMake([self inputDisplayLabelMaxLayoutWidth], 0)].height;
        resultContainerHeight = MAX(20, resultContainerHeight);
    }
    
    self.inputContainerHeight.constant = inputContainerHeight;
    self.translateResultContainerTop.constant = resultContainerTop;
    self.translateResultContainerHeight.constant = resultContainerHeight;
    self.scrollContentContainerHeight.constant = (inputContainerHeight + resultContainerTop + resultContainerHeight);
    
    [self updateScrollViewContentSize];
}

- (void)updateScrollViewContentSize {
    self.scrollView.contentSize = CGSizeMake([self scrollContentWidth], self.scrollContentContainerHeight.constant);
}

- (void)toggleStarred {
    
    BOOL isToStarOrNot = !self.isStarred;
    NSString *translateId = self.itemTranslateId;
    
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

- (void)shareClick:(id)sender {
    if (self.shareHandler) {
        self.shareHandler(self.itemTranslateId, [self currentOutputLanguage], self.isStarred);
    }
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
}

- (void)copyyClick:(id)sender {
    
    if (self.isTranslating) {
        [self shakeResultDisplayTextViewAtLeft:YES right:NO];
        return;
    }
    
    NSString *currentTranslateOutput = [self currentOutputLanguageTranslateResult].output;
    if (currentTranslateOutput.length != 0) {
        [[UIPasteboard generalPasteboard] setString:currentTranslateOutput];
    
        // 记录该次拷贝的翻译结果，防止反向翻译
        [self.dataController setLastCopiedTranslate:({
            TodayCopiedTranslateMeta *meta = [TodayCopiedTranslateMeta new];
            meta.translateId = self.itemTranslateId;
            meta.copiedString = currentTranslateOutput;
            meta;
        })];
        
        // 顺序更新到第一
        [self.dataController updateOrderToFirst:self.itemTranslateId];
        
        [self toggleCopiedTipLableHiddenState];
    }
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
}

- (void)toggleCopiedTipLableHiddenState {
    
    if (!self.copiedTipLabel.superview) {
        self.copiedTipLabel.alpha = 0;
        [self.view addSubview:self.copiedTipLabel];
    }
    
    CGPoint centerAtRoot = [self.copyyButton.superview convertPoint:self.copyyButton.center toView:self.view];
    __weak typeof(self)weakSelf = self;
    [self.copiedTipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view.mas_leading).offset(centerAtRoot.x);
        make.centerY.equalTo(weakSelf.view.mas_top).offset(centerAtRoot.y);
    }];
    self.copiedTipLabel.center = centerAtRoot;
    
    BOOL labelHidden = (_copiedTipLabel.alpha == 0);
    void(^animation)() = ^{
        if (labelHidden) {
            self.copiedTipLabel.alpha = 1;
            self.copyyButton.alpha = 0;
        } else {
            self.copiedTipLabel.alpha = 0;
            self.copyyButton.alpha = 1;
        }
    };
    
    [UIView animateWithDuration:0.2
                     animations:animation
    completion:^(BOOL finished) {
        if (labelHidden) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!weakSelf) return;
                [weakSelf toggleCopiedTipLableHiddenState];
            });
        }
    }];
}

- (void)trashClick:(id)sender {
    
    NSString *translateId = self.itemTranslateId;
    [self.dataController moveToTrashWithRequest:^TodayTranslateMoveToTrashRequest *{
        TodayTranslateMoveToTrashRequest *info = [[TodayTranslateMoveToTrashRequest alloc] init];
        info.translateId = translateId;
        info.deleteExistInHistory = YES;
        info.deleteExistInStarred = YES;
        return info;
    }];
    
    if (self.movedToTrashHandler) {
        self.movedToTrashHandler(self.itemTranslateId);
    }
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
}

- (void)toggleContentExpanded {
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    CGFloat inputContainerHeight_before = self.inputContainerHeight.constant;
    
    self.isContentExpanded = !self.isContentExpanded;
    [self updateScrollContentViewsConstraints];
    
    CGFloat inputContainerHeight_after = self.inputContainerHeight.constant;
    if (inputContainerHeight_before == inputContainerHeight_after) {
        // 抖动, 展开前后也是一样的高度
        [self shakesAtTop:NO left:NO bottom:YES right:NO];
    }
    
    if (self.isContentExpanded) {
        [self.contentExpandButton setImage:[UIImage imageNamed:@"content_shrink"] forState:UIControlStateNormal];
    } else {
        [self.contentExpandButton setImage:[UIImage imageNamed:@"content_extend"] forState:UIControlStateNormal];
    }
    
}

- (CGFloat)scrollViewContentHeight {
    return self.scrollView.contentSize.height;
}

- (CGFloat)scrollViewHeight {
    CGFloat scrollViewHeight = CGRectGetHeight(self.scrollView.bounds);
    if (scrollViewHeight < 0) {
        scrollViewHeight = CGRectGetHeight(self.view.bounds) - TodayDetailBottomBarHeight;
    }
    return scrollViewHeight;
}

- (NSUInteger)scrollViewContentTotalPage {
    CGFloat scrollViewHeight = [self scrollViewHeight];
    if (scrollViewHeight < 0) {
        return 0;
    }
    return ceilf(self.scrollView.contentSize.height/scrollViewHeight);
}

- (NSUInteger)currentPageIndex {
    CGFloat scrollViewHeight = [self scrollViewHeight];
    if (scrollViewHeight < 0) {
        return 0;
    }
    return floorf(self.scrollView.contentOffset.y/scrollViewHeight);
}

- (void)pageUp:(id)sender {
    // 上翻页
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    if (contentOffset.y <= 0) {
        // 抖动,提示到顶部了
        [self shakesAtTop:YES left:NO bottom:NO right:NO];
    } else {
       
        CGFloat tarOffsetY = (contentOffset.y - [self scrollViewHeight] + 20);
        if (tarOffsetY < 0) {
            tarOffsetY = 0;
        }
        if (tarOffsetY < contentOffset.y) {
            contentOffset.y = tarOffsetY;
            [self.scrollView setContentOffset:contentOffset animated:YES];
        }
    }
}

- (void)pageDown:(id)sender {
    // 下翻页
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGFloat maxOffsetY = [self scrollViewContentHeight] - [self scrollViewHeight];
    if (maxOffsetY < 0) {
        maxOffsetY = 0;
    }
   
    if (contentOffset.y >= maxOffsetY) {
        // 抖动,提示到最后一页了
        [self shakesAtTop:NO left:NO bottom:YES right:NO];
    } else {
        CGFloat tarOffsetY = contentOffset.y + [self scrollViewHeight] - 20;
        if (tarOffsetY > maxOffsetY) {
            tarOffsetY = maxOffsetY;
        }
        contentOffset.y = tarOffsetY;
        [self.scrollView setContentOffset:contentOffset animated:YES];
    }
}


- (void)shakeResultDisplayTextViewAtLeft:(BOOL)left
                                   right:(BOOL)right {
    if (!_resultDisplayTextView) return;
    
    CGRect viewBounds = _resultDisplayTextView.bounds;
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.05
          initialSpringVelocity:20
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect animBounds = viewBounds;
                         if (left) {
                             animBounds.origin.x -= 2;
                         } else if (right) {
                             animBounds.origin.x += 2;
                         }
                         self.resultDisplayTextView.bounds = animBounds;
                     }
                     completion:^(BOOL finished) {
                         self.resultDisplayTextView.bounds = viewBounds;
                     }];
}

/**
 在某一个方向抖动

 @param top 是否在 top 抖动
 @param left 是否在 left 抖动
 @param bottom 是否在 bottom 抖动
 @param right 是否在 right 抖动
 */
- (void)shakesAtTop:(BOOL)top
               left:(BOOL)left
             bottom:(BOOL)bottom
              right:(BOOL)right {
    
    CGRect scrollViewBounds = self.scrollView.bounds;
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.05
          initialSpringVelocity:20
                        options:UIViewAnimationOptionCurveEaseInOut
    animations:^{
        CGRect animBounds = scrollViewBounds;
        if (top) {
            animBounds.origin.y -= 2;
        } else if (left) {
            animBounds.origin.x -= 2;
        } else if (bottom) {
            animBounds.origin.y += 2;
        } else if (right) {
            animBounds.origin.x += 2;
        }
        self.scrollView.bounds = animBounds;
    }
    completion:^(BOOL finished) {
        self.scrollView.bounds = scrollViewBounds;
    }];
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

- (void)displayCurrentTranslateResult {
    
    TDTranslateResultStoreItem *currentTranslateResult = [self currentOutputLanguageTranslateResult];
    [self resultDisplayTextViewDisplayNormalText:currentTranslateResult.output];
}

- (void)resultDisplayTextViewDisplayNormalText:(NSString *)normalText {
    self.resultDisplayTextView.text = normalText;
    self.resultDisplayTextView.textColor = [TDColorSpecs wd_mainTextColor];
}

- (void)resultDisplayTextViewDisplayTipText:(NSString *)tipText {
    self.resultDisplayTextView.text = tipText;
    self.resultDisplayTextView.textColor = [TDColorSpecs wd_minorTextColor];
}

- (void)displayCurrentTranslateLanguage {
    NSString *langKey = TDLanguageShortLocalizedKeyForType([self currentOutputLanguage]);
    self.currentLangDisplayLabel.text = NSLocalizedStringFromTable(langKey, @"TDBundle", nil);
}

- (void)displayStarredState {
    UIImage *ic = [UIImage imageNamed:@"star_ic"];
    if (self.isStarred) {
        ic = [ic imageByTintColor:[TDColorSpecs remindColor]];
    }
    [self.starButton setImage:ic forState:UIControlStateNormal];
}

- (void)didChangedOutputLanguageWithNavigationToNext:(BOOL)navigationToNext {
    
    TDTranslateResultStoreItem *currentTranslateResult = [self currentOutputLanguageTranslateResult];
    if (currentTranslateResult) {
        
        CGRect containerFrame = self.scrollContentContainer.frame;
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect holder = containerFrame;
            if (navigationToNext) {
                holder.origin.x -= holder.size.width;
            } else {
                holder.origin.x += holder.size.width;
            }
            self.scrollContentContainer.frame = holder;
            self.scrollContentContainer.alpha = 0;
            
        } completion:^(BOOL finished) {
            self.scrollContentContainer.frame = containerFrame;
            [self.scrollView setContentOffset:CGPointZero animated:NO];
            [self displayCurrentTranslateResult];
            [self displayCurrentTranslateLanguage];
            if (self.isContentExpanded) {
                [self toggleContentExpanded];
            }
            [self updateScrollContentViewsConstraints];
            [UIView animateWithDuration:0.3 animations:^{
                self.scrollContentContainer.alpha = 1;
            }];
        }];
        
    } else {
    
        // 查询
        self.isTranslating = YES;
//        self.navPreLangButton.enabled = NO;
//        self.navNextLangButton.enabled = NO;
        CGRect containerFrame = self.scrollContentContainer.frame;
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect holder = containerFrame;
            if (navigationToNext) {
                holder.origin.x -= holder.size.width;
            } else {
                holder.origin.x += holder.size.width;
            }
            self.scrollContentContainer.frame = holder;
            self.scrollContentContainer.alpha = 0;
            
        } completion:^(BOOL finished) {
            self.scrollContentContainer.frame = containerFrame;
            [self.scrollView setContentOffset:CGPointZero animated:NO];
            
            [self displayCurrentTranslateLanguage];
            [self resultDisplayTextViewDisplayTipText:NSLocalizedStringFromTable(@"Translating...", @"todayextension", nil)];
            if (self.isContentExpanded) {
                [self toggleContentExpanded];
            }
            [self updateScrollContentViewsConstraints];
            
            [UIView animateWithDuration:0.3 animations:^{
                self.scrollContentContainer.alpha = 1;
            } completion:^(BOOL finished) {
                __weak typeof(self)weakSelf = self;
                [self.dataController translateForInput:[self.storeInfo input]
                                          destLanguage:[self currentOutputLanguage]
                completeHandler:^(TodayTranslateResponse *resp, NSError *error) {
                
                    if (!weakSelf) return;
                    
                    weakSelf.isTranslating = NO;
//                    weakSelf.navPreLangButton.enabled = YES;
//                    weakSelf.navNextLangButton.enabled = YES;
                    if (error || !resp || !resp.translateId) {
                        // 出错
                        [weakSelf resultDisplayTextViewDisplayTipText:NSLocalizedStringFromTable(@"The guy can't be translated!", @"todayextension", nil)];
                    } else {
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
                        
                        [weakSelf displayCurrentTranslateResult];
                    }
                    
                    [weakSelf updateScrollContentViewsConstraints];
                }];
            }];
        }];
    }
}

- (void)languagePre:(id)sender {
    
    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    if (self.isTranslating) {
        [self shakeResultDisplayTextViewAtLeft:YES right:NO];
        return;
    }
    
    if (self.currenOutputLanguageIndex == 0) {
        // 第一种语言，不能向前了，抖动
        [self shakesAtTop:NO left:YES bottom:NO right:NO];
        return;
    }
    
    NSInteger preOutputLanguageIndex = self.currenOutputLanguageIndex - 1;
    self.currenOutputLanguageIndex = preOutputLanguageIndex;
    [self didChangedOutputLanguageWithNavigationToNext:NO];
}

- (void)languageNext:(id)sender {

    // 触感振动
    [self.traitCollection tapticPeekIfPossible];
    
    if (self.isTranslating) {
        [self shakeResultDisplayTextViewAtLeft:NO right:YES];
        return;
    }
    
    if (self.currenOutputLanguageIndex >= self.translateOutputLanguageList.count - 1) {
        // 没有更多语言了，抖动
        [self shakesAtTop:NO left:NO bottom:NO right:YES];
        return;
    }
    
    NSInteger nextOutputLanguageIndex = self.currenOutputLanguageIndex + 1;
    self.currenOutputLanguageIndex = nextOutputLanguageIndex;
    [self didChangedOutputLanguageWithNavigationToNext:YES];
}

- (UILabel *)copiedTipLabel {
    if (!_copiedTipLabel) {
        _copiedTipLabel = [[UILabel alloc] init];
        _copiedTipLabel.text = NSLocalizedStringFromTable(@"copied", @"TDBundle", nil);
        _copiedTipLabel.textColor = [TDColorSpecs wd_mainTextColor];
        _copiedTipLabel.font = [TDFontSpecs tiny];
    }
    return _copiedTipLabel;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.viewDidLayoutSubviewsCallNum ++;
    
    if (self.viewDidLayoutSubviewsCallNum == 1) {
        self.scrollContentContainerWidth.constant = [self scrollContentWidth];
        self.inputDisplayLabel.preferredMaxLayoutWidth = [self inputDisplayLabelMaxLayoutWidth];
        
        [self updateScrollContentViewsConstraints];
        [self updateScrollViewContentSize];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *translateId = [self.itemTranslateId copy];
    TodayTranslateCheckExistResponse *checkResp
    = [self.dataController checkExistWithRequest:^TodayTranslateCheckExistRequest *{
        TodayTranslateCheckExistRequest *info = [[TodayTranslateCheckExistRequest alloc] init];
        info.translateId = translateId;
        info.checkExistInHistory = YES;
        info.checkExistInStarred = YES;
        return info;
    }];
    
    self.storeInfo = checkResp.existItemInHistory?:checkResp.existItemInStarred;
    self.isStarred = checkResp.existItemInStarred?YES:NO;
    
    NSArray<NSNumber *> *defaultPreferredLangList = [TDPrefs shared].preferredTranslateOutputLanguageList?:TDDefaultValue_preferredTranslateOutputLanguageList();
    if (self.storeInfo) {
        self.translateOutputLanguageList = [self.storeInfo preferredOutputLanguagesOrderWithDefault:defaultPreferredLangList];
    } else {
        self.translateOutputLanguageList = defaultPreferredLangList;
        if (self.cancelHandler) {
            self.cancelHandler(nil);
        }
        return;
    }
    self.currenOutputLanguageIndex = ({
        TDTextTranslateLanguage initialDisplayLang = self.storeInfo.translateResults.firstObject.outputLang;
        __block NSUInteger findIdx = 0;
        [self.translateOutputLanguageList enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj integerValue] == initialDisplayLang) {
                findIdx = idx;
                *stop = YES;
            }
        }];
        findIdx;
        
    });
    
    
    self.inputContainer.clipsToBounds = YES;
    self.bottomBarContainer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.001];
    self.compactModeContentOperateOptionsContainer.backgroundColor = [UIColor colorWithRGB:0x000000 alpha:0.06];
    [[self class] roundStyleForView:self.compactModeContentOperateOptionsContainer];
    
    self.itemOperateOptionsContainer.backgroundColor = [UIColor colorWithRGB:0x000000 alpha:0.06];
    [[self class] roundStyleForView:self.itemOperateOptionsContainer];
    
    self.languageOptionsContainer.backgroundColor = [UIColor colorWithRGB:0x000000 alpha:0.06];
    [[self class] roundStyleForView:self.languageOptionsContainer];
    
    self.resultDisplayTextView.textContainer.lineFragmentPadding = 0;
    self.resultDisplayTextView.textContainerInset = UIEdgeInsetsZero;
    
    [self.starButton addTarget:self action:@selector(toggleStarred) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.copyyButton addTarget:self action:@selector(copyyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.trashButton addTarget:self action:@selector(trashClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.cancelButton setTitle:NSLocalizedStringFromTable(@"Cancel", @"todayextension", nil) forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.widgetDisplayMode == NCWidgetDisplayModeCompact) {
        self.expandedModeContentOperateItemsStackView.hidden = YES;
        self.expandedModecontentOperateItemsStackViewWidth.constant = 12;
        self.compactModeContentOperateOptionsContainer.hidden = NO;
        self.itemOperateOptionsContainer.hidden = YES;
        self.contentExpandButton = self.compactModeContentOperateOptionsStackView.arrangedSubviews[0];
        self.contentPageUpButton = self.compactModeContentOperateOptionsStackView.arrangedSubviews[1];
        self.contentPageDownButton = self.compactModeContentOperateOptionsStackView.arrangedSubviews[2];
        self.languageOptionsContainerLeading.constant = (164 - 35);
    } else {
        self.expandedModeContentOperateItemsStackView.hidden = NO;
        self.expandedModecontentOperateItemsStackViewWidth.constant = 28;
        self.compactModeContentOperateOptionsContainer.hidden = YES;
        self.itemOperateOptionsContainer.hidden = NO;
        self.contentExpandButton = self.expandedModeContentOperateItemsStackView.arrangedSubviews[0];
        self.contentPageUpButton = self.expandedModeContentOperateItemsStackView.arrangedSubviews[1];
        self.contentPageDownButton = self.expandedModeContentOperateItemsStackView.arrangedSubviews[2];
        self.languageOptionsContainerLeading.constant = 164;
    }
    
    [self.contentExpandButton addTarget:self action:@selector(toggleContentExpanded) forControlEvents:UIControlEventTouchUpInside];
    self.isContentExpanded = NO;
    
    [self.contentPageUpButton addTarget:self action:@selector(pageUp:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentPageDownButton addTarget:self action:@selector(pageDown:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navPreLangButton addTarget:self action:@selector(languagePre:) forControlEvents:UIControlEventTouchUpInside];
    [self.navNextLangButton addTarget:self action:@selector(languageNext:) forControlEvents:UIControlEventTouchUpInside];
    
    self.inputDisplayLabel.text = self.storeInfo.input;
    [self displayCurrentTranslateResult];
    [self displayCurrentTranslateLanguage];
    [self displayStarredState];
}

@end
