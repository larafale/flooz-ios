//
//  AppDelegate.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NSDate *lastErrorDate;
    NSInteger lastErrorCode;
}

@property (strong, nonatomic) UIWindow *window;

- (void)didConnected;
- (void)didDisconnected;

- (void)displayError:(NSError *)error;
- (void)displayErrorMessage:(NSString *)title content:(NSString *)content;

- (void)facebookSessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)loadSignupWithUser:(NSDictionary *)user;

@end
