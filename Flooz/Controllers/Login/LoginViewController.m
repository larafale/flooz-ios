//
//  LoginViewController.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "LoginViewController.h"

#import "AppDelegate.h"

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
        registerFacebook = [[UIButton alloc] initWithFrame:CGRectMake(MARGE, 17, SCREEN_WIDTH - (2 * MARGE), 40)];
        registerFacebook.backgroundColor = [UIColor customBlue];
        [registerFacebook setTitle:NSLocalizedString(@"LOGIN_FACEBOOK", nil) forState:UIControlStateNormal];
        registerFacebook.titleLabel.font = [UIFont customContentRegular:13];
        [registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        [registerFacebook setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 12)];
        
        [self.view addSubview:registerFacebook];
    }
    
    {
        UIView *left = [[UIView alloc] initWithFrame:CGRectMake(MARGE, 80, 120, 1)];
        UIView *right = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - CGRectGetWidth(left.frame) - MARGE, left.frame.origin.y, CGRectGetWidth(left.frame), 1)];
        
        left.backgroundColor = right.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:left];
        [self.view addSubview:right];
        
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(left.frame), 70, CGRectGetWidth(self.view.frame) - 2 * (CGRectGetWidth(left.frame) + MARGE), 15)];
        text.text = NSLocalizedString(@"LOGIN_OR", nil);;
        text.textColor = [UIColor whiteColor];
        text.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:text];
    }
    
    {
        FLTextField *username = [[FLTextField alloc] initWithIcon:@"field-name" placeholder:@"FIELD_USERNAME" for:user key:@"login" position:CGPointMake(MARGE, 100)];
        FLTextField *password = [[FLTextField alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD" for:user key:@"password" position:CGPointMake(MARGE, CGRectGetMaxY(username.frame))];

        UIButton *passwordForget = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(password.frame) + 20, CGRectGetWidth(self.view.frame), 50)];
        passwordForget.titleLabel.textAlignment = NSTextAlignmentCenter;
        passwordForget.titleLabel.font = [UIFont customTitleBook:12];
        [passwordForget setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
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
    [[Flooz sharedInstance] login:user
                          success:^(id result){
                              [appDelegate didConnected];
                          }failure:^(NSError *error){
                              [appDelegate didConnected];
                          }];
}


@end
