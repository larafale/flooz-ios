//
//  AppDelegate.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "Mixpanel.h"
#import <Crashlytics/Crashlytics.h>
#import <UAAppReviewManager.h>

#import "AppDelegate.h"

#import "FLPreset.h"
#import "FLPopupReport.h"
#import "IDMPhotoBrowser.h"
#import "TutoViewController.h"
#import "HomeViewController.h"
#import "SignupViewController.h"
#import "SplashViewController.h"
#import "InviteViewController.h"
#import "AccountViewController.h"
#import "FriendsViewController.h"
#import "TimelineViewController.h"
#import "SecureCodeViewController.h"
#import "FirstLaunchViewController.h"
#import "TransactionViewController.h"
#import "AccountProfilViewController.h"
#import "NewTransactionViewController.h"

#ifdef TARGET_IPHONE_SIMULATOR
#import <PonyDebugger/PonyDebugger.h>
#endif

@interface AppDelegate()

@property (nonatomic, retain) NSString *appUpdateURI;

@property (nonatomic, retain) UIWindow *tmpActionSheetWindow;
@property (nonatomic, retain) FLReport *currentReport;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor customBackground];
    [self.window makeKeyAndVisible];
    
    _alertView = [FLAlertView new];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [Crashlytics startWithAPIKey:@"4f18178e0b7894ec76bb6f01a60f34baf68acbf7"];
    
    [self launchRootController];
    
    // initialisation de MagicalRecord
    // Pony Debugger
#ifdef PONY_D
#ifdef TARGET_IPHONE_SIMULATOR
    PDDebugger *debugger = [PDDebugger defaultInstance];
    [debugger connectToURL:[NSURL URLWithString:@"ws://localhost:9000/device"]];
    [debugger enableNetworkTrafficDebugging];
    [debugger forwardAllNetworkTraffic];
    [debugger enableViewHierarchyDebugging];
#endif
#endif
    
#ifdef FLOOZ_DEV_API
    [Mixpanel sharedInstanceWithToken:@"82c134b277474d6143decdc6ae73d5c9"];
#else
    [Mixpanel sharedInstanceWithToken:@"86108691338079db55b5fac30140d895"];
#endif
    
    [[Mixpanel sharedInstance] identify:[FLHelper generateRandomString]];
        
    [self handlePushMessage:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] withApplication:application];
    
    return YES;
}

- (void)launchRootController {
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[SplashViewController new]];
    
    if (![[Flooz sharedInstance] autologin]) {
        HomeViewController *home = [HomeViewController new];
        self.window.rootViewController = home;
    }
}

- (void)didConnected {
    
    FLUser *currentUser = [[Flooz sharedInstance] currentUser];
    
    [[Mixpanel sharedInstance] identify:currentUser.userId];
    
    [[Flooz sharedInstance] startSocket];
}

- (UIViewController *)prepareMainViewController {
    TimelineViewController *homePage = [TimelineViewController new];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homePage];
    [navController.navigationBar setTranslucent:NO];
    [navController.navigationBar setBarTintColor:[UIColor customBackgroundHeader]];
    [navController.navigationBar setTintColor:[UIColor whiteColor]];
    [navController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         [UIColor customBlue], NSForegroundColorAttributeName,
                                                         [UIFont customTitleBook:16.0], NSFontAttributeName, nil]];
    
    self.revealSideViewController = [[FLRevealContainerViewController alloc] initWithRootViewController:navController];
    self.revealSideViewController.delegate = self;
    
    return self.revealSideViewController;
}

