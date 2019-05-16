//
//  ShareEditViewController.m
//  tinyDict
//
//  Created by guangbool on 2017/4/17.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "ShareEditViewController.h"
#import <TDKit/TDKit.h>
#import <UITextView+Placeholder/UITextView+Placeholder.h>
#import <YYKeyboardManager/YYKeyboardManager.h>
#import <Aspects/Aspects.h>
#import "UIToolbar+TDApp.h"
#import "ShareEditMenuPanel.h"
#import "TDOverlayDrawAnimation.h"
#import "SharePreviewViewController.h"
#import "DefaultNavigationController.h"

@interface ShareEditViewController () <UITextViewDelegate, YYKeyboardObserver, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UIView *bodyView;
@property (nonatomic) UITextView *editTextView;
@property (nonatomic) UIBarButtonItem *menuRightNavItem;
@property (nonatomic) UIButton *shareButn;

@property (nonatomic) UIView *menuPanelOverlayView;
@property (nonatomic) ShareEditMenuPanel *menuPanel;

@property (nonatomic) UIActivityIndicatorView *loadingIndicator;

@property (nonatomic) TodayDataController0012 *dataController;
@property (nonatomic) TDTranslateStoreItem *storeInfo;

@property (nonatomic) UITextPosition *insertTextPositionOfEditTextView;
@property (nonatomic) NSUInteger insertLocationOfEditTextView;

@property (nonatomic) NSTextAlignment globalTextAlignment;

@end

@implementation ShareEditViewController

- (instancetype)init {
    return [self initWithTid:nil init_lang:TDTextTranslateLanguage_unkown];
}

- (instancetype)initWithTid:(NSString *)tid init_lang:(TDTextTranslateLanguage)init_lang {
    if (self = [super init]) {
        _tid = [tid copy];
        _init_lang = init_lang;
    }
    return self;
}

+ (UIEdgeInsets)editTextViewTextContainerInset {
    return UIEdgeInsetsMake(24, 20, 20, 30);
}

- (UIView *)bodyView {
    if (!_bodyView) {
        _bodyView = [[UIView alloc]init];
        _bodyView.clipsToBounds = YES;
    }
    return _bodyView;
}

- (UITextView *)editTextView {
    if (!_editTextView) {
        _editTextView = [[UITextView alloc] init];
        _editTextView.backgroundColor = [UIColor whiteColor];
        _editTextView.textContainer.lineFragmentPadding = 0;
        _editTextView.textContainerInset = [self.class editTextViewTextContainerInset];
        _editTextView.font = [TDFontSpecs large];
        _editTextView.textColor = [TDColorSpecs app_mainTextColor];
        _editTextView.editable = YES;
        _editTextView.scrollEnabled = YES;
        _editTextView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
        _editTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        _editTextView.spellCheckingType = UITextSpellCheckingTypeNo;
        _editTextView.enablesReturnKeyAutomatically = NO;
        _editTextView.placeholder = NSLocalizedStringFromTable(@"Share something...", @"TinyT", nil);
        _editTextView.placeholderColor = [TDColorSpecs app_minorTextColor];
        _editTextView.delegate = self;
        _editTextView.inputAccessoryView = [UIToolbar td_createToolbarWithRightItemForTitle:NSLocalizedStringFromTable(@"Done", @"TinyT", nil) target:self action:@selector(hideKeyboard)];
        
        [self adjustCaretRectForEditTextView];
    }
    return _editTextView;
}

