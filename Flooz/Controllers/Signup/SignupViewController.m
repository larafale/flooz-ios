//
//  SignupViewController.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "SignupViewController.h"

#import "SecureCodeViewController.h"

#define MARGE 20.

@interface SignupViewController (){
    NSMutableDictionary *_user;
    UIButton *registerFacebook;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self.view.backgroundColor = [UIColor customBackground];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(didSignupTouch)];
    
    {
        FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) / 2.) - (97. / 2.), 20, 97, 96.5)];
                
        [view setImageFromURL:[_user objectForKey:@"avatarURL"]];
        [_contentView addSubview:view];
    }
    
    {
        registerFacebook = [[UIButton alloc] initWithFrame:CGRectMake(MARGE, 137, SCREEN_WIDTH - (2 * MARGE), 45)];
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
        FLTextFieldIcon *username;
        
        if([_user objectForKey:@"fb"]){
            registerFacebook.hidden = YES;
            
            username = [[FLTextFieldIcon alloc] initWithIcon:@"field-username" placeholder:@"FIELD_USERNAME" for:_user key:@"nick" position:CGPointMake(MARGE, 137)];
        }
        else{
            username = [[FLTextFieldIcon alloc] initWithIcon:@"field-username" placeholder:@"FIELD_USERNAME" for:_user key:@"nick" position:CGPointMake(MARGE, 190)];
        }
        
        
        FLTextFieldIcon *name = [[FLTextFieldIcon alloc] initWithIcon:@"field-name" placeholder:@"FIELD_FIRSTNAME" for:_user key:@"firstName" position:CGPointMake(MARGE, CGRectGetMaxY(username.frame)) placeholder2:@"FIELD_LASTNAME" key2:@"lastName"];
        FLTextFieldIcon *phone = [[FLTextFieldIcon alloc] initWithIcon:@"field-phone" placeholder:@"FIELD_PHONE" for:_user key:@"phone" position:CGPointMake(MARGE, CGRectGetMaxY(name.frame))];
        FLTextFieldIcon *email = [[FLTextFieldIcon alloc] initWithIcon:@"field-email" placeholder:@"FIELD_EMAIL" for:_user key:@"email" position:CGPointMake(MARGE, CGRectGetMaxY(phone.frame))];
        FLTextFieldIcon *password = [[FLTextFieldIcon alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD" for:_user key:@"password" position:CGPointMake(MARGE, CGRectGetMaxY(email.frame))];
        [password seTsecureTextEntry:YES];
        
 
        [_contentView addSubview:username];
        [_contentView addSubview:name];
        [_contentView addSubview:phone];
        [_contentView addSubview:email];
        [_contentView addSubview:password];
        
        _contentView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(password.frame));
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didSignupTouch
{
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] signup:_user success:NULL failure:NULL];
}

- (void)didFacebookTouch
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] connectFacebook];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidAppear:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardDidAppear:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;

    _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillDisappear
{
    _contentView.contentInset = UIEdgeInsetsZero;
}

@end
