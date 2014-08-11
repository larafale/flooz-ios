//
//  AppDelegate.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "AppDelegate.h"

#import "FLContainerViewController.h"

#import "SplashViewController.h"

#import "HomeViewController.h"
#import "SignupViewController.h"
#import "LoginViewController.h"

#import "EventsViewController.h"
#import "TimelineViewController.h"
#import "AccountViewController.h"

#import "SecureCodeViewController.h"
#import <Analytics/Analytics.h>

#import "TransactionViewController.h"
#import "EventViewController.h"
#import "FriendsViewController.h"

#import "NewTransactionViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
    self.window.backgroundColor = [UIColor customBackground];
    [self.window makeKeyAndVisible];
    
    alertView = [FLAlertView new];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // Doit etre un FLNavigationController, sinon dans le cas ou appel secureCode la vue ne peut pas etre push
    self.window.rootViewController = [[FLNavigationController alloc] initWithRootViewController:[SplashViewController new]];
    
    if(![[Flooz sharedInstance] autologin]){
        self.window.rootViewController = [[FLNavigationController alloc] initWithRootViewController:[HomeViewController new]];
    }

#ifdef FLOOZ_DEV_API
    NSLog(@"API DEV");
#else
    NSLog(@"API PROD");
    [SEGAnalytics setupWithConfiguration:[SEGAnalyticsConfiguration configurationWithWriteKey:@"2jcb70koii"]];
#endif
    
    return YES;
}

- (void)didConnected
{    
    NSMutableDictionary *params = [@{
                             @"record":[[[Flooz sharedInstance] currentUser] record],
                             @"id": [[[Flooz sharedInstance] currentUser] userId],
                             @"username": [[[Flooz sharedInstance] currentUser] username],
                             @"phone": [[[Flooz sharedInstance] currentUser] phone]
                             } mutableCopy];
    
    if([[[Flooz sharedInstance] currentUser] email]){
        params[@"email"] = [[[Flooz sharedInstance] currentUser] email];
    }
    
    if([[[Flooz sharedInstance] currentUser] firstname]){
        params[@"firstName"] = [[[Flooz sharedInstance] currentUser] firstname];
    }
    
    if([[[Flooz sharedInstance] currentUser] lastname]){
        params[@"lastName"] = [[[Flooz sharedInstance] currentUser] lastname];
    }
    
#ifndef FLOOZ_DEV_API
        [[SEGAnalytics sharedAnalytics] identify:[[[Flooz sharedInstance] currentUser] userId]
                                   traits:params];
#endif
    
    if(!savedViewController){
        savedViewController = [[FLContainerViewController alloc] initWithControllers:@[[AccountViewController new], [TimelineViewController new], [FriendsViewController new]]];
    }
    [UIView transitionWithView:self.window
                      duration:0.7
                       options:(UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionAllowAnimatedContent)
                    animations:^{
                        self.window.rootViewController = savedViewController;
                    }
                    completion:^(BOOL finished) {
                        savedViewController = nil;
                    }
     ];
//
//    CompleteBlock completeBlock = ^{
//        if(!savedViewController){
//            savedViewController = [[FLContainerViewController alloc] initWithControllers:@[[AccountViewController new], [TimelineViewController new], [FriendsViewController new]]];
//        }
//        
//        [UIView transitionWithView:self.window
//                          duration:0.7
//                           options:(UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionAllowAnimatedContent)
//                        animations:^{
//                            self.window.rootViewController = savedViewController;
//                        }
//                        completion:^(BOOL finished) {
//                            savedViewController = nil;
//                        }
//         ];
//    };
//
//    
//    FLNavigationController *navController = nil;
//    SecureCodeViewController *controller = [SecureCodeViewController new];
//    controller.completeBlock = completeBlock;
//    
//    // Sortie de mise en vieille cas où on est deja connecté
//    if([self.window.rootViewController isKindOfClass:[FLContainerViewController class]]){
//        savedViewController = self.window.rootViewController;
//        
//        navController = [[FLNavigationController alloc] initWithRootViewController:[HomeViewController new]];
//        self.window.rootViewController = navController;
//    }
//    else{
//        navController = (FLNavigationController *)self.window.rootViewController;
//    }
//    
//    
//    // Cas ou fait retour sur le splashscreen
//    if([[[navController viewControllers] firstObject] isKindOfClass:[SplashViewController class]]){
//        navController = [[FLNavigationController alloc] initWithRootViewController:[HomeViewController new]];
//        self.window.rootViewController = navController;
//    }
//    
//    if([[[navController viewControllers] lastObject] presentedViewController]){
//        [[[[navController viewControllers] lastObject] presentedViewController] dismissViewControllerAnimated:NO completion:nil];
//    }
//    
//    [navController pushViewController:controller animated:NO];
}