- (void)adjustCaretRectForEditTextView {
    [_editTextView aspect_hookSelector:@selector(caretRectForPosition:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
        NSInvocation *invocation = aspectInfo.originalInvocation;
        
        CGRect originalRect;
        [invocation invoke];
        [invocation getReturnValue:&originalRect];
//            NSLog(@"originalRect: %@", NSStringFromCGRect(originalRect));
        
        CGRect result = originalRect;
        UITextView *instance = [aspectInfo instance];
        NSUInteger selectedLocation = instance.selectedRange.location;
        if (selectedLocation != NSNotFound) {
            NSAttributedString *attributedText = instance.attributedText;
            NSTextAttachment *caretBeforeAttachment = ({
                NSTextAttachment *attach = nil;
                if (selectedLocation > 0 && attributedText.length > 0) {
                    NSAttributedString *caretBeforeAttrText = [attributedText attributedSubstringFromRange:NSMakeRange(selectedLocation-1, 1)];
                    attach = [caretBeforeAttrText attribute:NSAttachmentAttributeName atIndex:0 effectiveRange:nil];
                }
                attach;
            });
            
            NSTextAttachment *caretAfterAttachment = ({
                NSTextAttachment *attach = nil;
                if (attributedText.length >= selectedLocation + 1) {
                    NSAttributedString *caretAfterAttrText = [attributedText attributedSubstringFromRange:NSMakeRange(selectedLocation, 1)];
                    attach = [caretAfterAttrText attribute:NSAttachmentAttributeName atIndex:0 effectiveRange:nil];
                }
                attach;
            });
            
            if (!caretBeforeAttachment && !caretAfterAttachment) {
                result.size.height = [TDFontSpecs large].lineHeight;
            }
        }
//            NSLog(@"resultRect: %@", NSStringFromCGRect(result));
        [invocation setReturnValue:&result];
        
    } error:nil];
}

- (void)hideKeyboard {
    [_editTextView resignFirstResponder];
}

- (UIBarButtonItem *)menuRightNavItem {
    if (!_menuRightNavItem) {
        _menuRightNavItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_ic"] style:UIBarButtonItemStylePlain target:self action:@selector(showShareMenuPanel)];
    }
    return _menuRightNavItem;
}

- (UIButton *)shareButn {
    if (!_shareButn) {
        _shareButn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButn setTitle:NSLocalizedStringFromTable(@"Share", @"TinyT", nil) forState:UIControlStateNormal];
        _shareButn.titleLabel.font = [TDFontSpecs largeBold];
        [_shareButn setTitleColor:[TDColorSpecs app_tint] forState:UIControlStateNormal];
        [_shareButn setLayerShadow:[UIColor blackColor] offset:CGSizeMake(0, 3) radius:3];
        _shareButn.backgroundColor = [TDColorSpecs app_cellColor];
        [_shareButn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButn;
}

- (UIView *)menuPanelOverlayView {
    if (!_menuPanelOverlayView) {
        _menuPanelOverlayView = [UIControl new];
        _menuPanelOverlayView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        [((UIControl *)_menuPanelOverlayView) addTarget:self action:@selector(hideShareMenuPanel) forControlEvents:UIControlEventTouchDown];
    }
    return _menuPanelOverlayView;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingIndicator.hidesWhenStopped = YES;
    }
    return _loadingIndicator;
}

- (BOOL)onlyAlignCurrentParagraph {
    NSNumber *valNum = [TDPrefs shared].onlyAlignCurrentParagraph;
    if (valNum) {
        return [valNum boolValue];
    }
    return TDAppDefaultValue_onlyAlignCurrentParagraph;
}

- (CGFloat)menuPanelTopSpacing {
    CGFloat topSpacing = 0;
    if (self.navigationController.navigationBar.isTranslucent) {
        topSpacing = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + CGRectGetHeight(self.navigationController.navigationBar.frame);
    }
    return topSpacing;
}

- (CGSize)menuPanelAnimationContainerSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return CGSizeMake(screenSize.width, screenSize.height - [self menuPanelTopSpacing]);
}

