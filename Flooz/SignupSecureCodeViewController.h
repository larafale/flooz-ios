//
//  SignupSecureCodeViewController.h
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "CodePinView.h"
#import "SignupBaseViewController.h"

@interface SignupSecureCodeViewController : SignupBaseViewController<CodePinDelegate>

- (id)initWithMode:(SecureCodeMode)mode;

@end