- (void)clearSavedViewController
{
    savedViewController = nil;
}

- (void)showLoginWithUser:(NSDictionary *)user
{
    FLNavigationController *navController = [[FLNavigationController alloc] initWithRootViewController:[[LoginViewController  alloc] initWithUser:user]];

    [[[self currentController] presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    [[self currentController] presentViewController:navController animated:YES completion:nil];
}

- (void)showSignupWithUser:(NSDictionary *)user
{    
    FLNavigationController *navController = [[FLNavigationController alloc] initWithRootViewController:[[SignupViewController alloc] initWithUser:user]];

    [[[self currentController] presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    [[self currentController] presentViewController:navController animated:YES completion:nil];
}

- (UIViewController *)currentController
{
    UIViewController *currentController = self.window.rootViewController;
    
    while([currentController presentedViewController]){
        currentController = [currentController presentedViewController];
    }
    
    return currentController;
}

#pragma mark -

- (void)didDisconnected
{
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[HomeViewController new]];
    
    [UIView transitionWithView:self.window
                      duration:0.7
                       options:(UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionAllowAnimatedContent)
                    animations:^{
                        self.window.rootViewController = controller;
                    }
                    completion:NULL
     ];
}

- (void)displayError:(NSError *)error
{
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:lastErrorDate];
        
    if((lastErrorCode == FLNetworkError) && (error.code == FLNetworkError) && seconds < 30){
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

- (void)displayMessage:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style time:(NSNumber *)time delay:(NSNumber *)delay;
{
    if(!title || [title isBlank]){
        title = NSLocalizedString(@"GLOBAL_ERROR", nil);
    }

    [alertView show:title content:content style:style time:time delay:delay];
}

#pragma mark -

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[Flooz sharedInstance] socketSendSessionEnd];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if([[Flooz sharedInstance] currentUser]){
        [self didConnected];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Facebook

- (void)facebookSessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // WARNING erreur code 2 http://stackoverflow.com/questions/20657780/ios-facebook-sdk-error-domain-com-facebook-sdk-code-2-and-code-7
    if(error){
        NSLog(@"Facebook connect error: %@", error);
        [[Flooz sharedInstance] hideLoadView];
        [appDelegate displayMessage:nil content:[error description] style:FLAlertViewStyleError time:nil delay:nil];
    }
    
    if (!error && state == FBSessionStateOpen){
        [[Flooz sharedInstance] didConnectFacebook];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Facebook session closed");
        // Show the user the logged-out UI
        //        [self userLoggedOut];
    }
    
    [[Flooz sharedInstance] hideLoadView];
    
    // 2 fois if error ?
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSLog(@"%@", [FBErrorUtility userMessageForError:error]);
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
//        [self userLoggedOut];
    }
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
        
    [FBAppCall handleDidBecomeActive];
    [[Flooz sharedInstance] startSocket];
}

#pragma mark - Notifications Push

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    _currentDeviceToken  = [NSString stringWithFormat:@"%@", deviceToken];
    _currentDeviceToken = [_currentDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    _currentDeviceToken = [_currentDeviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    _currentDeviceToken = [_currentDeviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSLog(@"Notification token: %@", _currentDeviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Notification push error in registration: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Notification push: %@", userInfo);
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        return;
    }
    
    if([[Flooz sharedInstance] currentUser]){
        [self didConnected];
    }
    return;
    
    NSDictionary *resource = userInfo[@"resource"];
    if([[Flooz sharedInstance] currentUser] && resource){
        NSString *resourceId = resource[@"resourceId"];
        
        FLContainerViewController *currentController = [[FLContainerViewController alloc] initWithControllers:@[[AccountViewController new], [TimelineViewController new], [FriendsViewController new]]];
        
        self.window.rootViewController = currentController;
        
        if([resource[@"type"] isEqualToString:@"line"]){
            
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] transactionWithId:resourceId success:^(id result) {
                FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
                TransactionViewController *controller = [[TransactionViewController alloc] initWithTransaction:transaction indexPath:nil];
                
                currentController.modalPresentationStyle = UIModalPresentationCurrentContext;
                [currentController presentViewController:controller animated:NO completion:^{
                    currentController.modalPresentationStyle = UIModalPresentationFullScreen;
                }];
            }];
            
        }
        else if([resource[@"type"] isEqualToString:@"event"]){
            
            [[Flooz sharedInstance] eventWithId:resourceId success:^(id result) {
                FLEvent *event = [[FLEvent alloc] initWithJSON:[result objectForKey:@"item"]];
                EventViewController *controller = [[EventViewController alloc] initWithEvent:event indexPath:nil];
                
                currentController.modalPresentationStyle = UIModalPresentationCurrentContext;
                [currentController presentViewController:controller animated:NO completion:^{
                    currentController.modalPresentationStyle = UIModalPresentationFullScreen;
                }];
            }];
            
        }
        else if([resource[@"type"] isEqualToString:@"friend"]){
            
            FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[FriendsViewController new]];
            [currentController presentViewController:controller animated:YES completion:NULL];
            
        }
    }
}

#pragma mark - Image fullscreen

- (BOOL)showPreviewImage:(NSString *)imageNamed
{
    NSString *key = [NSString stringWithFormat:@"preview-%@", imageNamed];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:key]){
        return NO;
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
    
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMakeWithSize(self.window.frame.size)];
    [view addTarget:self action:@selector(removePreviewImage:) forControlEvents:UIControlEventTouchUpInside];
    
    [view setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
    
    [self.window addSubview:view];
    
    return YES;
}

