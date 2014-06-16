//
//  HomeViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "HomeViewController.h"

#import "AppDelegate.h"

@interface HomeViewController (){
    UIButton *loginButton;
    UIButton *facebookbButton;
    
    UIImageView *logo;
    
    NSMutableDictionary *phone;
    
    FLTextField *phoneField;
}

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        phone = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    
    {
        logo = [UIImageView imageNamed:@"home-logo"];
        CGRectSetWidthHeight(logo.frame, 105, 105);
        CGRectSetXY(logo.frame, (SCREEN_WIDTH - logo.frame.size.width) / 2., 60);
        [_contentView addSubview:logo];
    }
    
    {
        loginButton = [UIButton new];
        
        loginButton.backgroundColor = [UIColor customBlue];
        loginButton.titleLabel.font = [UIFont customTitleLight:14];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        loginButton.layer.opacity = 0.7;
        loginButton.layer.cornerRadius = 2.;
        [loginButton setTitle:NSLocalizedString(@"HOME_LOGIN", nil) forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(didConnectTouch) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:loginButton];
    }
    
    {
//        facebookbButton = [UIButton new];
//        
//        facebookbButton.backgroundColor = [UIColor customBlue];
//        facebookbButton.titleLabel.font = loginButton.titleLabel.font;
//        facebookbButton.layer.opacity = loginButton.layer.opacity;
//        facebookbButton.layer.cornerRadius = loginButton.layer.cornerRadius;
//        [facebookbButton setTitle:@"Facebook" forState:UIControlStateNormal];
//        [facebookbButton addTarget:self action:@selector(didFacebookTouch) forControlEvents:UIControlEventTouchUpInside];
//        
//        [_contentView addSubview:facebookbButton];
    }
    
    {
        phoneField = [[FLTextField alloc] initWithPlaceholder:@"N° de mobile ou Code invitation" for:phone key:@"phone" position:CGPointMake(20, 220)];
        
        phoneField.backgroundColor = [UIColor whiteColor];
        phoneField.layer.cornerRadius = 2.;
        phoneField.clipsToBounds = YES;
        phoneField.textfield.textColor = [UIColor customBackground];
        
        [_contentView addSubview:phoneField];
    }
    
    loginButton.frame = CGRectMake(20, 270, SCREEN_WIDTH - 40, 39);
    _contentView.contentSize = CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(loginButton.frame));
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    _contentView.contentInset = UIEdgeInsetsZero;
    
    [phoneField becomeFirstResponder];
}

- (void)didConnectTouch
{
    [[self view] endEditing:YES];
    
    if(phone[@"phone"] && ![phone[@"phone"] isBlank]){
        [[Flooz sharedInstance] loginWithPhone:phone[@"phone"]];
    }
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
