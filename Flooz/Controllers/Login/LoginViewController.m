//
//  LoginViewController.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "LoginViewController.h"

#define MARGE 20.

@interface LoginViewController (){
    NSMutableDictionary *user;
    UIButton *registerFacebook;
}

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_LOGIN", nil);
        user = [NSMutableDictionary new];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor customBackground];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(presentTimelineController)];
    
    {
        registerFacebook = [[UIButton alloc] initWithFrame:CGRectMake(MARGE, 27, SCREEN_WIDTH - (2 * MARGE), 45)];
        [registerFacebook setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.5]] forState:UIControlStateNormal];
        
        [registerFacebook setTitle:NSLocalizedString(@"LOGIN_FACEBOOK", nil) forState:UIControlStateNormal];
        registerFacebook.titleLabel.font = [UIFont customContentRegular:13];
        [registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        [registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateHighlighted];
        [registerFacebook setImageEdgeInsets:UIEdgeInsetsMake(-1, 0, 0, 12)];
        
        [registerFacebook addTarget:self action:@selector(didFacebookTouch) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:registerFacebook];
    }
    
    {
        UIView *left = [[UIView alloc] initWithFrame:CGRectMake(MARGE, 115, 120, .5)];
        UIView *right = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - CGRectGetWidth(left.frame) - MARGE, left.frame.origin.y, CGRectGetWidth(left.frame), .5)];
        
        left.backgroundColor = right.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:left];
        [self.view addSubview:right];
        
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(left.frame), 105, CGRectGetWidth(self.view.frame) - 2 * (CGRectGetWidth(left.frame) + MARGE), 15)];
        text.text = NSLocalizedString(@"LOGIN_OR", nil);;
        text.textColor = [UIColor whiteColor];
        text.textAlignment = NSTextAlignmentCenter;
        text.font = [UIFont customContentLight:14];
        [self.view addSubview:text];
    }
    
    {
        FLTextFieldIcon *username = [[FLTextFieldIcon alloc] initWithIcon:@"field-username" placeholder:@"FIELD_USERNAME" for:user key:@"login" position:CGPointMake(MARGE, 140)];
        FLTextFieldIcon *password = [[FLTextFieldIcon alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD" for:user key:@"password" position:CGPointMake(MARGE, CGRectGetMaxY(username.frame))];

        UIButton *passwordForget = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(password.frame) + 20, CGRectGetWidth(self.view.frame), 50)];
        passwordForget.titleLabel.textAlignment = NSTextAlignmentCenter;
        passwordForget.titleLabel.font = [UIFont customContentRegular:12];
        [passwordForget setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
        [passwordForget setTitle:NSLocalizedString(@"LOGIN_PASSWORD_FORGOT", nil) forState:UIControlStateNormal];
        
        [self.view addSubview:username];
        [self.view addSubview:password];
        [self.view addSubview:passwordForget];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)presentTimelineController
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] login:user success:NULL failure:NULL];
}

- (void)didFacebookTouch
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] connectFacebook];
}

@end
