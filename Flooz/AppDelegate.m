//
//  AppDelegate.m
//  Flooz
//
//  Created by Olivier on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "Mixpanel.h"
#import "Branch.h"

#import "AppDelegate.h"
#import "AppDelegate+NVSBlurAppScreen.h"

#import <CoreTelephony/CTCallCenter.h>

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "FLTabBarController.h"
#import "FLPreset.h"
#import "IDMPhotoBrowser.h"
#import "HomeViewController.h"
#import "SplashViewController.h"
#import "AccountViewController.h"
#import "FriendsViewController.h"
#import "TimelineViewController.h"
#import "SecureCodeViewController.h"
#import "TransactionViewController.h"
#import "UICKeyChainStore.h"
#import "SignupNavigationController.h"
#import "UserViewController.h"
#import "FLNavigationController.h"
#import "CollectViewController.h"
#import "JTSAnimatedGIFUtility.h"
#import "NewFloozViewController.h"
#import "ABMediaView.h"

@interface AppDelegate() {
    NSDictionary *tmpUser;
    UIImage *tmpImage;
    NSDictionary *pendingData;
}

@property (nonatomic, retain) NSString *appUpdateURI;

@property (nonatomic, retain) UIWindow *tmpActionSheetWindow;
@property (nonatomic, retain) FLReport *currentReport;

@end

@implementation AppDelegate

@synthesize localIp;
@synthesize branchParam;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor customBackgroundHeader];
    [self.window makeKeyAndVisible];
    
    [self.window setTintColor:[UIColor customBlue]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [Fabric with:@[CrashlyticsKit]];
    [Crashlytics startWithAPIKey:@"4f18178e0b7894ec76bb6f01a60f34baf68acbf7"];
    
    [[ABMediaView sharedManager] setShouldCacheMedia:YES];
    [ABMediaView setPlaysAudioWhenPlayingMediaOnSilent:YES];
    [ABMediaView setPlaysAudioWhenStoppingMediaOnSilent:NO];
    [[ABMediaView sharedManager] setShouldPreloadVideoAndAudio:YES];

    [self loadBranchParams];
    
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if ([params count] > 0) {
            [branchParam addEntriesFromDictionary:params];
            
            if (branchParam[@"data"] && ![branchParam[@"data"] isBlank]) {
                NSDictionary *dataParam = [NSDictionary newWithJSONString:branchParam[@"data"]];
                
                if (dataParam) {
                    if (dataParam[@"login"]) {
                        NSString *token = dataParam[@"login"];
                        [[Flooz sharedInstance] loginWithToken:token];
                    }
                    
                    NSMutableDictionary *tmp = [pendingData mutableCopy];
                    if (tmp == nil)
                        tmp = [NSMutableDictionary new];
                    [tmp addEntriesFromDictionary:dataParam];
                    pendingData = tmp;
                    [self handlePendingData];
                }
            }
            [self saveBranchParams];
        }
    }];
    
#ifdef FLOOZ_DEV_LOCAL
    [self initLocalTesting];
#else
    [self launchRootController];
#endif
        
#ifdef FLOOZ_DEV_API
    [Mixpanel sharedInstanceWithToken:@"82c134b277474d6143decdc6ae73d5c9"];
#else
    [Mixpanel sharedInstanceWithToken:@"81df2d3dcfb7c866f37e78f1ad8aa1c4"];
#endif
    
    [[Mixpanel sharedInstance] identify:[FLHelper generateRandomString]];
    
    if (launchOptions[UIApplicationLaunchOptionsURLKey]) {
        NSURL *url = launchOptions[UIApplicationLaunchOptionsURLKey];
        
        if ([url.scheme isEqualToString:@"flooz"]) {
            if (url.host && ![url.host isBlank]) {
                NSString *host = url.host;
                NSDictionary *dic = [NSDictionary newWithJSONString:host];
                
                if (dic && dic[@"data"]) {
                    if (dic[@"data"][@"login"]) {
                        NSString *token = dic[@"data"][@"login"];
                        [[Flooz sharedInstance] loginWithToken:token];
                    }
                    
                    NSMutableDictionary *tmp = [pendingData mutableCopy];
                    if (tmp == nil)
                        tmp = [NSMutableDictionary new];
                    [tmp addEntriesFromDictionary:dic[@"data"]];
                    pendingData = tmp;
                }
            }
        }
    }
    
#ifndef FLOOZ_DEV_LOCAL
    if (!pendingData)
        pendingData = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
