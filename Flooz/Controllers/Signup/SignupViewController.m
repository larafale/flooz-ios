//
//  SignupViewController.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "SignupViewController.h"

#import "SecureCodeViewController.h"

#define MARGE 0.

@interface SignupViewController (){
    NSMutableDictionary *_user;
    UIButton *registerFacebook;
    
    FLTextFieldIcon *name;
    FLTextFieldIcon *email;
    FLTextFieldIcon *username;
    FLTextFieldIcon *phone;
    FLTextFieldIcon *password;
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
    
    
    CGFloat offset = 0;
    
    if([_user objectForKey:@"avatarURL"]){
        FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) / 2.) - (50 / 2.), 10, 50, 50)];
                
        [view setImageFromURL:[_user objectForKey:@"avatarURL"]];
        [_contentView addSubview:view];
        
        offset = CGRectGetMaxY(view.frame);
    }
    else{
        registerFacebook = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH - 40, 45)];
        [registerFacebook setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.5]] forState:UIControlStateNormal];
        
        [registerFacebook setTitle:NSLocalizedString(@"SIGNUP_FACEBOOK", nil) forState:UIControlStateNormal];
        registerFacebook.titleLabel.font = [UIFont customContentRegular:15];
        [registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
         [registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateHighlighted];
        [registerFacebook setImageEdgeInsets:UIEdgeInsetsMake(-1, 0, 0, 12)];
        
        [registerFacebook addTarget:self action:@selector(didFacebookTouch) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:registerFacebook];
        
        offset = CGRectGetMaxY(registerFacebook.frame);
    }
    
    {
        if([_user objectForKey:@"fb"]){
            registerFacebook.hidden = YES;
        }
        
        name = [[FLTextFieldIcon alloc] initWithIcon:@"field-name" placeholder:@"FIELD_FIRSTNAME" for:_user key:@"firstName" position:CGPointMake(MARGE, offset) placeholder2:@"FIELD_LASTNAME" key2:@"lastName"];
        offset = CGRectGetMaxY(name.frame);
        [name addForNextClickTarget:self action:@selector(didNameEndEditing)];
        
        email = [[FLTextFieldIcon alloc] initWithIcon:@"field-email" placeholder:@"FIELD_EMAIL" for:_user key:@"email" position:CGPointMake(MARGE, offset)];
        offset = CGRectGetMaxY(email.frame);
        [email addForNextClickTarget:self action:@selector(didEmailEndEditing)];
        
        username = [[FLTextFieldIcon alloc] initWithIcon:@"field-username" placeholder:@"FIELD_USERNAME" for:_user key:@"nick" position:CGPointMake(MARGE, offset)];
        offset = CGRectGetMaxY(username.frame);
        [username addForNextClickTarget:self action:@selector(didUsernameEndEditing)];
        
        password = [[FLTextFieldIcon alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD" for:_user key:@"password" position:CGPointMake(MARGE, offset)];
        offset = CGRectGetMaxY(password.frame);
        [password seTsecureTextEntry:YES];
        [password addForNextClickTarget:self action:@selector(didPasswordEndEditing)];
        
        phone = [[FLTextFieldIcon alloc] initWithIcon:@"field-phone" placeholder:@"FIELD_PHONE" for:_user key:@"phone" position:CGPointMake(MARGE, offset)];
        offset = CGRectGetMaxY(phone.frame);
        [phone addForNextClickTarget:self action:@selector(didPhoneEndEditing)];
        
 
        [_contentView addSubview:username];
        [_contentView addSubview:name];
        [_contentView addSubview:phone];
        [_contentView addSubview:email];
        [_contentView addSubview:password];
        
        _contentView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(password.frame));
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([_user objectForKey:@"avatarURL"]){
        [username becomeFirstResponder];
        [[Flooz sharedInstance] socketSendSignupFocusUsername];
    }
    else{
        [name becomeFirstResponder];
    }
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
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;

    keyboardHeight += 50;
    
    _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillDisappear
{
    _contentView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - Field callback

- (void)didNameEndEditing
{
    [email becomeFirstResponder];
}

- (void)didEmailEndEditing
{
    [username becomeFirstResponder];
    [[Flooz sharedInstance] socketSendSignupFocusUsername];
}

- (void)didUsernameEndEditing
{
    [password becomeFirstResponder];
}

- (void)didPasswordEndEditing
{
    [phone becomeFirstResponder];
}

- (void)didPhoneEndEditing
{
    UIView *validView = [[[self.navigationItem.rightBarButtonItem customView] subviews] firstObject];
    CGFloat duration = .25;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         validView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:duration
                                               delay:0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              validView.transform = CGAffineTransformIdentity;
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:duration
                                                                    delay:0
                                                                  options:UIViewAnimationOptionAllowUserInteraction
                                                               animations:^{
                                                                   validView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:duration
                                                                                         delay:0
                                                                                       options:UIViewAnimationOptionAllowUserInteraction
                                                                                    animations:^{
                                                                                        validView.transform = CGAffineTransformIdentity;
                                                                                    }
                                                                                    completion:nil];
                                                               }];
                                          }];
                     }];
}

@end
