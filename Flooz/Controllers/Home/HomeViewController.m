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

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    
    preview = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 34, CGRectGetWidth(self.view.frame), 34)];
    login = [[UIButton alloc] initWithFrame:CGRectMake(23, preview.frame.origin.y - 30 - 35, 134, 45)];
    signup = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(login.frame) + 6, login.frame.origin.y, login.frame.size.width, login.frame.size.height)];
    
    login.backgroundColor = [UIColor customBackground];
    login.titleLabel.font = [UIFont customTitleLight:14];
    login.layer.opacity = 0.7;
    login.layer.cornerRadius = 2.;
    [login setTitle:NSLocalizedString(@"HOME_LOGIN", nil) forState:UIControlStateNormal];
    [login addTarget:self action:@selector(presentLoginController) forControlEvents:UIControlEventTouchDown];
    
    signup.backgroundColor = [UIColor customBlue];
    signup.titleLabel.font = login.titleLabel.font;
    signup.layer.opacity = login.layer.opacity;
    signup.layer.cornerRadius = login.layer.cornerRadius;
    [signup setTitle:NSLocalizedString(@"HOME_SIGNUP", nil) forState:UIControlStateNormal];
    [signup addTarget:self action:@selector(presentSignupController) forControlEvents:UIControlEventTouchDown];
    
    preview.backgroundColor = [UIColor colorWithRed:30./256. green:41./256. blue:52./256. alpha:1.];
    preview.titleLabel.font = [UIFont customContentRegular:12];
    
    [preview setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
    [preview setTitle:NSLocalizedString(@"HOME_PREVIEW", nil) forState:UIControlStateNormal];
    [preview addTarget:self action:@selector(presentPreviewController) forControlEvents:UIControlEventTouchDown];
    [preview setImage:[UIImage imageNamed:@"arrow-right"] forState:UIControlStateNormal];
    
    preview.imageEdgeInsets = UIEdgeInsetsMake(2, 135, 0, 0);
    preview.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, [preview imageForState:UIControlStateNormal].size.width);
    
    {
        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(preview.frame), .5)];
        borderView.backgroundColor = [UIColor colorWithRed:1. green:1. blue:1. alpha:.1];
        [preview addSubview:borderView];
    }
    
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