#endif
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)updateShortcutList {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && [self.window.traitCollection forceTouchCapability] == UIForceTouchCapabilityAvailable) {
        if ([Flooz sharedInstance].currentUser) {
            NSMutableArray *items = [NSMutableArray new];
            
            for (FLHomeButton* button in [Flooz sharedInstance].currentTexts.homeButtons) {
                UIApplicationShortcutItem *item = [[UIApplicationShortcutItem alloc] initWithType:button.title localizedTitle:button.title localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithTemplateImageName:button.defaultImg] userInfo:button.json];
                
                [items addObject:item];
            }
            
            [UIApplication sharedApplication].shortcutItems = items;
        } else {
            NSMutableArray *items = [NSMutableArray new];
            
            for (FLHomeButton* button in [Flooz sharedInstance].currentTexts.homeButtons) {
                UIApplicationShortcutItem *item = [[UIApplicationShortcutItem alloc] initWithType:button.title localizedTitle:button.title localizedSubtitle:button.subtitle icon:[UIApplicationShortcutIcon iconWithTemplateImageName:button.defaultImg] userInfo:button.json];
                
                [items addObject:item];
            }
            
            [UIApplication sharedApplication].shortcutItems = @[];
        }
    }
}

- (void)saveBranchParams {
    if (branchParam)
        [UICKeyChainStore setString:[branchParam jsonStringWithPrettyPrint:NO] forKey:kBranchData];
}

- (void)loadBranchParams {
    NSString *textData = [UICKeyChainStore stringForKey:kBranchData];
    if (textData) {
        branchParam = [[NSDictionary newWithJSONString:textData] mutableCopy];
    } else {
        branchParam = [NSMutableDictionary new];
    }
}

- (void)clearBranchParams {
    [UICKeyChainStore removeItemForKey:kBranchData];
    [branchParam removeAllObjects];
}

- (void)clearPendingData {
    pendingData = nil;
}

- (void)launchRootController {
    self.window.rootViewController = [SplashViewController new];
    
    if (!pendingData || !pendingData[@"login"]) {
        if (![[Flooz sharedInstance] autologin]) {
            HomeViewController *home = [HomeViewController new];
            self.window.rootViewController = home;
        }
    }
}

- (void)initLocalTesting {
    self.window.rootViewController = [SplashViewController new];
}

- (void)initTestingWithIP:(NSString *)ip {
    self.localIp = ip;
    
    [UICKeyChainStore setString:self.localIp forKey:kLocalURLData];
    
    if (![[Flooz sharedInstance] autologin]) {
        HomeViewController *home = [HomeViewController new];
        self.window.rootViewController = home;
    }
}

- (void)didConnected {
    
    FLUser *currentUser = [[Flooz sharedInstance] currentUser];
    
    [[Flooz sharedInstance] textObjectFromApi:nil failure:nil];
    [[Flooz sharedInstance] notificationsWithSuccess:nil failure:nil];
    
    [[Mixpanel sharedInstance] identify:currentUser.userId];
    
    [[Flooz sharedInstance] startSocket];
}

- (UIViewController *)prepareMainViewController {
    self.tabBarController = [FLTabBarController new];
    
    return self.tabBarController;
}

- (void)goToAccountViewController {
    [self askNotification];
    [self flipToViewController:[self prepareMainViewController]];
}

- (void)askNotification {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil]];
        [application registerForRemoteNotifications];
    }
    else {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    //    [oneSignal registerForPushNotifications];
}

- (void)flipToViewController:(UIViewController *)viewController {
    if ([[self currentController] presentingViewController]) {
        [[[self currentController] presentingViewController] dismissViewControllerAnimated:NO completion: ^{
            [self setRootViewController:viewController withTransition:UIViewAnimationOptionTransitionFlipFromLeft completion:NULL];
        }];
    }
    else {
        [self setRootViewController:viewController withTransition:UIViewAnimationOptionTransitionFlipFromLeft completion:NULL];
    }
}

- (void)setRootViewController:(UIViewController *)viewController
               withTransition:(UIViewAnimationOptions)transition
                   completion:(void (^)(BOOL finished))completion {
    UIViewController *oldViewController = self.window.rootViewController;
    [UIView transitionFromView:oldViewController.view
                        toView:viewController.view
                      duration:0.7f
                       options:(UIViewAnimationOptions)(UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionLayoutSubviews | transition)
                    completion: ^(BOOL finished) {
                        self.window.rootViewController = viewController;
                        
                        if (completion) {
                            completion(finished);
                        }
                    }];
}

- (void)clearSavedViewController {
    savedViewController = nil;
}