- (void)goToAccountViewController {
    if (!savedViewController) {
        savedViewController = [self prepareMainViewController];
    }
    
    [self askNotification];
    [self flipToViewController:savedViewController];
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

- (void)showRequestInvitationCodeWithUser:(NSDictionary *)user {
    InviteViewController *invitVC = [[InviteViewController  alloc] initWithUser:user];
    [[[self currentController] presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    [[self currentController] presentViewController:[[FLNavigationController alloc] initWithRootViewController:invitVC] animated:YES completion:nil];
}

- (void)showSignupWithUser:(NSDictionary *)user {
    [[[self currentController] presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    SignupSMSViewController *controller = [SignupSMSViewController new];
    signupNavigationController.controller.userDic = [user mutableCopy];
    [signupNavigationController.controller.userDic setObject:[Mixpanel sharedInstance].distinctId forKey:@"distinctId"];
    [signupNavigationController pushViewController:controller animated:YES];
}

- (void)showSignupAfterFacebookWithUser:(NSDictionary *)user {
    [signupNavigationController.controller.userDic addEntriesFromDictionary:user];
    [signupNavigationController.controller displayChanges];
}

#pragma mark -

- (void)didDisconnected {
    
    [[Mixpanel sharedInstance] identify:[FLHelper generateRandomString]];
    
    [self displayHome];
}

- (void)displayHome {
    HomeViewController *home = [HomeViewController new];
    [self flipToViewController:home];
}

- (void)displaySignin {
    signupNavigationController = [[SignupNavigationController alloc] initWithRootViewController:[SignupPhoneViewController new]];
    [self flipToViewController:signupNavigationController];
}

- (void)displaySignupAtPage:(SignupOrderPage)index {
    firstVC = [[FirstLaunchViewController alloc] initWithSpecificPage:index];
    [self flipToViewController:firstVC];
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
    [_alertView show:title content:content style:style time:time delay:delay andDictionnary:nil];
}

- (void)displayMessage:(FLAlert*)alert {
    [_alertView show:alert];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Pas accès à vos contacts", nil)
                                                    message:NSLocalizedString(@"Vous n'avez pas laissez Flooz accéder à vos contacts, allez dans les réglages pour corriger ça", nil)
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
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[Flooz sharedInstance] closeSocket];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Facebook

- (void)facebookSessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
    // WARNING erreur code 2 http://stackoverflow.com/questions/20657780/ios-facebook-sdk-error-domain-com-facebook-sdk-code-2-and-code-7
    if (error) {
        [[Flooz sharedInstance] hideLoadView];
        [appDelegate displayMessage:nil content:[error description] style:FLAlertViewStyleError time:nil delay:nil];
    }
    
    if (!error && state == FBSessionStateOpen) {
        [[Flooz sharedInstance] didConnectFacebook];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
        // If the session is closed
        // Show the user the logged-out UI
        //        [self userLoggedOut];
    }
    
    [[Flooz sharedInstance] hideLoadView];
    if (error) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [FBAppCall handleDidBecomeActive];
    
    if ([[Flooz sharedInstance] currentUser]) {
        [[Flooz sharedInstance] startSocket];
        [[Flooz sharedInstance] updateCurrentUserWithSuccess:^{}];
    }
}

#pragma mark - Notifications Push

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAnswerAccessNotification object:nil];
    _currentDeviceToken  = [NSString stringWithFormat:@"%@", deviceToken];
    _currentDeviceToken = [_currentDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    _currentDeviceToken = [_currentDeviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    _currentDeviceToken = [_currentDeviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAnswerAccessNotification object:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
        return;
    
    [self handlePushMessage:userInfo withApplication:application];
}

- (void)handlePushMessage:(NSDictionary *)userInfo withApplication:(UIApplication *)application {
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        if ([[Flooz sharedInstance] currentUser] && userInfo) {
            self.window.rootViewController = [self prepareMainViewController];
            
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

- (void)showTutoPage:(TutoPage)tutoPage inController:(UIViewController*)vc {
    TutoViewController *tuto = [[TutoViewController alloc] initWithTutoPage:tutoPage];
    
    if (![tuto hasAlreadySawTuto]) {
        _formSheet = [[MZFormSheetController alloc] initWithViewController:tuto];
        _formSheet.presentedFormSheetSize = CGSizeMake(PPScreenWidth(), PPScreenHeight());
        _formSheet.transitionStyle = MZFormSheetTransitionStyleFade;// MZFormSheetTransitionStyleSlideFromBottom;
        _formSheet.shouldDismissOnBackgroundViewTap = YES;
        _formSheet.shouldCenterVertically = YES;
        _formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsDoNothing;
        _formSheet.shadowRadius = 0.0;
        [[MZFormSheetController sharedBackgroundWindow] setBackgroundColor:[UIColor clearColor]];
        
        [vc mz_presentFormSheetController:_formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) { }];
    }
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

- (void)showMenuForUser:(FLUser *)user imageView:(UIView *)imageView {
    [self showMenuForUser:user imageView:imageView canRemoveFriend:NO];
}

- (void)showMenuForUser:(FLUser *)user imageView:(UIView *)imageView canRemoveFriend:(BOOL)canRemoveFriend {
    [self showMenuForUser:user imageView:imageView canRemoveFriend:canRemoveFriend inWindow:self.window];
}

- (void)showMenuForUser:(FLUser *)user imageView:(UIView *)imageView canRemoveFriend:(BOOL)canRemoveFriend inWindow:(UIWindow *)window {
    if (!user || [[user userId] isEqualToString:[[[Flooz sharedInstance] currentUser] userId]] ||
        ![user username] || ![user fullname] || [user.username isEqualToString:@"flooz"])
        return;
    
    currentUserForMenu = user;
    currentImageView = imageView;
    haveMenuFriend = NO;
    _canRemoveFriend = canRemoveFriend;
    
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending))
        [self createActionSheetInWindow:window];
    else
        [self createAlertController];
}

- (void)createAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"MENU_NEW_FLOOZ", nil), currentUserForMenu.username] style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) { [self showNewTransactionController:currentUserForMenu transactionType:TransactionTypePayment]; }]];
    
    if (![self isFriend]) {
        haveMenuFriend = YES;
        [newAlert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"MENU_ADD_FRIENDS", nil), currentUserForMenu.username] style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] friendAcceptSuggestion:[currentUserForMenu userId] success: ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoveFriend object:nil];
            }];
        }]];
    }
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MENU_OTHER", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self createUserAlertController];
    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewC:newAlert animated:YES completion:NULL];
}

