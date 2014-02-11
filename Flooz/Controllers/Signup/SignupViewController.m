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
    NSMutableDictionary *_user;
    UIButton *registerFacebook;
    
    UIScrollView *_contentView;
}

@end

@implementation SignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithUser:nil];
}

- (id)initWithUser:(NSDictionary *)user
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_SIGNUP", nil);
        if(user){
            _user = [user mutableCopy];
        }
        else{
            _user = [NSMutableDictionary new];
        }
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
        FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) / 2.) - (97. / 2.), 10, 97, 96.5)];
                
        [view setImageFromURL:[_user objectForKey:@"avatarURL"]];
        [_contentView addSubview:view];
    }
    
    {
        registerFacebook = [[UIButton alloc] initWithFrame:CGRectMake(MARGE, 127, SCREEN_WIDTH - (2 * MARGE), 45)];
        [registerFacebook setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.5]] forState:UIControlStateNormal];
        
        [registerFacebook setTitle:NSLocalizedString(@"SIGNUP_FACEBOOK", nil) forState:UIControlStateNormal];
        registerFacebook.titleLabel.font = [UIFont customContentRegular:13];
        [registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
         [registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateHighlighted];
        [registerFacebook setImageEdgeInsets:UIEdgeInsetsMake(-1, 0, 0, 12)];
        
        [registerFacebook addTarget:self action:@selector(didFacebookTouch) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:registerFacebook];
    }
    
    {
        //WARNING quand appuie sur suivant dois changer d input
        FLTextFieldIcon *username = [[FLTextFieldIcon alloc] initWithIcon:@"field-username" placeholder:@"FIELD_USERNAME" for:_user key:@"nick" position:CGPointMake(MARGE, 180)];
        FLTextFieldIcon *name = [[FLTextFieldIcon alloc] initWithIcon:@"field-name" placeholder:@"FIELD_FIRSTNAME" for:_user key:@"firstName" position:CGPointMake(MARGE, CGRectGetMaxY(username.frame)) placeholder2:@"FIELD_LASTNAME" key2:@"lastName"];
        FLTextFieldIcon *phone = [[FLTextFieldIcon alloc] initWithIcon:@"field-phone" placeholder:@"FIELD_PHONE" for:_user key:@"phone" position:CGPointMake(MARGE, CGRectGetMaxY(name.frame))];
        FLTextFieldIcon *email = [[FLTextFieldIcon alloc] initWithIcon:@"field-email" placeholder:@"FIELD_EMAIL" for:_user key:@"email" position:CGPointMake(MARGE, CGRectGetMaxY(phone.frame))];
        
        
        UILabel *textSecurity = [[UILabel alloc] initWithFrame:CGRectMake(MARGE, CGRectGetMaxY(email.frame) + 25, CGRectGetWidth(self.view.frame) - MARGE, 15)];
        
        textSecurity.font = [UIFont customContentRegular:10];
        textSecurity.textColor = [UIColor customBlueLight];
        
        textSecurity.text = NSLocalizedString(@"SIGNUP_SECURITY_INFO", nil);
        
        
        FLTextFieldIcon *password = [[FLTextFieldIcon alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD" for:_user key:@"password" position:CGPointMake(MARGE, CGRectGetMaxY(textSecurity.frame))];
        FLTextFieldIcon *code = [[FLTextFieldIcon alloc] initWithIcon:@"field-code" placeholder:@"FIELD_CODE" for:_user key:@"code" position:CGPointMake(MARGE, CGRectGetMaxY(password.frame))];
        
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
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] signup:_user success:NULL failure:NULL];
}

- (void)didFacebookTouch
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] connectFacebook];
}

@end
