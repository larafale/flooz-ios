//
//  SignupNavigationController.m
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SignupNavigationController.h"

@interface SignupNavigationController () {
    UIBarButtonItem *backItem;
}

@end

@implementation SignupNavigationController

@synthesize controller;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self customAppearence];
}

- (void)customAppearence {
    [self.navigationBar setBarTintColor:[UIColor customBackgroundHeader]];
    self.navigationBar.translucent = NO;
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [UIColor customBlue],
                                 NSFontAttributeName: [UIFont customTitleNav]
                                 };
    
    [self.navigationBar setTitleTextAttributes:attributes];
    
    backItem = [UIBarButtonItem createBackButtonWithTarget:self action:@selector(popViewController)];
    
    {
        self.navigationBar.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:.2];
        self.navigationBar.layer.shadowOpacity = .2;
        self.navigationBar.layer.shadowOffset = CGSizeMake(0, 3.5);
        self.navigationBar.layer.shadowRadius = 1;
        self.navigationBar.clipsToBounds = NO;
    }
}

- (void)popViewController {
    [self popViewControllerAnimated:YES];
}

- (void)dismiss {
    [self.view endEditing:YES];
    
    UIViewController *vc = [self presentingViewController];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (controller)
        [((SignupBaseViewController*)viewController).userDic addEntriesFromDictionary:((SignupBaseViewController*)controller).userDic];
    
    controller = (SignupBaseViewController*)viewController;
    [controller displayChanges];
    viewController.navigationItem.leftBarButtonItem = backItem;
 }

@end
