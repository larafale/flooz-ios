//
//  AppDelegate.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLAlertView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NSDate *lastErrorDate;
    NSInteger lastErrorCode;
    
    FLAlertView *alertView;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *currentDeviceToken;

- (void)didConnected;
- (void)didDisconnected;

- (void)displayError:(NSError *)error;
- (void)displayMessage:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style time:(NSNumber *)time delay:(NSNumber *)delay;

- (void)facebookSessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)loadSignupWithUser:(NSDictionary *)user;

@end
