//
//  SecureCodeViewController.h
//  Flooz
//
//  Created by olivier on 2014-03-17.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "FLKeyboardView.h"
#import "CodePinView.h"
#import "NumPadAppleStyle.h"

typedef void (^CompleteBlock)();

@interface SecureCodeViewController : GlobalViewController <CodePinDelegate, NumPadAppleDelegate>

@property BOOL blockTouchID;
@property BOOL isForChangeSecureCode;
@property (strong, nonatomic) CompleteBlock completeBlock;
@property (nonatomic) SecureCodeMode currentSecureMode;

- (id)initWithUser:(NSDictionary *)_user;

+ (BOOL)hasSecureCodeForCurrentUser;
+ (void)clearSecureCode;
+ (NSString *)secureCodeForCurrentUser;
+ (BOOL)canUseTouchID;
+ (void)useToucheID:(CompleteBlock)successBlock passcodeCallback:(CompleteBlock)passcodeBlock cancelCallback:(CompleteBlock)cancelBlock;

@end
