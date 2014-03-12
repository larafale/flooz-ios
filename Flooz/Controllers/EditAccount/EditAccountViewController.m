//
//  EditAccountViewController.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EditAccountViewController.h"

#define MARGE 20.

@interface EditAccountViewController (){
    NSMutableDictionary *_user;
    UIButton *registerFacebook;
}

@end

@implementation EditAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_EDIT_ACCOUNT", nil);
        
        FLUser *currentUser = [[Flooz sharedInstance] currentUser];
        
        _user = [NSMutableDictionary new];
        [_user setObject:[NSMutableDictionary new] forKey:@"settings"];
        [[_user objectForKey:@"settings"] setObject:[[currentUser address] mutableCopy] forKey:@"address"];
        
        if([currentUser lastname]){
            [_user setObject:[currentUser lastname] forKey:@"lastName"];
        }
        if([currentUser firstname]){
            [_user setObject:[currentUser firstname] forKey:@"firstName"];
        }
        if([currentUser email]){
            [_user setObject:[currentUser email] forKey:@"email"];
        }
        if([currentUser phone]){
            [_user setObject:[currentUser phone] forKey:@"phone"];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self.view.backgroundColor = [UIColor customBackground];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(didValidTouch)];
        
    CGFloat height = 0;
    
    {
//        FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) / 2.) - (97. / 2.), 10, 97, 96.5)];
        
//        [view setImageFromURL:[_user objectForKey:@"avatarURL"]];
//        [_contentView addSubview:view];
    }

    
    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-name" placeholder:@"FIELD_FIRSTNAME" for:_user key:@"firstName" position:CGPointMake(MARGE, 10) placeholder2:@"FIELD_LASTNAME" key2:@"lastName"];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-phone" placeholder:@"FIELD_PHONE" for:_user key:@"phone" position:CGPointMake(MARGE, height)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-email" placeholder:@"FIELD_EMAIL" for:_user key:@"email" position:CGPointMake(MARGE, height)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }

    {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(MARGE, height + 40, CGRectGetWidth(self.view.frame) - MARGE, 15)];
        view.font = [UIFont customContentRegular:12];
        view.textColor = [UIColor customBlueLight];
        view.text = NSLocalizedString(@"EDIT_ACCOUNT_PERSONAL_INFO", nil);
        
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-address" placeholder:@"FIELD_ADDRESS" for:[[_user objectForKey:@"settings"] objectForKey:@"address"] key:@"address" position:CGPointMake(MARGE, height)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-zip-code" placeholder:@"FIELD_ZIP_CODE" for:[[_user objectForKey:@"settings"] objectForKey:@"address"] key:@"zipCode" position:CGPointMake(MARGE, height)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }

    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-city" placeholder:@"FIELD_CITY" for:[[_user objectForKey:@"settings"] objectForKey:@"address"] key:@"city" position:CGPointMake(MARGE, height)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(MARGE, height + 40, 244, 20)];
        view.font = [UIFont customContentRegular:12];
        view.textColor = [UIColor customBlueLight];
        view.text = NSLocalizedString(@"EDIT_ACCOUNT_SOCIAL_INFO", nil);
        
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_contentView.frame), 56)];
        
        {
            UIView *separatorTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), 1)];
            UIView *separatorBottom = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame) - 1, CGRectGetWidth(view.frame), 1)];
            
            separatorTop.backgroundColor = separatorBottom.backgroundColor = [UIColor customSeparator];
            
            [view addSubview:separatorTop];
            [view addSubview:separatorBottom];
        }
        
        {
            UIImageView *arrow = [UIImageView imageNamed:@"arrow-white-right"];
            CGRectSetXY(arrow.frame, CGRectGetWidth(view.frame) - 24, 26);
            [view addSubview:arrow];
        }
        
        {
            UIImageView *fb = [UIImageView imageNamed:@"facebook2"];
            CGRectSetXY(fb.frame, 24, 21);
            [view addSubview:fb];
        }
        
        [view setTitle:NSLocalizedString(@"EDIT_ACCOUNT_FACEBOOK", nil) forState:UIControlStateNormal];
        [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        view.titleLabel.font = [UIFont customContentLight:14];
        
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didValidTouch
{
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updateUser:_user success:^(id result) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } failure:NULL];
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