- (void)askForSecureCodeWithUser:(NSDictionary *)user {
    SecureCodeViewController *secureVC = [[SecureCodeViewController alloc] initWithUser:user];
    [[[self currentController] presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    [[self currentController] presentViewController:secureVC animated:YES completion:nil];
}

- (void)showResetPasswordWithUser:(NSDictionary*)user {
    SecureCodeViewController *secureVC = [[SecureCodeViewController alloc] initWithUser:user];
    [secureVC setCurrentSecureMode:SecureCodeModeChangePass];
    [[[self currentController] presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    [[self currentController] presentViewController:secureVC animated:YES completion:nil];
}

- (void)resetTuto:(Boolean)value {
    [[Flooz sharedInstance] saveSettingsObject:[NSNumber numberWithBool:value] withKey:kKeyTutoFlooz];
    [[Flooz sharedInstance] saveSettingsObject:[NSNumber numberWithBool:value] withKey:kKeyTutoTimelineFriends];
    [[Flooz sharedInstance] saveSettingsObject:[NSNumber numberWithBool:value] withKey:kKeyTutoTimelinePublic];
    [[Flooz sharedInstance] saveSettingsObject:[NSNumber numberWithBool:value] withKey:kKeyTutoTimelinePrivate];
    [[Flooz sharedInstance] saveSettingsObject:[NSNumber numberWithBool:value] withKey:kKeyTutoWelcome];
    [[Flooz sharedInstance] saveSettingsObject:[NSNumber numberWithBool:value] withKey:kSendContact];
}

- (void)showSignupWithUser:(NSDictionary *)user {
    NSMutableDictionary *userData = [NSMutableDictionary new];
    
    [userData setObject:[Mixpanel sharedInstance].distinctId forKey:@"distinctId"];
    
    [userData addEntriesFromDictionary:user];
    
    if (userData[@"fb"] && userData[@"fb"][@"id"])
        [userData setObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", userData[@"fb"][@"id"]] forKey:@"avatarURL"];
    
    if ([[self myTopViewController] isKindOfClass:[HomeViewController class]]) {
        HomeViewController *home = (HomeViewController*)[self myTopViewController];
        [home setUserDataForSignup:userData];
    }
}

- (void)showSignupAfterFacebookWithUser:(NSDictionary *)user {
    [signupNavigationController.controller.userDic addEntriesFromDictionary:user];
    [signupNavigationController.controller displayChanges];
}

#pragma mark -

- (void)didDisconnected {
    
    [[Mixpanel sharedInstance] identify:[FLHelper generateRandomString]];
    
    pendingData = nil;
    [Flooz sharedInstance].notificationsCount = @0;
    [self updateShortcutList];
    [self displayHome];
}

- (void)displayHome {
    savedViewController = nil;
    HomeViewController *home = [HomeViewController new];
    [self flipToViewController:home];
}

- (void)displayError:(NSError *)error {
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:lastErrorDate];
    
    if ((lastErrorCode == FLNetworkError) && (error.code == FLNetworkError) && seconds < 30) {
        return;
    }
    
    lastErrorDate = [NSDate date];
    lastErrorCode = error.code;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GLOBAL_ERROR", nil)
                                                    message:ERROR_LOCALIZED_DESCRIPTION((int)error.code)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil)
                                          otherButtonTitles:nil
                          ];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void)displayMessage:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style time:(NSNumber *)time delay:(NSNumber *)delay {
    _alertView = [FLAlertView new];
    [_alertView show:title content:content style:style time:time delay:delay andDictionnary:nil];
}

- (void)displayMessage:(FLAlert*)alert completion:(dispatch_block_t)completion {
    _alertView = [FLAlertView new];
    [_alertView show:alert completion:completion];
}

- (void)displayAlert:(NSString *)title content:(NSString *)content {
    if (!title || [title isBlank]) {
        title = NSLocalizedString(@"GLOBAL_ERROR", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:content delegate:nil cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil) otherButtonTitles:nil ];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void)noAccessToSettings {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Pas d'accès à vos contacts", nil)
                                                    message:NSLocalizedString(@"Vous n'avez pas laissé Flooz accéder à vos contacts, allez dans les réglages pour corriger ça", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil)
                                          otherButtonTitles:NSLocalizedString(@"Go", nil), nil
                          ];
    alert.tag = 22;
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 22) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    else if (alertView.tag == 42) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.appUpdateURI]];
    }
    else if (alertView.tag == 10) {
        if (buttonIndex == 1) {
            [[Flooz sharedInstance] reportContent:self.currentReport];
        }
    }
    else if (alertView.tag == 11) {
        if (buttonIndex == 1) {
            [[Flooz sharedInstance] blockUser:currentUserForMenu.userId];
        }
    }
}

#pragma mark -

