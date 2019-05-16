//
//  ShareEditMenuPanel.h
//  tinyDict
//
//  Created by guangbool on 2017/5/11.
//  Copyright © 2017年 bool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TDKit/TDConstants.h>

@interface ShareEditMenuPanel : UIView

// 是否显示和翻译相关的选项，这些选项包括「插入原文」、「插入译文」、「重置」
@property (nonatomic, assign) BOOL showTranslationEditOptions;

// 插入原文选中 handler
@property (nonatomic, copy) void(^sourceInsertHandler)(ShareEditMenuPanel *panel);

// 插入译文选中 handler
@property (nonatomic, copy) void(^translationInsertHandler)(ShareEditMenuPanel *panel, TDTextTranslateLanguage insertLanguageOutput);

// 插入图片选中 handler
@property (nonatomic, copy) void(^photoInsertHandler)(ShareEditMenuPanel *panel, BOOL insertFromAlbum, BOOL takePhoto);

// 只对齐当前段落
@property (nonatomic, assign) BOOL alignCurrentParagraphOnly;

// 只对齐当前段落 toggle handler
@property (nonatomic, copy) void(^alignCurrentParagraphOnlyToggleHandler)(ShareEditMenuPanel *panel, BOOL alignCurrentParagraphOnly);

// 对齐方式设置 handler
@property (nonatomic, copy) void(^alignOptionHandler)(ShareEditMenuPanel *panel, NSTextAlignment alignment);

// 重置选中 handler
@property (nonatomic, copy) void(^resetHandler)(ShareEditMenuPanel *panel);

// 预览选中 handler
@property (nonatomic, copy) void(^previewHandler)(ShareEditMenuPanel *panel);

// 最大本身高度
@property (nonatomic, assign) CGFloat maxIntrinsicContentHeight;

- (CGSize)intrinsicContentSize;

@end
