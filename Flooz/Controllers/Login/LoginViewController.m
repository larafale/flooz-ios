//
//  LoginViewController.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "LoginViewController.h"
#import "PasswordForgetViewController.h"

#define MARGE 0.

@interface LoginViewController (){
    NSMutableDictionary *user;
    UIButton *registerFacebook;
    
    FLTextFieldIcon *username;
    FLTextFieldIcon *password;
}

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithUser:nil];
}

- (id)initWithUser:(NSDictionary *)_user
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_LOGIN", nil);
        if(_user){
            user = [_user mutableCopy];
        }
        else{
            user = [NSMutableDictionary new];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackground];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(presentTimelineController)];
    
    {
        username = [[FLTextFieldIcon alloc] initWithIcon:@"field-username" placeholder:@"FIELD_USERNAME" for:user key:@"login" position:CGPointMake(MARGE, 0)];
        [user setObject:@"" forKey:@"password"];
        password = [[FLTextFieldIcon alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD" for:user key:@"password" position:CGPointMake(MARGE, CGRectGetMaxY(username.frame))];
        [password seTsecureTextEntry:YES];
        
        UIButton *passwordForget = [[UIButton alloc] initWithFrame:CGRectMake(270, password.frame.origin.y, 45, 50)];
        passwordForget.titleLabel.textAlignment = NSTextAlignmentRight;
        passwordForget.titleLabel.font = [UIFont customContentRegular:12];
        [passwordForget setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
        [passwordForget setTitle:NSLocalizedString(@"LOGIN_PASSWORD_FORGOT", nil) forState:UIControlStateNormal];
        
        [passwordForget addTarget:self action:@selector(didPasswordForget) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:username];
        [self.view addSubview:password];
        [self.view addSubview:passwordForget];
    }
    
    {
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 105, CGRectGetWidth(self.view.frame), 15)];
        text.text = NSLocalizedString(@"LOGIN_OR", nil);
        text.textColor = [UIColor whiteColor];
        text.textAlignment = NSTextAlignmentCenter;
        text.font = [UIFont customContentLight:14];
        [self.view addSubview:text];
    }
    
    {
        registerFacebook = [[UIButton alloc] initWithFrame:CGRectMake(0, 135, SCREEN_WIDTH, 45)];
        [registerFacebook setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.5]] forState:UIControlStateNormal];
        
        [registerFacebook setTitle:NSLocalizedString(@"LOGIN_FACEBOOK", nil) forState:UIControlStateNormal];
        registerFacebook.titleLabel.font = [UIFont customContentRegular:15];
        [registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        [registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateHighlighted];
        [registerFacebook setImageEdgeInsets:UIEdgeInsetsMake(-1, 0, 0, 12)];
        
        [registerFacebook addTarget:self action:@selector(didFacebookTouch) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:registerFacebook];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(user[@"login"] && ![user[@"login"] isBlank]){
        [password becomeFirstResponder];
    }
}

- (void)presentTimelineController
{
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] login:user];
}

- (void)didFacebookTouch
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] connectFacebook];
}

- (void)didPasswordForget
{
    [[self navigationController] pushViewController:[PasswordForgetViewController new] animated:YES];
}

@end