- (void)applicationWillResignActive:(UIApplication *)application {
    [self nvs_blurPresentedView];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    CTCallCenter *callCenter = [[CTCallCenter alloc] init];
    if (!callCenter.currentCalls.count)
        [[Flooz sharedInstance] closeSocket];
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (!(application.applicationState == UIApplicationStateActive))
                [[Flooz sharedInstance] closeSocket];
        });
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEnterBackground object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
// Can't enable Flooz init if local, causing to skip the ip specification process
#ifndef FLOOZ_DEV_LOCAL
    if ([[Flooz sharedInstance] currentUser]) {
        [[Flooz sharedInstance] startSocket];
        [[Flooz sharedInstance] updateCurrentUserWithSuccess:^{}];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloadTimeline object:nil];
        if (pendingData && [Flooz sharedInstance].currentUser && [self isViewAfterAuthentication]) {
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [self handlePendingData];
            });
        }
        [self clearBranchParams];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEnterForeground object:nil];
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

#pragma mark - Facebook

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation])
        return YES;
    else if ([[Branch getInstance] handleDeepLink:url]) {
        return YES;
    } else {
        if ([url.scheme isEqualToString:@"flooz"]) {
            if (url.host && ![url.host isBlank]) {
                NSString *host = url.host;
                NSDictionary *dic = [NSDictionary newWithJSONString:host];
                
                if (dic && dic[@"data"]) {
                    if (dic[@"data"][@"login"]) {
                        NSString *token = dic[@"data"][@"login"];
                        [[Flooz sharedInstance] loginWithToken:token];
                    }
                    
                    NSMutableDictionary *tmp = [pendingData mutableCopy];
                    if (tmp == nil)
                        tmp = [NSMutableDictionary new];
                    [tmp addEntriesFromDictionary:dic[@"data"]];
                    pendingData = tmp;
                }
            }
        }
    }
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    
    [self nvs_unblurPresentedView];
    
#ifndef FLOOZ_DEV_LOCAL
    if (pendingData && [Flooz sharedInstance].currentUser && [self isViewAfterAuthentication]) {
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self handlePendingData];
        });
    }
#endif
}

- (BOOL)isViewAfterAuthentication {
    if (![[self myTopViewController] isKindOfClass:[SplashViewController class]] && ![[self myTopViewController] isKindOfClass:[SplashViewController class]] && ![[self myTopViewController] isKindOfClass:[SignupNavigationController class]])
        return YES;
    return NO;
}

#pragma mark - Shortcut List

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    NSMutableDictionary *tmp = [pendingData mutableCopy];
    if (tmp == nil)
        tmp = [NSMutableDictionary new];
    [tmp addEntriesFromDictionary:shortcutItem.userInfo];
    pendingData = tmp;
    
    [self handlePendingData];
}

#pragma mark - Notifications Push

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    _currentDeviceToken  = [NSString stringWithFormat:@"%@", deviceToken];
    _currentDeviceToken = [_currentDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    _currentDeviceToken = [_currentDeviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    _currentDeviceToken = [_currentDeviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAnswerAccessNotification object:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAnswerAccessNotification object:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
        return;
    
    NSMutableDictionary *tmp = [pendingData mutableCopy];
    if (tmp == nil)
        tmp = [NSMutableDictionary new];
    [tmp addEntriesFromDictionary:userInfo];
    pendingData = tmp;
    
    [self handlePendingData];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
        return;
    
    NSMutableDictionary *tmp = [pendingData mutableCopy];
    if (tmp == nil)
        tmp = [NSMutableDictionary new];
    [tmp addEntriesFromDictionary:userInfo];
    pendingData = tmp;
    
    [self handlePendingData];
}

- (void)handlePendingData {
#ifndef FLOOZ_DEV_LOCAL
    if (pendingData && [Flooz sharedInstance].currentUser && [self isViewAfterAuthentication]) {
        [self handlePushMessage:pendingData withApplication:nil];
        pendingData = nil;
    }
    [self clearBranchParams];
#endif
}

- (void)handlePushMessage:(NSDictionary *)userInfo withApplication:(UIApplication *)application {
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        if ([[Flooz sharedInstance] currentUser] && userInfo && [self isViewAfterAuthentication]) {
            [[Flooz sharedInstance] handleRequestTriggers:userInfo];
            [[Flooz sharedInstance] displayPopupMessage:userInfo];
        }
    });
}

#pragma mark - Image fullscreen

- (BOOL)showPreviewImage:(NSString *)imageNamed {
    
    NSString *key = [NSString stringWithFormat:@"preview-%@", imageNamed];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:key]) {
        return NO;
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
    
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMakeWithSize(self.window.frame.size)];
    [view addTarget:self action:@selector(removePreviewImage:) forControlEvents:UIControlEventTouchUpInside];
    
    [view setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
    [view setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateHighlighted];
    
    [self.window addSubview:view];
    
    return YES;
}

- (void)showPreviewImages:(NSArray *)imagesNamed {
    imagesForPreview = [imagesNamed mutableCopy];
    [self showNextPreviewImage];
}

- (void)showNextPreviewImage {
    NSString *imageNamed = [imagesForPreview firstObject];
    [imagesForPreview removeObjectAtIndex:0];
    
    [self showPreviewImage:imageNamed];
}