- (ShareEditMenuPanel *)menuPanel {
    if (!_menuPanel) {
        _menuPanel = [[ShareEditMenuPanel alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        [_menuPanel setLayerShadow:[UIColor blackColor] offset:CGSizeMake(1, 0) radius:2];
        
        _menuPanel.alignCurrentParagraphOnly = [self onlyAlignCurrentParagraph];
        
        __weak typeof(self)weakSelf = self;
        _menuPanel.sourceInsertHandler = ^(ShareEditMenuPanel *panel){
            [weakSelf hideShareMenuPanel];
            [weakSelf insertSource];
        };
        _menuPanel.translationInsertHandler = ^(ShareEditMenuPanel *panel, TDTextTranslateLanguage insertLanguageOutput){
            [weakSelf hideShareMenuPanel];
            [weakSelf insertTranslationForLang:insertLanguageOutput];
        };
        _menuPanel.photoInsertHandler = ^(ShareEditMenuPanel *panel, BOOL insertFromAlbum, BOOL takePhoto) {
            [weakSelf hideShareMenuPanel];
            [weakSelf insertPhotoFromAlbum:insertFromAlbum];
        };
        _menuPanel.alignCurrentParagraphOnlyToggleHandler = ^(ShareEditMenuPanel *panel, BOOL alignCurrentParagraphOnly) {
            if (!weakSelf) return;
            [TDPrefs shared].onlyAlignCurrentParagraph = @(alignCurrentParagraphOnly);
        };
        _menuPanel.alignOptionHandler = ^(ShareEditMenuPanel *panel, NSTextAlignment alignment) {
            [weakSelf hideShareMenuPanel];
            [weakSelf alignText:alignment];
        };
        _menuPanel.resetHandler = ^(ShareEditMenuPanel *panel) {
            [weakSelf hideShareMenuPanel];
            [weakSelf resetText];
        };
        _menuPanel.previewHandler = ^(ShareEditMenuPanel *panel) {
            [weakSelf hideShareMenuPanel];
            [weakSelf preview];
        };
    }
    return _menuPanel;
}

- (void)showShareMenuPanel {

    [_editTextView resignFirstResponder];
    

    // show panel
    
    if (!self.menuPanelOverlayView.superview) {
        [self.view addSubview:self.menuPanelOverlayView];
    }
    CGFloat panelTopSpacing = [self menuPanelTopSpacing];
    [self.menuPanelOverlayView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(panelTopSpacing);
        make.leading.and.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.view bringSubviewToFront:self.menuPanelOverlayView];
    
    BOOL existTranslateInfo = self.storeInfo != nil;
    self.menuPanel.showTranslationEditOptions = existTranslateInfo;
    
    if (!self.menuPanel.superview) {
        [self.menuPanelOverlayView addSubview:self.menuPanel];
    }
    
    __weak typeof(self)weakSelf = self;
    [self.menuPanel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.width.equalTo(weakSelf.menuPanelOverlayView.mas_width).multipliedBy(0.9);
    }];
    
    [self.view layoutIfNeeded];
    
    // Store interactivePopGestureRecognizer state
    [self setAssociateValue:@(self.navigationController.interactivePopGestureRecognizer.enabled) withKey:@"interactivePopGestureRecognizerEnabledBeforeShowPanel"];
    
    TDOverlayDrawAnimation *drawAnimation = [[TDOverlayDrawAnimation alloc] init];
    drawAnimation.drawStyle = TDOverlayDrawAnimationDrawFromRight;
    drawAnimation.drawView = self.menuPanel;
    drawAnimation.overlayBackgroudView = self.menuPanelOverlayView;
    drawAnimation.animationContainerSize = [self menuPanelAnimationContainerSize];
    
    [drawAnimation animate:({
        TDOverlayDrawAnimationContext *ctx = [TDOverlayDrawAnimationContext new];
        ctx.fromVisible = NO;
        ctx.toVisible = YES;
        ctx.duration = 0.3;
        ctx.animationFinishedHandler = ^(BOOL finished, BOOL fromVisible, BOOL toVisible){
            if (!weakSelf) return;
            weakSelf.navigationItem.title = NSLocalizedStringFromTable(@"Menu", @"TinyT", nil);
            weakSelf.navigationItem.rightBarButtonItem
            = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close_ic"]
                                               style:UIBarButtonItemStylePlain
                                              target:weakSelf
                                              action:@selector(hideShareMenuPanel)];
            [weakSelf.navigationItem setHidesBackButton:YES];
            
            // Set interactivePopGestureRecognizer disabled
            weakSelf.navigationController.interactivePopGestureRecognizer.enabled = NO;
        };
        ctx;
    })];
}