- (void)showPreviewImages:(NSArray *)imagesNamed
{
    imagesForPreview = [imagesNamed mutableCopy];
    [self showNextPreviewImage];
}

- (void)showNextPreviewImage
{
    NSString *imageNamed = [imagesForPreview firstObject];
    [imagesForPreview removeObjectAtIndex:0];
    
    [self showPreviewImage:imageNamed];
}

- (void)removePreviewImage:(UIView *)view
{
    [view removeFromSuperview];
    
    if(imagesForPreview && [imagesForPreview count] > 0){
        [self showNextPreviewImage];
    }
}

#pragma mark -

- (void)showMenuForUser:(FLUser *)user imageView:(UIView *)imageView
{
    [self showMenuForUser:user imageView:imageView canRemoveFriend:NO];
}

- (void)showMenuForUser:(FLUser *)user imageView:(UIView *)imageView canRemoveFriend:(BOOL)canRemoveFriend
{
    if(!user || [user userId] == [[[Flooz sharedInstance] currentUser] userId] ||
       ![user username] || ![user fullname]) {
        return;
    }
    
    currentUserForMenu = user;
    currentImageView = imageView;
    haveMenuFriend = NO;
    
     UIActionSheet *actionSheet = actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_PAYMENT", nil), NSLocalizedString(@"MENU_COLLECT", nil), nil];
    NSMutableArray *menus = [NSMutableArray new];
    

    BOOL isFriend = NO;
    if([[[[Flooz sharedInstance] currentUser] userId] isEqualToString:[user userId]]){
        isFriend = YES;
    }
    else{
        for(FLUser *friend in [[[Flooz sharedInstance] currentUser] friends]){
            if([[friend userId] isEqualToString:[user userId]]){
                isFriend = YES;
                break;
            }
        }
    }
    
    if(isFriend){
        if(canRemoveFriend){
            [actionSheet addButtonWithTitle:NSLocalizedString(@"MENU_REMOVE_FRIENDS", nil)];
            haveMenuFriend = YES;
        }
    }
    else{
        [actionSheet addButtonWithTitle:NSLocalizedString(@"MENU_ADD_FRIENDS", nil)];
        haveMenuFriend = YES;
    }
    
    if([currentUserForMenu avatarURL]){
        [menus addObject:NSLocalizedString(@"MENU_AVATAR", nil)];
    }

    for(NSString *menu in menus){
        [actionSheet addButtonWithTitle:menu];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    
    [actionSheet showInView:self.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    void (^friendMenu)(void) = ^(void){
        [[Flooz sharedInstance] showLoadView];
        
        BOOL isFriend = NO;
        if([[[[Flooz sharedInstance] currentUser] userId] isEqualToString:[currentUserForMenu userId]]){
            isFriend = YES;
        }
        else{
            for(FLUser *friend in [[[Flooz sharedInstance] currentUser] friends]){
                if([[friend userId] isEqualToString:[currentUserForMenu userId]]){
                    isFriend = YES;
                    break;
                }
            }
        }
        
        if(isFriend){
            [[Flooz sharedInstance] friendRemove:[currentUserForMenu friendRelationId] success:nil];
        }
        else{
            [[Flooz sharedInstance] friendAcceptSuggestion:[currentUserForMenu userId] success:nil];
        }
    };
    
    void (^showAvatar)(void) = ^(void){
        FLContainerViewController *controller = (FLContainerViewController *)appDelegate.window.rootViewController;
        [controller didImageTouch:currentImageView photoURL:[NSURL URLWithString:[currentUserForMenu avatarURL]]];
    };
    
    if(buttonIndex == 0){
        [self showNewTransactionController:currentUserForMenu transactionType:TransactionTypePayment];
    }
    else if(buttonIndex == 1){
        [self showNewTransactionController:currentUserForMenu transactionType:TransactionTypeCharge];
    }
    else if(buttonIndex == 2 && haveMenuFriend){
        friendMenu();
    }
    else if(buttonIndex == 2 && [currentUserForMenu avatarURL]){
        showAvatar();
    }
    else if(buttonIndex == 2){
        
    }
    else if(buttonIndex == 3 && haveMenuFriend && [currentUserForMenu avatarURL]){
        showAvatar();
    }
}

// WARNING gros gros hack
- (void)showNewTransactionController:(FLUser *)user transactionType:(NSUInteger)transactionType
{
    if([self.window.rootViewController presentedViewController]){
        [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
            NewTransactionViewController *controller = [[NewTransactionViewController alloc] initWithTransactionType:transactionType user:currentUserForMenu];
            [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
        }];
    }
    else{
        NewTransactionViewController *controller = [[NewTransactionViewController alloc] initWithTransactionType:transactionType user:currentUserForMenu];
        [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
    }
}

- (void)lockForUpdate:(NSString *)updateUrl
{
    if(updateUrl){
        NSURL *url = [NSURL URLWithString:updateUrl];
        [[UIApplication sharedApplication] openURL:url];
    }
    
    [UIView transitionWithView:self.window
                      duration:0.7
                       options:(UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionAllowAnimatedContent)
                    animations:^{
                        self.window.rootViewController = [SplashViewController new];
                    }
                    completion:^(BOOL finished) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GLOBAL_ERROR", nil)
                                                                        message:ERROR_LOCALIZED_DESCRIPTION(FLNeedUpdateError)
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil)
                                                              otherButtonTitles:nil
                                              ];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [alert show];
                        });
                    }
     ];
}

@end
