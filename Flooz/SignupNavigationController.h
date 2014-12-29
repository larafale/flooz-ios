//
//  SignupNavigationController.h
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignupBaseViewController.h"

@interface SignupNavigationController : UINavigationController<UINavigationControllerDelegate>

@property (nonatomic, retain) SignupBaseViewController *controller;

@end
