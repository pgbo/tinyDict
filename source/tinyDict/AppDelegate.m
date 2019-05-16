//
//  AppDelegate.m
//  tinyDict
//
//  Created by guangbool on 2017/3/8.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "AppDelegate.h"
#import <TDKit/TDKit.h>
#import <UIApplication-ViewControllerHandy/UIApplication+ViewControllerHandy.h>
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "DefaultNavigationController.h"
#import "MainViewController.h"
#import "ShareEditViewController.h"
#import "TranslateDetailViewController.h"
#import "TodayDataController0012.h"

static NSString *const MBSpotlightFunctionSearchableItemId_QuickTranslate = @"func.quicktranslate";
static NSString *const MBSpotlightFunctionSearchableItemId_PasteAndTranslate = @"func.pastetranslate";
static NSString *const MBSpotlightFunctionSearchableItemId_QuickShare = @"func.quickshare";

@interface AppDelegate ()

@property (nonatomic) TodayDataController0012 *dataController;

@end

@implementation AppDelegate


- (TodayDataController0012 *)dataController {
    if (!_dataController) {
        _dataController = [[TodayDataController0012 alloc] init];
    }
    return _dataController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self configureAppearance];
    
    [self configureFunctionSpotlightSearchableItems];
    
    [self.dataController indexesAllTranslateRecordsSpotlightSearchavleItemsIfNeed];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    MainViewController *navRootVC = [[MainViewController alloc] init];
    DefaultNavigationController *nav = [[DefaultNavigationController alloc] initWithRootViewController:navRootVC];
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([self openUrlIfNeed:url]) {
        return YES;
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray *restorableObjects))restorationHandler {
    if([userActivity.activityType isEqualToString:CSSearchableItemActionType]) {
        NSString *identifier = userActivity.userInfo[CSSearchableItemActivityIdentifier];
        //这里根据这个uniqueIdentifier可以跳转到详细信息页面
        NSLog(@"searchableIdentifier: %@", identifier);
        
        if ([identifier isEqualToString:MBSpotlightFunctionSearchableItemId_QuickTranslate]) {
            // quick translate
            
            TranslateDetailViewController *detail = [[TranslateDetailViewController alloc] init];
            [[UIApplication sharedApplication].presentedNavigationController pushViewController:detail animated:YES];
            
        } else if ([identifier isEqualToString:MBSpotlightFunctionSearchableItemId_PasteAndTranslate]) {
            // paste and translate
            
            NSString *pasteStr = [[UIPasteboard generalPasteboard].string stringByTrim];
            TranslateDetailViewController *detail = [[TranslateDetailViewController alloc] initWithInitialInputText:pasteStr];
            [[UIApplication sharedApplication].presentedNavigationController pushViewController:detail animated:YES];
            
        } else if ([identifier isEqualToString:MBSpotlightFunctionSearchableItemId_QuickShare]) {
            // quick share
            ShareEditViewController *shareEditVC = [[ShareEditViewController alloc] init];
            [[UIApplication sharedApplication].presentedNavigationController pushViewController:shareEditVC animated:YES];
            
        } else if (TDSpotlightTranslateRecordsSearchableItemJudger(identifier)) {
            // Translate records searchable item
            NSString *translateId = TDTranslateIdParserFromSpotlightRecordsSearchableItemIdentfier(identifier);
            TranslateDetailViewController *detail = [[TranslateDetailViewController alloc] initWithItemTranslateId:translateId];
            [[UIApplication sharedApplication].presentedNavigationController pushViewController:detail animated:YES];
        }
        
        return YES;
    }
    return YES;
}


- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    NSString *type = shortcutItem.type;
    if ([type isEqualToString:MBSpotlightFunctionSearchableItemId_QuickTranslate]) {
        TranslateDetailViewController *detail = [[TranslateDetailViewController alloc] init];
        [[UIApplication sharedApplication].presentedNavigationController pushViewController:detail animated:YES];
    } else if ([type isEqualToString:MBSpotlightFunctionSearchableItemId_PasteAndTranslate]) {
        NSString *pasteStr = [[UIPasteboard generalPasteboard].string stringByTrim];
        TranslateDetailViewController *detail = [[TranslateDetailViewController alloc] initWithInitialInputText:pasteStr];
        [[UIApplication sharedApplication].presentedNavigationController pushViewController:detail animated:YES];
    } else if ([type isEqualToString:MBSpotlightFunctionSearchableItemId_QuickShare]) {
        ShareEditViewController *shareEditVC = [[ShareEditViewController alloc] init];
        [[UIApplication sharedApplication].presentedNavigationController pushViewController:shareEditVC animated:YES];
    }
}


