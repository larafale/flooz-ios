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

@interface SecureCodeViewController : UIViewController<SecureCodeFieldDelegate>

@property BOOL isForChangeSecureCode;
@property (strong, nonatomic) CompleteBlock completeBlock;

@end