- (void)createUserAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([currentUserForMenu avatarURL]) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MENU_AVATAR", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            NSURL *urlImage = [NSURL URLWithString:[currentUserForMenu avatarURL]];
            [self showAvatarView:currentImageView withUrl:urlImage];
        }]];
    }
    
    if ([self isFriend]) {
        if (_canRemoveFriend) {
            haveMenuFriend = YES;
            [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MENU_REMOVE_FRIENDS", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
                [[Flooz sharedInstance] showLoadView];
                [[Flooz sharedInstance] friendRemove:[currentUserForMenu userId] success: ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoveFriend object:nil];
                }];
            }]];
        }
    }
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MENU_BLOCK_USER", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
        [self showBlockView];
    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MENU_REPORT_USER", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
        self.currentReport = [[FLReport alloc] initWithType:ReportUser id:currentUserForMenu.userId];
        [self showReportView];
    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewC:newAlert animated:YES completion:NULL];
}

- (void)createReportAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
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

- (void)managerGlobalActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^friendMenu)(void) = ^(void) {
        [[Flooz sharedInstance] showLoadView];
        if ([self isFriend]) {
            [[Flooz sharedInstance] friendRemove:[currentUserForMenu userId] success: ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoveFriend object:nil];
            }];
        }
        else {
            [[Flooz sharedInstance] friendAcceptSuggestion:[currentUserForMenu userId] success: ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoveFriend object:nil];
            }];
        }
    };
    
    if (buttonIndex == 0) {
        [self showNewTransactionController:currentUserForMenu transactionType:TransactionTypePayment];
    }
    else if (buttonIndex == 1 && haveMenuFriend) {
        friendMenu();
    }
    else if (buttonIndex == 1 || (buttonIndex == 2 && haveMenuFriend)) {
        [self createUserActionSheetInWindow:self.tmpActionSheetWindow];
    }
    self.tmpActionSheetWindow = nil;
}

- (void)managerUserActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^friendMenu)(void) = ^(void) {
        [[Flooz sharedInstance] showLoadView];
        if ([self isFriend]) {
            [[Flooz sharedInstance] friendRemove:[currentUserForMenu userId] success: ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoveFriend object:nil];
            }];
        }
        else {
            [[Flooz sharedInstance] friendAcceptSuggestion:[currentUserForMenu userId] success: ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRemoveFriend object:nil];
            }];
        }
    };
    
    void (^showAvatar)(void) = ^(void) {
        NSURL *urlImage = [NSURL URLWithString:[currentUserForMenu avatarURL]];
        [self showAvatarView:currentImageView withUrl:urlImage];
    };
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"MENU_AVATAR", nil)]) {
        showAvatar();
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"MENU_REMOVE_FRIENDS", nil)]) {
        friendMenu();
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"MENU_BLOCK_USER", nil)]) {
        [self showBlockView];
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"MENU_REPORT_USER", nil)]) {
        self.currentReport = [[FLReport alloc] initWithType:ReportUser id:currentUserForMenu.userId];
        [self showReportView];
    }
}

- (void)managerReportActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self showReportView];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1)
        [self managerGlobalActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    if (actionSheet.tag == 2)
        [self managerUserActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    if (actionSheet.tag == 3)
        [self managerReportActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
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

- (void)showBlockView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_BLOCK_USER", nil) message:NSLocalizedString(@"MENU_BLOCK_USER_CONTENT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_NO", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_YES", nil), nil];
    alertView.tag = 11;
    [alertView show];
}

- (void)showAvatarView:(UIView *)view withUrl:(NSURL *)urlImage {
    if (urlImage) {
        IDMPhotoBrowser *controller = [[IDMPhotoBrowser alloc] initWithPhotoURLs:@[urlImage] animatedFromView:view];
        controller.displayActionButton = NO;
        [self presentViewC:controller animated:YES completion:NULL];
    }
}

- (void)showNewTransactionController:(FLUser *)user transactionType:(NSUInteger)transactionType {
    [self dismissControllersAnimated:YES completion: ^{
        [self popToMainView];
        FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[[NewTransactionViewController alloc] initWithTransactionType:transactionType user:currentUserForMenu]];
        [self.revealSideViewController presentViewController:controller animated:YES completion:NULL];
    }];
}

