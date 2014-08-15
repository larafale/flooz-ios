//
//  FirstLaunchViewController.h
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FirstLaunchContentViewController.h"

@interface FirstLaunchViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, FirstLaunchContentViewControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *userInfoDico;

- (void)phoneNotRegistered:(NSDictionary *)user;
- (void)signupWithFacebookUser:(NSDictionary *)user;

@end