- (void)hideShareMenuPanel {
    if (!_menuPanel && !_menuPanelOverlayView) {
        return;
    }
    
    TDOverlayDrawAnimation *drawAnimation = [[TDOverlayDrawAnimation alloc] init];
    drawAnimation.drawStyle = TDOverlayDrawAnimationDrawFromRight;
    drawAnimation.drawView = _menuPanel;
    drawAnimation.overlayBackgroudView = _menuPanelOverlayView;
    drawAnimation.animationContainerSize = [self menuPanelAnimationContainerSize];
    
    __weak typeof(self)weakSelf = self;
    [drawAnimation animate:({
        TDOverlayDrawAnimationContext *ctx = [TDOverlayDrawAnimationContext new];
        ctx.fromVisible = YES;
        ctx.toVisible = NO;
        ctx.duration = 0.3;
        ctx.animationFinishedHandler = ^(BOOL finished, BOOL fromVisible, BOOL toVisible){
            if (!weakSelf) return;
            weakSelf.navigationItem.title = NSLocalizedStringFromTable(@"Share", @"TinyT", nil);
            weakSelf.navigationItem.rightBarButtonItem = weakSelf.menuRightNavItem;
            [weakSelf.navigationItem setHidesBackButton:NO];
            
            // Restore interactivePopGestureRecognizer state
            weakSelf.navigationController.interactivePopGestureRecognizer.enabled = ((NSNumber *)[weakSelf getAssociatedValueForKey:@"interactivePopGestureRecognizerEnabledBeforeShowPanel"]).boolValue;
        };
        ctx;
    })];
}

- (void)editTextViewInsertSource:(NSAttributedString *)source newLineWrap:(BOOL)newLineWrap {
    
    NSAttributedString *newLineAttrText = [self.class createEditTextViewAttributedTextWithSource:newLineWrap?@"\n":@"" alignment:self.globalTextAlignment];
    if (self.insertLocationOfEditTextView == 0) {
        NSMutableAttributedString *insertText = [[NSMutableAttributedString alloc] init];
        [insertText appendAttributedString:source];
        [insertText appendAttributedString:newLineAttrText];
        [_editTextView.textStorage insertAttributedString:insertText atIndex:0];
        
    } else if (_editTextView.textStorage.length >= self.insertLocationOfEditTextView){
        
        NSMutableAttributedString *insertText = [[NSMutableAttributedString alloc] init];
        [insertText appendAttributedString:newLineAttrText];
        [insertText appendAttributedString:source];
        [insertText appendAttributedString:newLineAttrText];
        
        [_editTextView.textStorage insertAttributedString:insertText atIndex:self.insertLocationOfEditTextView];
    }
}

- (void)insertImage:(UIImage *)image {
    if (!image) return;
    
    UIImage *optImg = nil;
    if (image.scale == [UIScreen mainScreen].scale) {
        optImg = image;
    } else {
        optImg = [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:image.imageOrientation];
    }
    
    CGFloat oldWidth = optImg.size.width;
    
    // For display nicely
    UIEdgeInsets textContainerInset = [self.class editTextViewTextContainerInset];
    CGFloat tar_width = (CGRectGetWidth([UIScreen mainScreen].bounds) - textContainerInset.left - textContainerInset.right);
    if (tar_width <= 0) return;
    
    CGFloat resizeFactor = tar_width / oldWidth;
    if (resizeFactor < 1) {
        optImg = [optImg imageByResizeToSize:CGSizeMake(tar_width, optImg.size.height * resizeFactor)];
    }
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = optImg;
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [self editTextViewInsertSource:attrStringWithImage newLineWrap:YES];
}

