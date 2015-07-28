//
//  BaseViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-01.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    
    CGFloat mainBodyHeight = PPScreenHeight();
    
    if (![UIApplication sharedApplication].isStatusBarHidden)
        mainBodyHeight -= PPStatusBarHeight();
    
    if (self.navigationController && self.navigationController.navigationBarHidden == NO)
        mainBodyHeight -= NAVBAR_HEIGHT;
    
    if (self.tabBarController)
        mainBodyHeight -= PPTabBarHeight();
    
    _mainBody = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), mainBodyHeight)];
    _mainBody.backgroundColor = [UIColor customBackgroundHeader];
    
    [self.view addSubview:_mainBody];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
