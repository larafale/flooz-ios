//
//  SignupViewController.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "SignupViewController.h"

#import "AppDelegate.h"

#define MARGE 20.

@interface SignupViewController (){
    NSMutableDictionary *user;
    UIButton *registerFacebook;
}

@end

@implementation SignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_SIGNUP", nil);
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
        [registerFacebook setTitle:NSLocalizedString(@"SIGNUP_FACEBOOK", nil) forState:UIControlStateNormal];
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
        text.text = NSLocalizedString(@"SIGN_OR", nil);
        text.textColor = [UIColor whiteColor];
        text.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:text];
    }
    
    {
        UIButton *avatar = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) / 2.) - 50, 100, 100, 96)];
        [avatar setImage:[UIImage imageNamed:@"test_user1"] forState:UIControlStateNormal];
        [self.view addSubview:avatar];
    }
    
    {
        FLTextField *username = [[FLTextField alloc] initWithIcon:@"field-name" placeholder:@"FIELD_USERNAME" for:user key:@"nick" position:CGPointMake(MARGE, 209)];
        FLTextField *name = [[FLTextField alloc] initWithIcon:@"field-name" placeholder:@"FIELD_FIRSTNAME" for:user key:@"firstName" position:CGPointMake(MARGE, CGRectGetMaxY(username.frame)) placeholder2:@"FIELD_LASTNAME" key2:@"lastName"];
        FLTextField *phone = [[FLTextField alloc] initWithIcon:@"field-phone" placeholder:@"FIELD_PHONE" for:user key:@"phone" position:CGPointMake(MARGE, CGRectGetMaxY(name.frame))];
        FLTextField *email = [[FLTextField alloc] initWithIcon:@"field-email" placeholder:@"FIELD_EMAIL" for:user key:@"email" position:CGPointMake(MARGE, CGRectGetMaxY(phone.frame))];
        
        
        UILabel *textSecurity = [[UILabel alloc] initWithFrame:CGRectMake(MARGE, CGRectGetMaxY(email.frame), CGRectGetWidth(self.view.frame) - MARGE, 15)];
        
        textSecurity.font = [UIFont customContentRegular:12];
        textSecurity.textColor = [UIColor customBlue];
        
        textSecurity.text = NSLocalizedString(@"SIGNUP_SECURITY_INFO", nil);
        
        
        FLTextField *password = [[FLTextField alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD" for:user key:@"password" position:CGPointMake(MARGE, CGRectGetMaxY(textSecurity.frame))];
        FLTextField *code = [[FLTextField alloc] initWithIcon:@"field-password" placeholder:@"FIELD_CODE" for:user key:@"code" position:CGPointMake(MARGE, CGRectGetMaxY(password.frame))];
        
        UILabel *textFooter = [[UILabel alloc] initWithFrame:CGRectMake(MARGE + 40, CGRectGetMaxY(code.frame), 244, 50)];
        
        textFooter.font = [UIFont customContentRegular:12];
        textFooter.textColor = [UIColor customBlue];
        textFooter.numberOfLines = 2;
        
        textFooter.text = NSLocalizedString(@"SIGNUP_CODE_INFO", nil);
        
        [self.view addSubview:username];
        [self.view addSubview:name];
        [self.view addSubview:phone];
        [self.view addSubview:email];
        [self.view addSubview:textSecurity];
        [self.view addSubview:password];
        [self.view addSubview:code];
        [self.view addSubview:textFooter];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)presentTimelineController
{
    [[Flooz sharedInstance] signup:user
                            success:^(id result){
                                [appDelegate didConnected];
                            }failure:^(NSError *error){
                               
                            }];
}

@end
