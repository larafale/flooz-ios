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
    
    UIScrollView *contentView;
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
    
    contentView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    
    self.view.backgroundColor = [UIColor customBackground];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(presentTimelineController)];
    
    {
        registerFacebook = [[UIButton alloc] initWithFrame:CGRectMake(MARGE, 27, SCREEN_WIDTH - (2 * MARGE), 45)];
        registerFacebook.backgroundColor = [UIColor colorWithRed:59./256. green:87./256 blue:157./256 alpha:.5];
        
        [registerFacebook setTitle:NSLocalizedString(@"SIGNUP_FACEBOOK", nil) forState:UIControlStateNormal];
        registerFacebook.titleLabel.font = [UIFont customContentRegular:13];
        [registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        [registerFacebook setImageEdgeInsets:UIEdgeInsetsMake(-1, 0, 0, 12)];
        
        [contentView addSubview:registerFacebook];
    }
        
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) / 2.) - (97. / 2.), 120, 97, 96.5)];
        
        UIImageView *filter = [UIImageView imageNamed:@"avatar-filter"];
        UIButton *avatar = [[UIButton alloc] initWithFrame:filter.frame];
        [avatar setImage:[UIImage imageNamed:@"test_user1"] forState:UIControlStateNormal];
        
        [view addSubview:avatar];
        [view addSubview:filter];
        
        [contentView addSubview:view];
    }
    
    {
        //WARNING quand appuie sur suivant dois changer d input
        FLTextField *username = [[FLTextField alloc] initWithIcon:@"field-email" placeholder:@"FIELD_USERNAME" for:user key:@"nick" position:CGPointMake(MARGE, 222)];
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
        
        [contentView addSubview:username];
        [contentView addSubview:name];
        [contentView addSubview:phone];
        [contentView addSubview:email];
        [contentView addSubview:textSecurity];
        [contentView addSubview:password];
        [contentView addSubview:code];
        [contentView addSubview:textFooter];
        
        // WARNING hauteur
        contentView.contentSize = CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(textFooter.frame) + 100);
        NSLog(@"%f", contentView.contentSize.height);
    }
    
    [self.view addSubview:contentView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)presentTimelineController
{
    [[Flooz sharedInstance] signup:user success:NULL failure:NULL];
}

@end
