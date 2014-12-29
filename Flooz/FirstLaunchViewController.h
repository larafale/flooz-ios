//
//  FirstLaunchViewController.h
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SignupViewController.h"

@interface FirstLaunchViewController : GlobalViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, SignupViewControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *userInfoDico;

- (id)initWithSpecificPage:(SignupOrderPage)index;

- (void)phoneNotRegistered:(NSDictionary *)user;
- (void)signupWithFacebookUser:(NSDictionary *)user;

@end
