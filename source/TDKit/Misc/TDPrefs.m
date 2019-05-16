//
//  TDPrefs.m
//  tinyDict
//
//  Created by guangbool on 2017/3/31.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "TDPrefs.h"
#import "MMWormhole.h"
#import "TDConstants.h"

@interface TDPrefs ()

@property (nonatomic) MMWormhole *prefsWormhole;

@end

@implementation TDPrefs

static id _instance;

+(instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    
    return _instance;
}

+(id)allocWithZone:(struct _NSZone *)zone {
    // 创建对象的步骤分为申请内存(alloc)、初始化(init)这两个步骤。在调用alloc 这一阶段时，oc内部会调用allocWithZone这个方法来申请内存，我们覆写这个方法，然后在这个方法中调用shareInstance方法返回单例对象，即可确保对象的唯一性。
    return [TDPrefs shared];
}

-(id)copyWithZone:(struct _NSZone *)zone {
    return [TDPrefs shared];
}

- (MMWormhole *)prefsWormhole {
    if (!_prefsWormhole) {
        _prefsWormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:NameOfTDAppGroup
                                                              optionalDirectory:DirectoryNameOfAppPrefs];
    }
    return _prefsWormhole;
}

- (NSNumber *)translateCopyTextAutomatically {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:NSStringFromSelector(@selector(translateCopyTextAutomatically))];
    return val;
}

- (void)setTranslateCopyTextAutomatically:(NSNumber *)translateCopyTextAutomatically {
    NSString *key = NSStringFromSelector(@selector(translateCopyTextAutomatically));
    if (!translateCopyTextAutomatically) {
        [self.prefsWormhole clearMessageContentsForIdentifier:key];
    } else {
        [self.prefsWormhole passMessageObject:translateCopyTextAutomatically identifier:key];
    }
}

- (NSNumber *)detectInputLanguageAndTranslateOutputOther {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:NSStringFromSelector(@selector(detectInputLanguageAndTranslateOutputOther))];
    return val;
}

- (void)setDetectInputLanguageAndTranslateOutputOther:(NSNumber *)detectInputLanguageAndTranslateOutputOther {
    NSString *key = NSStringFromSelector(@selector(detectInputLanguageAndTranslateOutputOther));
    if (!detectInputLanguageAndTranslateOutputOther) {
        [self.prefsWormhole clearMessageContentsForIdentifier:key];
    } else {
        [self.prefsWormhole passMessageObject:detectInputLanguageAndTranslateOutputOther identifier:key];
    }
}

- (NSArray<NSNumber *> *)preferredTranslateProviderList {
    return [self.prefsWormhole messageWithIdentifier:NSStringFromSelector(@selector(preferredTranslateProviderList))];
}

- (void)setPreferredTranslateProviderList:(NSArray<NSNumber *> *)preferredTranslateProviderList {
    NSString *key = NSStringFromSelector(@selector(preferredTranslateProviderList));
    if (!preferredTranslateProviderList) {
        [self.prefsWormhole clearMessageContentsForIdentifier:key];
    } else {
        [self.prefsWormhole passMessageObject:preferredTranslateProviderList identifier:key];
    }
}

- (NSArray<NSNumber *> *)preferredTranslateOutputLanguageList {
    return [self.prefsWormhole messageWithIdentifier:NSStringFromSelector(@selector(preferredTranslateOutputLanguageList))];
}

- (void)setPreferredTranslateOutputLanguageList:(NSArray<NSNumber *> *)preferredTranslateOutputLanguageList {
    NSString *key = NSStringFromSelector(@selector(preferredTranslateOutputLanguageList));
    if (!preferredTranslateOutputLanguageList) {
        [self.prefsWormhole clearMessageContentsForIdentifier:key];
    } else {
        [self.prefsWormhole passMessageObject:preferredTranslateOutputLanguageList identifier:key];
    }
}

- (void)setRecordsLimit:(NSNumber *)recordsLimit {
    NSString *key = NSStringFromSelector(@selector(recordsLimit));
    if (!recordsLimit) {
        [self.prefsWormhole clearMessageContentsForIdentifier:key];
    } else {
        [self.prefsWormhole passMessageObject:recordsLimit identifier:key];
    }
}

- (NSNumber *)recordsLimit {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:NSStringFromSelector(@selector(recordsLimit))];
    return val;
}


- (void)setTapticPeekOpened:(NSNumber *)tapticPeekOpened {
    NSString *key = NSStringFromSelector(@selector(tapticPeekOpened));
    if (!tapticPeekOpened) {
        [self.prefsWormhole clearMessageContentsForIdentifier:key];
    } else {
        [self.prefsWormhole passMessageObject:tapticPeekOpened identifier:key];
    }
}

- (NSNumber *)tapticPeekOpened {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:NSStringFromSelector(@selector(tapticPeekOpened))];
    return val;
}

- (void)setOnlySaveLastTranslateInAppTranslatePage:(NSNumber *)onlySaveLastTranslateInAppTranslatePage {
    NSString *key = NSStringFromSelector(@selector(onlySaveLastTranslateInAppTranslatePage));
    if (!onlySaveLastTranslateInAppTranslatePage) {
        [self.prefsWormhole clearMessageContentsForIdentifier:key];
    } else {
        [self.prefsWormhole passMessageObject:onlySaveLastTranslateInAppTranslatePage identifier:key];
    }
}

- (NSNumber *)onlySaveLastTranslateInAppTranslatePage {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:NSStringFromSelector(@selector(onlySaveLastTranslateInAppTranslatePage))];
    return val;
}

- (void)setPreferredTranslateCopyOptionInAppTranslatePage:(NSNumber *)preferredTranslateCopyOptionInAppTranslatePage {
    NSString *key = NSStringFromSelector(@selector(preferredTranslateCopyOptionInAppTranslatePage));
    if (!preferredTranslateCopyOptionInAppTranslatePage) {
        [self.prefsWormhole clearMessageContentsForIdentifier:key];
    } else {
        [self.prefsWormhole passMessageObject:preferredTranslateCopyOptionInAppTranslatePage identifier:key];
    }
}

- (NSNumber *)preferredTranslateCopyOptionInAppTranslatePage {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:NSStringFromSelector(@selector(preferredTranslateCopyOptionInAppTranslatePage))];
    return val;
}

- (void)setOnlyAlignCurrentParagraph:(NSNumber *)onlyAlignCurrentParagraph {
    NSString *key = NSStringFromSelector(@selector(onlyAlignCurrentParagraph));
    if (!onlyAlignCurrentParagraph) {
        [self.prefsWormhole clearMessageContentsForIdentifier:key];
    } else {
        [self.prefsWormhole passMessageObject:onlyAlignCurrentParagraph identifier:key];
    }
}

- (NSNumber *)onlyAlignCurrentParagraph {
    NSNumber *val = [self.prefsWormhole messageWithIdentifier:NSStringFromSelector(@selector(onlyAlignCurrentParagraph))];
    return val;
}

@end
