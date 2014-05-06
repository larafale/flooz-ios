//
//  AppDelegate.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "AppDelegate.h"

#import "FLContainerViewController.h"

#import "HomeViewController.h"
#import "SignupViewController.h"

#import "EventsViewController.h"
#import "TimelineViewController.h"
#import "AccountViewController.h"

#import "SecureCodeViewController.h"
#import "Analytics/Analytics.h"

#import "TransactionViewController.h"
#import "EventViewController.h"
#import "FriendsViewController.h"

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
    
    if([[Flooz sharedInstance] autologin]){
        self.window.rootViewController = [UIViewController new];
    }
    else{
        FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[HomeViewController new]];
        
        self.window.rootViewController = controller;
    }

    [Analytics initializeWithSecret:@"2jcb70koii"];
    
    return YES;
}

- (void)didConnected
{
    NSMutableDictionary *params = [@{
                             @"firstName": [[[Flooz sharedInstance] currentUser] firstname],
                             @"lastName": [[[Flooz sharedInstance] currentUser] lastname],
                             @"email": [[[Flooz sharedInstance] currentUser] email],
                             @"record":[[[Flooz sharedInstance] currentUser] record],
                             @"id": [[[Flooz sharedInstance] currentUser] userId],
                             @"username": [[[Flooz sharedInstance] currentUser] username],
                             @"phone": [[[Flooz sharedInstance] currentUser] phone],
                             @"$ios_devices": @[]
                             } mutableCopy];
    
    if([[[Flooz sharedInstance] currentUser] device]){
        params[@"$ios_devices"] = @[[[[Flooz sharedInstance] currentUser] device]];
    }
    
    [[Analytics sharedAnalytics] identify:[[[Flooz sharedInstance] currentUser] userId]
                                   traits:params];
    
    CompleteBlock completeBlock = ^{
        FLContainerViewController *controller = [[FLContainerViewController alloc] initWithControllers:@[[AccountViewController new], [TimelineViewController new], [EventsViewController new]]];
        
        [UIView transitionWithView:self.window
                          duration:0.7
                           options:(UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionAllowAnimatedContent)
                        animations:^{
                            self.window.rootViewController = controller;
                        }
                        completion:NULL
         ];
    };
    
    if(![SecureCodeViewController hasSecureCodeForCurrentUser]){
        SecureCodeViewController *controller = [SecureCodeViewController new];
        controller.completeBlock = completeBlock;
        
        FLNavigationController *rootController = (FLNavigationController *)self.window.rootViewController;
        [rootController pushViewController:controller animated:YES];
    }
    else{
        completeBlock();
    }
}

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
    if((lastErrorCode == FLNetworkError) && (error.code == FLNetworkError)){
        lastErrorDate = [NSDate date];
        return;
    }
    
    lastErrorDate = [NSDate date];
    lastErrorCode = error.code;

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GLOBAL_ERROR", nil)
                                                    message:ERROR_LOCALIZED_DESCRIPTION((long)error.code)
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

- (void)loadSignupWithUser:(NSDictionary *)user
{
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[HomeViewController new]];
    [controller setViewControllers:@[[HomeViewController new], [[SignupViewController alloc] initWithUser:user]]];
    self.window.rootViewController = controller;
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
        [[Flooz sharedInstance] hideLoadView];
        [appDelegate displayMessage:nil content:[error description] style:FLAlertViewStyleError time:nil delay:nil];
    }
    
    if (!error && state == FBSessionStateOpen){
        [[Flooz sharedInstance] didConnectFacebook];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        //        [self userLoggedOut];
        
        
    }
    
    [[Flooz sharedInstance] hideLoadView];
    
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
    
    NSDictionary *resource = userInfo[@"resource"];
    if([[Flooz sharedInstance] currentUser] && resource){
        NSString *resourceId = resource[@"resourceId"];
        
        FLContainerViewController *currentController = [[FLContainerViewController alloc] initWithControllers:@[[AccountViewController new], [TimelineViewController new], [EventsViewController new]]];
        
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

@end