- (void)removePreviewImage:(UIView *)view {
    [view removeFromSuperview];
    
    if (imagesForPreview && [imagesForPreview count] > 0)
        [self showNextPreviewImage];
}

#pragma mark -

- (void)showReportMenu:(FLReport *)report {
    self.currentReport = report;
    
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending))
        [self createReportActionSheetInWindow:self.window];
    else
        [self createReportAlertController];
}

- (void)createReportAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MENU_QRCODE", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
    //        [self showQRCode];
    //    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MENU_REPORT_LINE", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
        [self showReportView];
    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewC:newAlert animated:YES completion:NULL];
}

- (void)createUserActionSheetInWindow:(UIWindow *)wind {
    UIActionSheet *actionSheet = actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    NSMutableArray *menus = [NSMutableArray new];
    
    if ([currentUserForMenu avatarURL]) {
        [menus addObject:NSLocalizedString(@"MENU_AVATAR", nil)];
    }
    
    if ([self isFriend]) {
        if (_canRemoveFriend) {
            [menus addObject:NSLocalizedString(@"MENU_REMOVE_FRIENDS", nil)];
            haveMenuFriend = YES;
        }
    }
    
    [menus addObject:NSLocalizedString(@"MENU_BLOCK_USER", nil)];
    
    [menus addObject:NSLocalizedString(@"MENU_REPORT_USER", nil)];
    
    for (NSString *menu in menus) {
        [actionSheet addButtonWithTitle:menu];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet setTag:2];
    
    [actionSheet showInView:wind];
}

- (void)createReportActionSheetInWindow:(UIWindow *)wind {
    UIActionSheet *actionSheet = actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    NSMutableArray *menus = [NSMutableArray new];
    
    //    [menus addObject:NSLocalizedString(@"MENU_QRCODE", nil)];
    [menus addObject:NSLocalizedString(@"MENU_REPORT_LINE", nil)];
    
    for (NSString *menu in menus) {
        [actionSheet addButtonWithTitle:menu];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet setTag:3];
    
    [actionSheet showInView:wind];
}

- (void)createActionSheetInWindow:(UIWindow *)wind {
    UIActionSheet *actionSheet = actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"MENU_NEW_FLOOZ", nil), currentUserForMenu.username], nil];
    NSMutableArray *menus = [NSMutableArray new];
    
    if (![self isFriend]) {
        [menus addObject:[NSString stringWithFormat:NSLocalizedString(@"MENU_ADD_FRIENDS", nil), currentUserForMenu.username]];
        haveMenuFriend = YES;
    }
    
    [menus addObject:NSLocalizedString(@"MENU_OTHER", nil)];
    
    for (NSString *menu in menus) {
        [actionSheet addButtonWithTitle:menu];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet setTag:1];
    
    [actionSheet showInView:wind];
    self.tmpActionSheetWindow = wind;
    
}

- (void)managerReportActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //    if (buttonIndex == 0) {
    //        [self showQRCode];
    //    } else if (buttonIndex == 1) {
    //        [self showReportView];
    //    }
    if (buttonIndex == 0) {
        [self showReportView];
    }
}

- (void)managerImageActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UIImageWriteToSavedPhotosAlbum(tmpImage, nil, nil, nil);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 3)
        [self managerReportActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    else if (actionSheet.tag == 4)
        [self managerImageActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
}

- (BOOL)isFriend {
    BOOL isFriend = NO;
    if ([[[[Flooz sharedInstance] currentUser] userId] isEqualToString:[currentUserForMenu userId]]) {
        isFriend = YES;
    }
    else {
        for (FLUser *friend in[[[Flooz sharedInstance] currentUser] friends]) {
            if ([[friend userId] isEqualToString:[currentUserForMenu userId]]) {
                isFriend = YES;
                break;
            }
        }
    }
    return isFriend;
}

- (void)showReportView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_REPORT", nil) message:(self.currentReport.reportType == ReportUser ? NSLocalizedString(@"MENU_REPORT_USER_CONTENT", nil) : NSLocalizedString(@"MENU_REPORT_LINE_CONTENT", nil)) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_NO", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_YES", nil), nil];
    alertView.tag = 10;
    [alertView show];
}

- (void)showQRCode {
    NSString *stringToEncode = @"http://www.google.com";
    
    CIImage *qrCode = [FLHelper createQRForString:stringToEncode];
    
    UIImage *qrCodeImg = [FLHelper createNonInterpolatedUIImageFromCIImage:qrCode withScale:2*[[UIScreen mainScreen] scale]];
    
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = qrCodeImg;
    imageInfo.referenceContentMode = UIViewContentModeScaleAspectFill;
    
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    imageViewer.interactionsDelegate = self;
    
    [imageViewer showFromViewController:[self myTopViewController] transition:JTSImageViewControllerTransition_FromOffscreen];
}

