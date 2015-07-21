//
//  AppDelegate.h
//  Flooz
//
//  Created by olivier on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "FLAlert.h"
#import "FLAlertView.h"
#import "MZFormSheetController.h"
#import "FLRevealContainerViewController.h"
#import "SignupNavigationController.h"
#import "SignupSMSViewController.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "FLTabBarController.h"

#define REFRESH_INTERVAL 1

static NSString *kKeyTutoFlooz = @"kKeyTutoFlooz";
static NSString *kKeyLastUpdate = @"kKeyLastUpdate";
static NSString *kKeyTutoWelcome = @"kKeyTutoWelcome";
static NSString *kKeyTutoTimeline = @"kKeyTutoTimeline";
static NSString *kKeyTutoTimelineFriends = @"kKeyTutoTimelineFriends";
static NSString *kKeyTutoTimelinePublic = @"kKeyTutoTimelinePublic";
static NSString *kKeyTutoTimelinePrivate = @"kKeyTutoTimelinePrivate";
static NSString *kKeyAccessContacts = @"kKeyAccessContacts";
static NSString *kNotificationCancelTimer = @"kNotificationCancelTimer";
static NSString *kNotificationTouchStatusBarClick = @"kNotificationTouchStatusBarClick";

@interface AppDelegate : UIResponder <UIApplicationDelegate, MFMailComposeViewControllerDelegate, PPRevealSideViewControllerDelegate, UIActionSheetDelegate, JTSImageViewControllerInteractionsDelegate> {
	NSDate *lastErrorDate;
	NSInteger lastErrorCode;

	FLAlertView *_alertView;

	FLUser *currentUserForMenu;
	UIView *currentImageView;
	BOOL haveMenuFriend;
    BOOL _canRemoveFriend;

	NSMutableArray *imagesForPreview;

	UIViewController *savedViewController;
    SignupNavigationController *signupNavigationController;
    
	UIViewController *viewControllerForPopup;
	UIViewController *currentMainView;
    NSString *_lastTransactionID;
}

@property (nonatomic, retain) NSString *localIp;
@property (nonatomic) BOOL canRefresh;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *currentDeviceToken;
@property (strong, nonatomic) MZFormSheetController *formSheet;
@property (strong, nonatomic) FLRevealContainerViewController *revealSideViewController;
@property (strong, nonatomic) FLTabBarController *tabBarController;
@property (nonatomic, retain) NSMutableDictionary *branchParam;

- (void)initTestingWithIP:(NSString *)ip;

- (void)handlePendingData;
- (void)didConnected;
- (void)goToAccountViewController;
- (void)didDisconnected;
- (void)displayHome;
- (void)askForSecureCodeWithUser:(NSDictionary *)user;
- (void)showResetPasswordWithUser:(NSDictionary*)user;
- (void)showSignupWithUser:(NSDictionary *)user;
- (void)showSignupAfterFacebookWithUser:(NSDictionary *)user;
- (void)resetTuto:(Boolean)value;
- (void)clearBranchParams;
- (void)clearPendingData;

- (void)displayError:(NSError *)error;
- (void)displayMessage:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style time:(NSNumber *)time delay:(NSNumber *)delay;
- (void)displayMessage:(FLAlert*)alert;
- (void)displayAlert:(NSString *)title content:(NSString *)content;
- (void)noAccessToSettings;

- (void)facebookSessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error;

- (BOOL)showPreviewImage:(NSString *)imageNamed;
- (void)showPreviewImages:(NSArray *)imagesNamed;
- (void)showReportMenu:(FLReport *)report;
- (void)showMenuForUser:(FLUser *)user imageView:(UIView *)imageView;
- (void)showMenuForUser:(FLUser *)user imageView:(UIView *)imageView canRemoveFriend:(BOOL)canRemoveFriend;
- (void)showMenuForUser:(FLUser *)user imageView:(UIView *)imageView canRemoveFriend:(BOOL)canRemoveFriend inWindow:(UIWindow *)window;
- (void)showAvatarView:(UIView *)view withUrl:(NSURL *)urlImage;
- (void)showPresetNewTransactionController:(FLPreset *)preset;
- (void)popToMainView;

- (void)lockForUpdate:(NSString *)updateUrl;

- (void)clearSavedViewController;
- (void)askNotification;

- (void)showTransaction:(FLTransaction *)transaction inController:(UIViewController *)vc withIndexPath:(NSIndexPath *)indexPath focusOnComment:(BOOL)focus;
- (void)showFriendsController;
- (void)showEditProfil;

- (BOOL)shouldRefreshWithKey:(NSString *)keyUpdate;
- (void)displayMailWithMessage:(NSString *)message object:(NSString *)object recipients:(NSArray *)recipient andMessageError:(NSString *)messageError inViewController:(UIViewController *)vc;

- (UIWindow *)topWindow;
- (UIViewController *)currentController;
- (UIViewController *)myTopViewController;

@end
