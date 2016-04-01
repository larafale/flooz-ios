//
//  BaseViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-01.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "BaseViewController.h"

#import "UserViewController.h"
#import "TransactionViewController.h"
#import "CollectViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    
    CGFloat mainBodyHeight = PPScreenHeight();
    
    if (![UIApplication sharedApplication].isStatusBarHidden)
        mainBodyHeight -= PPStatusBarHeight();
    
    if (self.navigationController) {
        if (self.navigationController.viewControllers.count > 1) {
            UIViewController *currentVisibleController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
            if (self.navigationController.navigationBarHidden == NO)
                mainBodyHeight -= NAVBAR_HEIGHT;
            else if (currentVisibleController && [currentVisibleController isKindOfClass:[UserViewController class]] && ![self isKindOfClass:[UserViewController class]])
                mainBodyHeight -= NAVBAR_HEIGHT;
        } else if (self.navigationController.navigationBarHidden == NO)
            mainBodyHeight -= NAVBAR_HEIGHT;
    }
    
    if (self.tabBarController && ![self isKindOfClass:TransactionViewController.class] && ![self isKindOfClass:CollectViewController.class])
        mainBodyHeight -= PPTabBarHeight();
    
    _mainBody = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), mainBodyHeight)];
    _mainBody.backgroundColor = [UIColor customBackgroundHeader];
        
    [self.view addSubview:_mainBody];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CGRectSetHeight(self.view.frame, CGRectGetHeight(_mainBody.frame));
}

@end