- (void)insertText:(NSString *)text {
    if (text.length == 0) return;
    NSAttributedString *insertAttrText = [self.class createEditTextViewAttributedTextWithSource:text  alignment:self.globalTextAlignment];
    [self editTextViewInsertSource:insertAttrText newLineWrap:YES];
}

- (void)insertSource {
    NSString *source = [self.storeInfo input];
    [self insertText:source];
}

- (void)insertTranslationForLang:(TDTextTranslateLanguage)translateLang {

    TDTranslateResultStoreItem *langOutput = [self.storeInfo translateResultForOutputLang:translateLang];
    if (langOutput) {
        [self insertText:langOutput.output];
        return;
    }
    
    // load immediately if have not load
    CGRect caretRect = CGRectZero;
    if (self.insertTextPositionOfEditTextView) {
        caretRect = [self.editTextView caretRectForPosition:self.insertTextPositionOfEditTextView];
    } else {
        caretRect = CGRectMake(20, 20, 1, self.editTextView.font.lineHeight);
        self.insertLocationOfEditTextView = 0;
    }
    CGSize indicatorSize = [self.loadingIndicator intrinsicContentSize];
    [self.loadingIndicator mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(CGRectGetMidX(caretRect) - indicatorSize.width/2);
        make.top.mas_equalTo(CGRectGetMidY(caretRect) - indicatorSize.height/2);
    }];
    [self.loadingIndicator startAnimating];
    [self.editTextView setEditable:NO];
    [self.editTextView setSelectable:NO];
    [self.menuRightNavItem setEnabled:NO];
    __weak typeof(self)weakSelf = self;
    [self.dataController translateForInput:self.storeInfo.input destLanguage:translateLang completeHandler:^(TodayTranslateResponse *resp, NSError *error) {
        if (!weakSelf) return;
        
        [weakSelf.loadingIndicator stopAnimating];
        [weakSelf.editTextView setEditable:YES];
        [weakSelf.editTextView setSelectable:YES];
        [weakSelf.menuRightNavItem setEnabled:YES];
        
        if (error || !resp || !resp.translateId) return;
        
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
        
        // insert output
        [weakSelf insertText:newTranslateResult.output];
    }];
}

