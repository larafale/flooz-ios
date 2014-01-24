//
//  SignupViewController.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "SignupViewController.h"

#define MARGE 20.

@interface SignupViewController (){
    NSMutableDictionary *user;
    UIButton *registerFacebook;
    
    UIScrollView *_contentView;
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
    
    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMakeWithSize(self.view.frame.size)];
    [self.view addSubview:_contentView];
    
    {
        registerFacebook = [[UIButton alloc] initWithFrame:CGRectMake(MARGE, 27, SCREEN_WIDTH - (2 * MARGE), 45)];
        registerFacebook.backgroundColor = [UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.5];
        
        [registerFacebook setTitle:NSLocalizedString(@"SIGNUP_FACEBOOK", nil) forState:UIControlStateNormal];
        registerFacebook.titleLabel.font = [UIFont customContentRegular:13];
        [registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        [registerFacebook setImageEdgeInsets:UIEdgeInsetsMake(-1, 0, 0, 12)];
        
        [_contentView addSubview:registerFacebook];
    }
        
    {
        FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) / 2.) - (97. / 2.), 120, 97, 96.5)];
        [_contentView addSubview:view];
    }
    
    {
        //WARNING quand appuie sur suivant dois changer d input
        FLTextField *username = [[FLTextField alloc] initWithIcon:@"field-username" placeholder:@"FIELD_USERNAME" for:user key:@"nick" position:CGPointMake(MARGE, 222)];
        FLTextField *name = [[FLTextField alloc] initWithIcon:@"field-name" placeholder:@"FIELD_FIRSTNAME" for:user key:@"firstName" position:CGPointMake(MARGE, CGRectGetMaxY(username.frame)) placeholder2:@"FIELD_LASTNAME" key2:@"lastName"];
        FLTextField *phone = [[FLTextField alloc] initWithIcon:@"field-phone" placeholder:@"FIELD_PHONE" for:user key:@"phone" position:CGPointMake(MARGE, CGRectGetMaxY(name.frame))];
        FLTextField *email = [[FLTextField alloc] initWithIcon:@"field-email" placeholder:@"FIELD_EMAIL" for:user key:@"email" position:CGPointMake(MARGE, CGRectGetMaxY(phone.frame))];
        
        
        UILabel *textSecurity = [[UILabel alloc] initWithFrame:CGRectMake(MARGE, CGRectGetMaxY(email.frame) + 25, CGRectGetWidth(self.view.frame) - MARGE, 15)];
        
        textSecurity.font = [UIFont customContentRegular:10];
        textSecurity.textColor = [UIColor customBlueLight];
        
        textSecurity.text = NSLocalizedString(@"SIGNUP_SECURITY_INFO", nil);
        
        
        FLTextField *password = [[FLTextField alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD" for:user key:@"password" position:CGPointMake(MARGE, CGRectGetMaxY(textSecurity.frame))];
        FLTextField *code = [[FLTextField alloc] initWithIcon:@"field-code" placeholder:@"FIELD_CODE" for:user key:@"code" position:CGPointMake(MARGE, CGRectGetMaxY(password.frame))];
        
        UILabel *textFooter = [[UILabel alloc] initWithFrame:CGRectMake(MARGE + 36, CGRectGetMaxY(code.frame), 244, 50)];
        
        textFooter.font = [UIFont customContentRegular:12];
        textFooter.textColor = [UIColor customBlueLight];
        textFooter.numberOfLines = 0;
        
        textFooter.text = NSLocalizedString(@"SIGNUP_CODE_INFO", nil);
        
        [_contentView addSubview:username];
        [_contentView addSubview:name];
        [_contentView addSubview:phone];
        [_contentView addSubview:email];
        [_contentView addSubview:textSecurity];
        [_contentView addSubview:password];
        [_contentView addSubview:code];
        [_contentView addSubview:textFooter];
        
        _contentView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(textFooter.frame));
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
    
    _contentView.frame = CGRectMakeWithSize(self.view.frame.size);
}

- (void)presentTimelineController
{
    [[Flooz sharedInstance] signup:user success:NULL failure:NULL];
}

@end