- (void)showPresetNewTransactionController:(FLPreset *)preset {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissControllersAnimated:YES completion: ^{
            [self popToMainView];
            FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[[NewTransactionViewController alloc] initWithPreset:preset]];
            [self.revealSideViewController presentViewController:controller animated:YES completion:NULL];
        }];
    });
}

- (void)showFriendsController {
    [[Flooz sharedInstance] updateCurrentUser];
    [self dismissControllersAnimated:YES completion: ^{
        [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionRight withOffset:PADDING_NAV animated:YES];
    }];
}

- (void)showEditProfil {
    [[Flooz sharedInstance] updateCurrentUser];
    [self dismissControllersAnimated:YES completion: ^{
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[AccountProfilViewController new]];
        [self.revealSideViewController presentViewController:controller animated:YES completion:NULL];
    }];
}

- (void)popToMainView {
    [self.revealSideViewController popViewControllerAnimated:YES];
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

- (void)showTransaction:(FLTransaction *)transaction inController:(UIViewController*)vc withIndexPath:(NSIndexPath *)indexPath focusOnComment:(BOOL)focus {
    
    [[Flooz sharedInstance] readTransactionWithId:transaction.transactionId success:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCancelTimer object:nil];
    if (_formSheet.presentedFSViewController) {
        if ([_lastTransactionID isEqualToString:transaction.transactionId]) {
            return;
        }
        
        [[self currentController] mz_dismissFormSheetControllerAnimated:NO completionHandler: ^(MZFormSheetController *formSheetController) {
            _formSheet = nil;
        }];
    }
    _lastTransactionID = transaction.transactionId;
    if (!vc) {
        vc = [self myTopViewController];
    }
    
    CGSize size = CGSizeMake(PPScreenWidth() - 52.0f, PPScreenHeight() - 45.0f * 2.0f);
    if (IS_IPHONE4) {
        size = CGSizeMake(PPScreenWidth(), PPScreenHeight());
    }
    TransactionViewController *controller;
    
    controller = [[TransactionViewController alloc] initWithTransaction:transaction indexPath:indexPath withSize:size];
    if ([vc conformsToProtocol:@protocol(TransactionCellDelegate)]) {
        controller.delegateController = (UIViewController <TransactionCellDelegate> *)vc;
    }
    
    if (focus) {
        [controller focusOnComment];
    }
    
    _formSheet = [[MZFormSheetController alloc] initWithViewController:controller];
    _formSheet.presentedFormSheetSize = size;
    _formSheet.transitionStyle = MZFormSheetTransitionStyleBounce;// MZFormSheetTransitionStyleSlideFromBottom;
    _formSheet.shadowRadius = 2.0;
    _formSheet.shadowOpacity = 0.3;
    _formSheet.shouldDismissOnBackgroundViewTap = YES;
    _formSheet.shouldCenterVertically = YES;
    _formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsDoNothing;
    
    [vc mz_presentFormSheetController:_formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
}

- (UIWindow *)topWindow {
    if (self.formSheet.formSheetWindow) {
        return appDelegate.formSheet.formSheetWindow;
    }
    else {
        return appDelegate.window;
    }
}

#pragma mark - PPRevealSideViewControllerDelegate

- (void)handleOpenClosedEventsAndEnableSubviews:(BOOL)enable {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCancelTimer object:nil];
    UINavigationController *nav = (UINavigationController *)_revealSideViewController.rootViewController;
    for (UIView *vi in[nav.visibleViewController.view subviews])  // this is the best way to keep functional the gestures
        [vi setUserInteractionEnabled:enable];
}

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller willPopToController:(UIViewController *)centerController {
    [self.revealSideViewController.view endEditing:YES];
    [self handleOpenClosedEventsAndEnableSubviews:YES]; // Just to be sure in case we reuse the view
}

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didPopToController:(UIViewController *)centerController {
    [self handleOpenClosedEventsAndEnableSubviews:YES];
}

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didPushController:(UIViewController *)pushedController {
    [self handleOpenClosedEventsAndEnableSubviews:NO];
}

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didManuallyMoveCenterControllerWithOffset:(CGFloat)offset {
    CGFloat xRight = PADDING_NAV - (PPScreenWidth() / 2 - PADDING_NAV - 10.0f) + offset / 2;
    xRight = MAX(0, MIN(xRight, PPScreenWidth()));
    [self.revealSideViewController.rightViewController.view setXOrigin:xRight];
    
    CGFloat xLeft = - offset / 2 + 30.0f;
    xLeft = MIN(0, xLeft);
    [self.revealSideViewController.leftViewController.view setXOrigin:xLeft];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCancelTimer object:nil];
}

@end