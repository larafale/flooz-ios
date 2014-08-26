//
//  AppDelegate.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FirstLaunchViewController.h"
#import "FLAlertView.h"

static NSString *kNotificationTouchStatusBarClick = @"kNotificationTouchStatusBarClick";

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIActionSheetDelegate>{
    NSDate *lastErrorDate;
    NSInteger lastErrorCode;
    
    FLAlertView *alertView;
    
    FLUser *currentUserForMenu;
    UIView *currentImageView;
    BOOL haveMenuFriend;
    
    NSMutableArray *imagesForPreview;
    
    UIViewController *savedViewController;
    FirstLaunchViewController *firstVC;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *currentDeviceToken;

- (void)didConnected;
- (void)goToAccountViewController;
- (void)didDisconnected;
- (void)showLoginWithUser:(NSDictionary *)user;
- (void)askForSecureCodeWithUser:(NSDictionary *)user withNavigationBar:(BOOL)navBar;
- (void)showSignupWithUser:(NSDictionary *)user;
- (void)showSignupAfterFacebookWithUser:(NSDictionary *)user;

- (void)displayError:(NSError *)error;
- (void)displayMessage:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style time:(NSNumber *)time delay:(NSNumber *)delay;

- (void)facebookSessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

- (BOOL)showPreviewImage:(NSString *)imageNamed;
- (void)showPreviewImages:(NSArray *)imagesNamed;
- (void)showMenuForUser:(FLUser *)user imageView:(UIView *)imageView;
- (void)showMenuForUser:(FLUser *)user imageView:(UIView *)imageView canRemoveFriend:(BOOL)canRemoveFriend;

- (void)lockForUpdate:(NSString *)updateUrl;

- (void)clearSavedViewController;

- (void)showRequestInvitationCodeWithUser:(NSDictionary *)user;


//TODO: delete after testing friends
- (void)showsignupFriendUser:(NSDictionary *)user;

@end