- (void)configureAppearance {
    
    // All view tint
    [[UIView appearance] setTintColor:[TDColorSpecs app_tint]];
    
    // NavigationBar
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[TDColorSpecs app_mainTextColor], NSFontAttributeName: [TDFontSpecs large]};
    [[UINavigationBar appearance] setBarTintColor:[TDColorSpecs app_cellColor]];
    
    // UIBarButtonItem
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[TDColorSpecs app_tint], NSFontAttributeName: [TDFontSpecs regular]} forState:UIControlStateNormal];
    
    // Table section header && footer
    UILabel *tableSectionHeaderFooterAppearance
    = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[UITableViewHeaderFooterView class]]];
    tableSectionHeaderFooterAppearance.textColor = [TDColorSpecs app_minorTextColor];
    tableSectionHeaderFooterAppearance.font = [TDFontSpecs regular];
    
    // Table
    UITableView *tableViewAppearance = [UITableView appearance];
    tableViewAppearance.backgroundColor = [TDColorSpecs app_pageBackground];
    tableViewAppearance.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableViewAppearance.separatorColor = [TDColorSpecs app_separator];
}

- (BOOL)openUrlIfNeed:(NSURL *)url {
    if (!url) return NO;

    NSLog(@"url: %@", url);
    
    if ([url.host isEqualToString:@"share"]) {
        // 分享
        NSDictionary *queryParams = [url queryWrapToDictionary];
        NSString *translateId = queryParams[@"tid"];
        NSString *init_lang = queryParams[@"init_lang"];
        if (translateId) {
            TDTextTranslateLanguage lang = init_lang?[init_lang integerValue]:TDTextTranslateLanguage_unkown;
            ShareEditViewController *shareEditVC = [[ShareEditViewController alloc] initWithTid:translateId init_lang:lang];
            
            [[UIApplication sharedApplication].presentedNavigationController pushViewController:shareEditVC animated:YES];
            return YES;
        }
    }
    
    return NO;
}

- (void)configureFunctionSpotlightSearchableItems {
    
    // set0 nil will use Spotlight icon in AppIconset
    NSData *iconData = nil;
    
    NSString *domainIdentifier = TDSpotlightFunctionSearchableItemsDomainIdentifier;
    NSString *contentType = (NSString *)kUTTypeText;
    
    NSMutableArray<CSSearchableItem*> *funcItems = [NSMutableArray<CSSearchableItem*> array];
    CSSearchableItemAttributeSet *attributeSet = nil;
    CSSearchableItem *searchableItem = nil;
    
    // 快速翻译
    attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:contentType];
    attributeSet.title = NSLocalizedStringFromTable(@"QUICK TRANSLATE", @"TinyT", nil);
    attributeSet.keywords = [NSLocalizedStringFromTable(@"QUICKTRANSLATE_KEYWORDS", @"TinyT", nil) componentsSeparatedByString:@","];
    attributeSet.thumbnailData = iconData;
    
    searchableItem = [[CSSearchableItem alloc] initWithUniqueIdentifier:MBSpotlightFunctionSearchableItemId_QuickTranslate domainIdentifier:domainIdentifier attributeSet:attributeSet];
    [funcItems addObject:searchableItem];
    
    // 粘贴并翻译
    attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:contentType];
    attributeSet.title = NSLocalizedStringFromTable(@"PASTE AND TRANSLATE", @"TinyT", nil);
    attributeSet.keywords = [NSLocalizedStringFromTable(@"PASTETRANSLATE_KEYWORDS", @"TinyT", nil) componentsSeparatedByString:@","];
    attributeSet.thumbnailData = iconData;
    
    searchableItem = [[CSSearchableItem alloc] initWithUniqueIdentifier:MBSpotlightFunctionSearchableItemId_PasteAndTranslate domainIdentifier:domainIdentifier attributeSet:attributeSet];
    [funcItems addObject:searchableItem];
    
    // 快速分享
    attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:contentType];
    
    attributeSet.title = NSLocalizedStringFromTable(@"QUICK SHARE", @"TinyT", nil);
    attributeSet.keywords = [NSLocalizedStringFromTable(@"QUICKSHARE_KEYWORDS", @"TinyT", nil) componentsSeparatedByString:@","];
    attributeSet.thumbnailData = iconData;
    
    searchableItem = [[CSSearchableItem alloc] initWithUniqueIdentifier:MBSpotlightFunctionSearchableItemId_QuickShare domainIdentifier:domainIdentifier attributeSet:attributeSet];
    [funcItems addObject:searchableItem];
    
    
    // Delete function spotlight searchable items before update them
    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithDomainIdentifiers:@[domainIdentifier] completionHandler:^(NSError *error) {
        [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:funcItems completionHandler:^(NSError * _Nullable error) {
            if(error) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }];
}

@end
