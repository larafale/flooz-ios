//
//  SecureCodeViewController.h
//  Flooz
//
//  Created by jonathan on 2014-03-17.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SecureCodeFieldDelegate.h"

typedef void (^CompleteBlock)();

typedef NS_ENUM(NSInteger, SecureCodeMode) {
    SecureCodeModeNormal, // Demande code pour avoir acces
    SecureCodeModeForget, // Code perdu
    SecureCodeModeChangeOld, // Ancien code pour le changer
    SecureCodeModeChangeNew, // Nouveau code
    SecureCodeModeChangeConfirm // Nouveau code confirmation
};

@interface SecureCodeViewController : UIViewController<SecureCodeFieldDelegate>

@property BOOL isForChangeSecureCode;
@property (strong, nonatomic) CompleteBlock completeBlock;

+ (BOOL)hasSecureCodeForCurrentUser;
+ (void)clearSecureCode;

@end
