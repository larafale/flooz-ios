//
//  SignupPhoneViewController.h
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SignupBaseViewController.h"

@interface SignupPhoneViewController : SignupBaseViewController

@property (nonatomic, retain) NSString *coupon;

- (id) initWithCoupon:(NSString *)coupon;

@end