- (void)insertPhotoFromAlbum:(BOOL)isFromAlbum {
    
    UIImagePickerController *picker =[[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = isFromAlbum?UIImagePickerControllerSourceTypePhotoLibrary:UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = NO;
    
    [self presentViewController:picker animated:YES completion:nil];
    
    
//    UIImage *testImg = [UIImage imageNamed:@"Social_Icons_Flat"];
//    [self insertImage:testImg];
}

- (void)alignText:(NSTextAlignment)alignment {

    BOOL onlyAlignCurrentParagraph = [self onlyAlignCurrentParagraph];
    if (onlyAlignCurrentParagraph && self.insertLocationOfEditTextView != NSNotFound) {
        [self alignCurrentParagraphOnly:alignment];
    } else {
        // all paragraphs
        [self alignTextAtRange:NSMakeRange(0, _editTextView.textStorage.length) withAlignment:alignment];
    }
}

- (void)alignCurrentParagraphOnly:(NSTextAlignment)alignment {
    NSInteger insertLocation = self.insertLocationOfEditTextView;
    NSInteger textLength = _editTextView.attributedText.length;
    if (insertLocation <= textLength) {
        NSAttributedString *leftPart = [_editTextView.attributedText attributedSubstringFromRange:NSMakeRange(0, insertLocation)];
        NSAttributedString *rightPart = [_editTextView.attributedText attributedSubstringFromRange:NSMakeRange(insertLocation, textLength - insertLocation)];
        NSUInteger leftNewLineCharactarLocation = ({
            NSUInteger loc = 0;
            NSUInteger len = leftPart.length;
            if (len > 0) {
                for (NSInteger i = len - 1; i >= 0; i --) {
                    NSString *fragmentStr = [leftPart attributedSubstringFromRange:NSMakeRange(i, 1)].string;
                    if (fragmentStr && [@"\n" isEqualToString:fragmentStr]) {
                        loc = i + 1;
                        break;
                    }
                }
            }
            loc;
        });
        NSUInteger rightNewLineCharactarLocation = ({
            NSUInteger loc = 0;
            NSUInteger len = rightPart.length;
            if (len > 0) {
                for (NSInteger i = 0; i < len; i ++) {
                    NSString *fragmentStr = [rightPart attributedSubstringFromRange:NSMakeRange(i, 1)].string;
                    if (fragmentStr && [@"\n" isEqualToString:fragmentStr]) {
                        loc = i;
                        break;
                    }
                }
            }
            loc += leftPart.length;
            loc;
        });
        
        if (rightNewLineCharactarLocation >= leftNewLineCharactarLocation) {
            NSRange range = NSMakeRange(leftNewLineCharactarLocation,
                                        rightNewLineCharactarLocation - leftNewLineCharactarLocation);
            [self alignTextAtRange:range withAlignment:alignment];
        }
    }
}

- (void)alignTextAtRange:(NSRange)range withAlignment:(NSTextAlignment)alignment {
    if (range.location == NSNotFound) return;
    if (range.location + range.length > _editTextView.textStorage.length) return;
    
    NSMutableParagraphStyle *pStyle = [self.class editTextViewAttributedTextParagraphStyle];
    pStyle.alignment = alignment;
    [_editTextView.textStorage addAttribute:NSParagraphStyleAttributeName value:pStyle range:range];
}

- (void)resetText {
    
    self.insertTextPositionOfEditTextView = nil;
    self.insertLocationOfEditTextView = 0;
    self.globalTextAlignment = NSTextAlignmentLeft;
    
    NSMutableString *displayText = [NSMutableString string];
    if (self.storeInfo) {
        [displayText appendString:self.storeInfo.input?:@""];
        NSString *initOutput = [self.storeInfo translateResultForOutputLang:self.init_lang].output;
        if (initOutput.length > 0) {
            if (displayText.length > 0) [displayText appendString:@"\n"];
            [displayText appendString:initOutput];
        }
    }
    
    if (displayText.length == 0) {
        // set paragraph style first if text is empty
        NSTextStorage *textStorage = self.editTextView.textStorage;
        [textStorage setAttributedString:[[self class] createEditTextViewAttributedTextWithSource:@" " alignment:self.globalTextAlignment]];
        [textStorage setAttributedString:[[self class] createEditTextViewAttributedTextWithSource:@"" alignment:self.globalTextAlignment]];
    } else {
        [self.editTextView.textStorage setAttributedString:[[self class] createEditTextViewAttributedTextWithSource:displayText alignment:self.globalTextAlignment]];
    }
}

- (UIImage *)generatePreviewImage {
    if (!_editTextView) return nil;
    
    UITextView *tmpSnapshootView = [UITextView new];
    tmpSnapshootView.backgroundColor = [UIColor whiteColor];
    tmpSnapshootView.textContainer.lineFragmentPadding = 0;
    tmpSnapshootView.textContainer.lineFragmentPadding = _editTextView.textContainer.lineFragmentPadding;
    tmpSnapshootView.textContainerInset = _editTextView.textContainerInset;
    tmpSnapshootView.attributedText = _editTextView.attributedText;
    CGFloat fitWidth = CGRectGetWidth(_editTextView.frame);
    CGFloat fitHeight = [tmpSnapshootView sizeThatFits:CGSizeMake(fitWidth, 0)].height;
    tmpSnapshootView.frame = CGRectMake(0, 0, fitWidth, fitHeight);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(fitWidth, fitHeight), NO, [UIScreen mainScreen].scale);
    
    [tmpSnapshootView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *previewImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return previewImg;
}

- (void)showPreviewViewWithImage:(UIImage *)previewImg hideOperateItemsInitial:(BOOL)hideOperateItemsInitial {
    SharePreviewViewController *previewVC = [[SharePreviewViewController alloc] initWithPreviewImage:previewImg];
    
    previewVC.closeHandler = ^(UIViewController *viewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    DefaultNavigationController *defaultNAV = [[DefaultNavigationController alloc] initWithRootViewController:previewVC];
    defaultNAV.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    __weak typeof(self)weakSelf = self;
    [self presentViewController:defaultNAV animated:YES completion:^{
        if (!hideOperateItemsInitial) {
            SharePreviewViewController *topVC = (SharePreviewViewController *)[(UINavigationController *)weakSelf.presentedViewController topViewController];
            [topVC animatedShowOperateItems];
        }
    }];
}

- (void)preview {
    UIImage *previewImg = [self generatePreviewImage];
    if (!previewImg) return;
    
    [self showPreviewViewWithImage:previewImg hideOperateItemsInitial:YES];
}

- (void)share:(id)sender {
    UIImage *previewImg = [self generatePreviewImage];
    if (!previewImg) return;
    
    [self showPreviewViewWithImage:previewImg hideOperateItemsInitial:NO];
}

- (TodayDataController0012 *)dataController {
    if (!_dataController) {
        _dataController = [[TodayDataController0012 alloc] init];
    }
    return _dataController;
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

- (void)updateInsertTextPositionIfNeed {

    UITextRange *selectedTextRange = _editTextView.selectedTextRange;
    if (selectedTextRange) {
        self.insertTextPositionOfEditTextView = selectedTextRange.start;
    }
}

- (void)updateInsertLocationIfNeed {
    
    NSUInteger selectedLocation = _editTextView.selectedRange.location;
    if (selectedLocation != NSNotFound) {
        self.insertLocationOfEditTextView = selectedLocation;
    }
}

+ (NSMutableParagraphStyle *)editTextViewAttributedTextParagraphStyle {
    NSMutableParagraphStyle *info = [[NSMutableParagraphStyle alloc] init];
    info.lineSpacing = 10;
    info.paragraphSpacing = 0;
    return info;
}

+ (NSAttributedString *)createEditTextViewAttributedTextWithSource:(NSString *)sourceText alignment:(NSTextAlignment)alignment {
    if (!sourceText) return nil;
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = [TDFontSpecs large];
    attrs[NSForegroundColorAttributeName] = [TDColorSpecs app_mainTextColor];
    attrs[NSParagraphStyleAttributeName] = ({
        NSMutableParagraphStyle *info = [self editTextViewAttributedTextParagraphStyle];
        info.alignment = alignment;
        info;
    });
    
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:sourceText attributes:attrs];
    return attributed;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.globalTextAlignment = NSTextAlignmentLeft;
    
    if (self.tid.length > 0) {
        TodayTranslateCheckExistResponse *checkResp = [self loadExistTranslateWithId:self.tid];
        self.storeInfo = checkResp.existItemInHistory?:checkResp.existItemInStarred;
    }
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = NSLocalizedStringFromTable(@"Share", @"TinyT", nil);
    self.navigationItem.rightBarButtonItem = self.menuRightNavItem;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.bodyView];
    [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    
    [self.bodyView addSubview:self.editTextView];
    [self.bodyView addSubview:self.shareButn];
    
    __weak typeof(self)weakSelf = self;
    [self.shareButn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo([TDHeight app_bottomBarHeight]);
    }];
    
    [self.editTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.and.trailing.mas_equalTo(0);
        make.bottom.equalTo(weakSelf.shareButn.mas_bottom);
    }];
    
    [self.editTextView addSubview:self.loadingIndicator];
    
    [self resetText];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self updateInsertTextPositionIfNeed];
    [self updateInsertLocationIfNeed];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self updateInsertTextPositionIfNeed];
    [self updateInsertLocationIfNeed];
}

#pragma mark - YYKeyboardObserver

- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    
    if (transition.toVisible) {
        CGRect kbFrame = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
            [_editTextView mas_updateConstraints:^(MASConstraintMaker *make) {
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
            [_editTextView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-[TDHeight app_bottomBarHeight]);
            }];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self insertImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
