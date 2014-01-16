//
//  HomeViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "HomeViewController.h"

#import "PreviewViewController.h"
#import "LoginViewController.h"
#import "SignupViewController.h"

@interface HomeViewController (){
    UIButton *login;
    UIButton *signup;
    UIButton *preview;
}

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    preview = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 29, CGRectGetWidth(self.view.frame), 29)];
    login = [[UIButton alloc] initWithFrame:CGRectMake(23, preview.frame.origin.y - 13 - 35, 134, 35)];
    signup = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(login.frame) + 6, login.frame.origin.y, 134, 35)];
    
    login.backgroundColor = [UIColor redColor];
    [login setTitle:NSLocalizedString(@"HOME_LOGIN", nil) forState:UIControlStateNormal];
    [login addTarget:self action:@selector(presentLoginController) forControlEvents:UIControlEventTouchDown];
    
    signup.backgroundColor = [UIColor customBlue];
    [signup setTitle:NSLocalizedString(@"HOME_SIGNUP", nil) forState:UIControlStateNormal];
    [signup addTarget:self action:@selector(presentSignupController) forControlEvents:UIControlEventTouchDown];
    
    preview.backgroundColor = [UIColor redColor];
    [preview setTitle:NSLocalizedString(@"HOME_PREVIEW", nil) forState:UIControlStateNormal];
    [preview addTarget:self action:@selector(presentPreviewController) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:login];
    [self.view addSubview:signup];
    [self.view addSubview:preview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)presentLoginController
{
    [self.navigationController pushViewController:[LoginViewController new] animated:YES];
}

- (void)presentSignupController
{
    [self.navigationController pushViewController:[SignupViewController new] animated:YES];
}

- (void)presentPreviewController
{
    [self.navigationController pushViewController:[PreviewViewController new] animated:YES];
}

@end