- (void)showBlockView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_BLOCK_USER", nil) message:NSLocalizedString(@"MENU_BLOCK_USER_CONTENT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_NO", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_YES", nil), nil];
    alertView.tag = 11;
    [alertView show];
}

- (void)showAvatarView:(UIImageView *)view withUrl:(NSURL *)urlImage {
    if (urlImage && ![urlImage.absoluteString isEqualToString:@"/img/fake.png"]) {
        if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:urlImage] || [[SDWebImageManager sharedManager] diskImageExistsForURL:urlImage]) {
            [[SDWebImageManager sharedManager] loadImageWithURL:urlImage options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                
                if ([JTSAnimatedGIFUtility imageURLIsAGIF:urlImage.absoluteString]) {
                    image = [JTSAnimatedGIFUtility animatedImageWithAnimatedGIFData:data];
                }
                
                if (image) {
                    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
                    imageInfo.image = image;
                    imageInfo.referenceRect = view.frame;
                    imageInfo.referenceView = view.superview;
                    imageInfo.referenceContentMode = UIViewContentModeScaleAspectFill;
                    
                    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                                           initWithImageInfo:imageInfo
                                                           mode:JTSImageViewControllerMode_Image
                                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
                    imageViewer.interactionsDelegate = self;
                    
                    [imageViewer showFromViewController:[self myTopViewController] transition:JTSImageViewControllerTransition_FromOriginalPosition];
                }
            }];
        } else {
            JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
            imageInfo.imageURL = urlImage;
            imageInfo.referenceRect = view.frame;
            imageInfo.referenceView = view.superview;
            imageInfo.referenceContentMode = UIViewContentModeScaleAspectFill;
            
            JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                                   initWithImageInfo:imageInfo
                                                   mode:JTSImageViewControllerMode_Image
                                                   backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
            imageViewer.interactionsDelegate = self;
            [imageViewer showFromViewController:[self myTopViewController] transition:JTSImageViewControllerTransition_FromOriginalPosition];
            
            [[SDWebImageManager sharedManager] loadImageWithURL:urlImage options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                
            }];
        }
    } else if (urlImage) {
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.image = [UIImage imageNamed:@"fake"];
        imageInfo.referenceRect = view.frame;
        imageInfo.referenceView = view.superview;
        imageInfo.referenceContentMode = UIViewContentModeScaleAspectFill;
        
        JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                               initWithImageInfo:imageInfo
                                               mode:JTSImageViewControllerMode_Image
                                               backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
        imageViewer.interactionsDelegate = self;
        
        [imageViewer showFromViewController:[self myTopViewController] transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
}

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer atRect:(CGRect)rect {
    tmpImage = imageViewer.image;
    UIActionSheet *actionSheet = actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    NSMutableArray *menus = [NSMutableArray new];
    
    [menus addObject:NSLocalizedString(@"SAVE_IMAGE", nil)];
    
    for (NSString *menu in menus) {
        [actionSheet addButtonWithTitle:menu];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet setTag:4];
    
    [actionSheet showInView:self.window];
}

- (void)showNewTransactionController:(FLUser *)user transactionType:(NSUInteger)transactionType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_formSheet.presentedFSViewController) {
            [[self currentController] mz_dismissFormSheetControllerAnimated:NO completionHandler: ^(MZFormSheetController *formSheetController) {
                FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[[NewFloozViewController alloc] initWithTransactionType:transactionType user:user]];
                [self.tabBarController presentViewController:controller animated:YES completion:NULL];
            }];
        } else {
            FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[[NewFloozViewController alloc] initWithTransactionType:transactionType user:user]];
            [self.tabBarController presentViewController:controller animated:YES completion:NULL];
        }
    });
}

- (void)showFriendsController {
    [[Flooz sharedInstance] updateCurrentUser];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissControllersAnimated:YES completion: ^{
            [self popToMainView];
            FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[FriendsViewController new]];
            [self.tabBarController presentViewController:controller animated:YES completion:NULL];
        }];
    });
}

- (void)showEditProfil {
    [[Flooz sharedInstance] updateCurrentUser];
    [self dismissControllersAnimated:YES completion: ^{
        [((FLNavigationController*)self.tabBarController.viewControllers[4]) popToRootViewControllerAnimated:NO];
        [self.tabBarController setSelectedIndex:4];
    }];
}

- (void)popToMainView {
    [(UINavigationController*)self.tabBarController.selectedViewController popViewControllerAnimated:YES];
}

