//
//  AppDelegate.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLAlertView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIActionSheetDelegate>{
    NSDate *lastErrorDate;
    NSInteger lastErrorCode;
    
    FLAlertView *alertView;
    
    FLUser *currentUserForMenu;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *currentDeviceToken;

- (void)didConnected;
- (void)didDisconnected;
- (void)showLoginWithUser:(NSDictionary *)user;
- (void)showSignupWithUser:(NSDictionary *)user;

- (void)displayError:(NSError *)error;
- (void)displayMessage:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style time:(NSNumber *)time delay:(NSNumber *)delay;

- (void)facebookSessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

- (void)showPreviewImage:(NSString *)imageNamed;
- (void)showMenuForUser:(FLUser *)user;

@end
