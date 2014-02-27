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

#import "SocialViewController.h"
#import "TimelineViewController.h"
#import "AccountViewController.h"

#import "TestFlight.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor customBackground];
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[HomeViewController new]];
    self.window.rootViewController = controller;

//    [[Flooz sharedInstance] login:nil success:NULL failure:NULL];
    
    [TestFlight takeOff:@"bcb15527-05d2-46c9-8fc3-59693ee53ebe"];
    
    return YES;
}

- (void)didConnected
{
    FLContainerViewController *controller = [[FLContainerViewController alloc] initWithControllers:@[
        [SocialViewController new], [TimelineViewController new], [AccountViewController new]
    ]];

    [UIView transitionWithView:self.window
                      duration:0.7
                       options:(UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionAllowAnimatedContent)
                    animations:^{
                        self.window.rootViewController = controller;
                    }
                    completion:NULL
     ];
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
                                                    message:ERROR_LOCALIZED_DESCRIPTION(error.code)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil)
                                          otherButtonTitles:nil
                          ];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void)displayErrorMessage:(NSString *)errorMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GLOBAL_ERROR", nil)
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil)
                                          otherButtonTitles:nil
                          ];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
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

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    if (!error && state == FBSessionStateOpen){
        [[Flooz sharedInstance] didConnectFacebook];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        //        [self userLoggedOut];
        
        [[Flooz sharedInstance] hideLoadView];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSLog(@"%@", [FBErrorUtility userMessageForError:error]);
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
//        [self userLoggedOut];
        
        [[Flooz sharedInstance] hideLoadView];
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
}

@end