- (void)lockForUpdate:(NSString *)updateUrl {
    self.appUpdateURI = updateUrl;
    
    [UIView transitionWithView:self.window duration:0.7 options:(UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionAllowAnimatedContent)
                    animations: ^{ self.window.rootViewController = [SplashViewController new]; } completion: ^(BOOL finished)
     {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GLOBAL_UPDATE", nil) message:NSLocalizedString(@"MSG_UPDATE", nil)
                                                        delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"BTN_UPDATE", nil), nil];
         [alert setTag:42];
         dispatch_async(dispatch_get_main_queue(), ^{
             [alert show];
         });
     }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    if (location.y > 0 && location.y < 20) {
        [self touchStatusBar];
    }
}

- (void)touchStatusBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTouchStatusBarClick object:nil];
}

- (BOOL)shouldRefreshWithKey:(NSString *)keyUpdate {
    BOOL good = YES;
    
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:keyUpdate];
    if ([lastUpdate isKindOfClass:[NSDate class]]) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:lastUpdate];
        
        BOOL goodTime = (time > (NSTimeInterval)REFRESH_INTERVAL);
        good = (goodTime || _canRefresh);
        _canRefresh = NO;
    }
    return good;
}

- (void)displayMailWithMessage:(NSString *)message object:(NSString *)object recipients:(NSArray *)recipient andMessageError:(NSString *)messageError inViewController:(UIViewController *)vc {
    viewControllerForPopup = vc;
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        [mailComposer setMailComposeDelegate:self];
        [mailComposer.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor] }];
        
        [mailComposer setToRecipients:recipient];
        [mailComposer setMessageBody:message isHTML:NO];
        [mailComposer setSubject:object];
        
        [viewControllerForPopup presentViewController:mailComposer animated:YES completion: ^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    }
    else {
        [appDelegate displayMessage:NSLocalizedString(@"ALERT_NO_MAIL_TITLE", nil) content:messageError style:FLAlertViewStyleInfo time:nil delay:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [viewControllerForPopup dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    viewControllerForPopup = nil;
}

#pragma mark - presented helpers

- (void)presentViewC:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion {
    [self.myTopViewController presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (UIViewController *)myTopViewController {
    if (_formSheet.presentedFSViewController) {
        return _formSheet.presentedFSViewController;
    }
    return self.currentController;
}

- (UIViewController *)currentController {
    UIViewController *currentController = self.window.rootViewController;
    
    while ([currentController presentedViewController]) {
        currentController = [currentController presentedViewController];
    }
    
    return currentController;
}

- (void)dismissFormSheetAnimated:(BOOL)animated {
    [[self currentController] mz_dismissFormSheetControllerAnimated:animated completionHandler: ^(MZFormSheetController *formSheetController) {
        _formSheet = nil;
    }];
}

- (void)dismissControllersAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self dismissFormSheetAnimated:animated];
    if ([self.window.rootViewController presentedViewController]) {
        [self.window.rootViewController dismissViewControllerAnimated:animated completion: ^{
            if (completion) {
                completion();
            }
        }];
    }
    else {
        if (completion) {
            completion();
        }
    }
}

#pragma mark -

- (void)showUser:(FLUser *)user inController:(UIViewController*)vc {
    [self showUser:user inController:vc completion:nil];
}

- (void)showUser:(FLUser *)user inController:(UIViewController*)vc completion:(dispatch_block_t)completion {
    if (user.json[@"isCactus"] && [user.json[@"isCactus"] boolValue])
        return;
    
    if (!vc) {
        vc = [self myTopViewController];
    }
    
    if ([vc isKindOfClass:[FLTabBarController class]]) {
        vc = [((FLTabBarController *)vc) selectedViewController];
    }
    
    if ([vc isKindOfClass:[FLNavigationController class]]) {
        UIViewController *v = [((FLNavigationController *)vc) visibleViewController];
        if ([v isKindOfClass:[UserViewController class]]) {
            UserViewController *u = (UserViewController *)v;
            
            if ([u.currentUser.userId isEqualToString:user.userId]) {
                [u shakeView];
                return;
            }
        }
    }
    
    if ([vc isKindOfClass:[UserViewController class]]) {
        UserViewController *u = (UserViewController *)vc;
        
        if ([u.currentUser.userId isEqualToString:user.userId]) {
            [u shakeView];
            return;
        }
    }
    
    if ([user.userId isEqualToString:[Flooz sharedInstance].currentUser.userId])
        user = [Flooz sharedInstance].currentUser;
    
    UserViewController *controller;
    
    controller = [[UserViewController alloc] initWithUser:user];
    
    if ([vc isKindOfClass:FLNavigationController.class])
        [((FLNavigationController*)vc) pushViewController:controller animated:YES completion:completion];
    else if (vc.navigationController != nil)
        [((FLNavigationController*)vc.navigationController) pushViewController:controller animated:YES completion:completion];
    else
        [vc presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:completion];
}

- (void)showTransaction:(FLTransaction *)transaction inController:(UIViewController*)vc withIndexPath:(NSIndexPath *)indexPath focusOnComment:(BOOL)focus {
    [self showTransaction:transaction inController:vc withIndexPath:indexPath focusOnComment:focus completion:nil];
}

- (void)showTransaction:(FLTransaction *)transaction inController:(UIViewController*)vc withIndexPath:(NSIndexPath *)indexPath focusOnComment:(BOOL)focus completion:(dispatch_block_t)completion {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCancelTimer object:nil];
    _lastTransactionID = transaction.transactionId;
    
    if (!vc) {
        vc = [self myTopViewController];
    }
    
    if ([vc isKindOfClass:[FLTabBarController class]]) {
        vc = [((FLTabBarController *)vc) selectedViewController];
    }
    
    if ([vc isKindOfClass:[FLNavigationController class]]) {
        UIViewController *current = [(FLNavigationController*)vc topViewController];
        if ([current isKindOfClass:[TransactionViewController class]]) {
            if ([[(TransactionViewController*)current currentId] isEqualToString:transaction.transactionId]) {
                [(TransactionViewController*)current refreshTransaction];
                return;
            }
        }
    } else if ([vc isKindOfClass:[CollectViewController class]]) {
        if ([[(TransactionViewController*)vc currentId] isEqualToString:transaction.transactionId]) {
            [(TransactionViewController*)vc refreshTransaction];
            return;
        }
    }
    
    TransactionViewController *controller;
    
    controller = [[TransactionViewController alloc] initWithTransaction:transaction indexPath:indexPath];
    if ([vc conformsToProtocol:@protocol(TransactionCellDelegate)]) {
        controller.delegateController = (UIViewController <TransactionCellDelegate> *)vc;
    }
    
    if (focus) {
        [controller focusOnComment:@YES];
    }
    
    if ([vc isKindOfClass:FLNavigationController.class])
        [((FLNavigationController*)vc) pushViewController:controller animated:YES completion:completion];
    else if (vc.navigationController != nil)
        [((FLNavigationController*)vc.navigationController) pushViewController:controller animated:YES completion:completion];
    else
        [vc presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:completion];
}

- (void)showPot:(FLTransaction *)transaction inController:(UIViewController*)vc withIndexPath:(NSIndexPath *)indexPath focusOnComment:(BOOL)focus {
    [self showPot:transaction inController:vc withIndexPath:indexPath focusOnComment:focus completion:nil];
}

- (void)showPot:(FLTransaction *)transaction inController:(UIViewController*)vc withIndexPath:(NSIndexPath *)indexPath focusOnComment:(BOOL)focus completion:(dispatch_block_t)completion {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCancelTimer object:nil];
    _lastTransactionID = transaction.transactionId;
    
    if (!vc) {
        vc = [self myTopViewController];
    }
    
    if ([vc isKindOfClass:[FLTabBarController class]]) {
        vc = [((FLTabBarController *)vc) selectedViewController];
    }
    
    if ([vc isKindOfClass:[FLNavigationController class]]) {
        UIViewController *current = [(FLNavigationController*)vc topViewController];
        if ([current isKindOfClass:[CollectViewController class]]) {
            CollectViewController *collectController = (CollectViewController*)current;
            if ([[collectController currentId] isEqualToString:transaction.transactionId]) {
                [collectController refreshTransaction];
                return;
            }
        }
    } else if ([vc isKindOfClass:[CollectViewController class]]) {
        CollectViewController *collectController = (CollectViewController*)vc;
        if ([[collectController currentId] isEqualToString:transaction.transactionId]) {
            [collectController refreshTransaction];
            return;
        }
    }
    
    CollectViewController *controller;
    
    controller = [[CollectViewController alloc] initWithTransaction:transaction indexPath:indexPath];
    if ([vc conformsToProtocol:@protocol(TransactionCellDelegate)]) {
        controller.delegateController = (UIViewController <TransactionCellDelegate> *)vc;
    }
    
    if (focus) {
        [controller focusOnComment:@YES];
    }
    
    if ([vc isKindOfClass:FLNavigationController.class])
        [((FLNavigationController*)vc) pushViewController:controller animated:YES completion:completion];
    else if (vc.navigationController != nil)
        [((FLNavigationController*)vc.navigationController) pushViewController:controller animated:YES completion:completion];
    else
        [vc presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:completion];
}

- (UIWindow *)topWindow {
    if (self.formSheet.formSheetWindow && [self.formSheet.formSheetWindow isKeyWindow])
        return self.formSheet.formSheetWindow;
    else if ([self.window isKeyWindow])
        return self.window;
    else
        return [UIApplication sharedApplication].keyWindow;
}

@end
