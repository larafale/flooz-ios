//
//  HomeViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "HomeViewController.h"

#import "AppDelegate.h"
#import "FLKeyboardView.h"
#import "FLHomeTextField.h"

@interface HomeViewController (){
    UIButton *loginButton;
    UIButton *facebookbButton;
    
    UIImageView *logo;
    
    NSMutableDictionary *phone;
    
    FLHomeTextField *phoneField;
    FLKeyboardView *inputView;
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
    
    if(SCREEN_HEIGHT < 500){
        CGRectSetXY(logo.frame, (SCREEN_WIDTH - logo.frame.size.width) / 2., 90);
    }
    else{
        CGRectSetXY(logo.frame, (SCREEN_WIDTH - logo.frame.size.width) / 2., 60);
    }
    
    {
        loginButton = [UIButton new];
        
        loginButton.backgroundColor = [UIColor clearColor];
        loginButton.titleLabel.font = [UIFont customTitleLight:20];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginButton setTitle:NSLocalizedString(@"HOME_LOGIN", nil) forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(didConnectTouch) forControlEvents:UIControlEventTouchUpInside];
        
//        [_contentView addSubview:loginButton];
    }
    
    {
        phoneField = [[FLHomeTextField alloc] initWithPlaceholder:@"06 ou code" for:phone key:@"phone" position:CGPointMake(20, 200)];
        
        [phoneField addForNextClickTarget:self action:@selector(didConnectTouch)];
        
        [_contentView addSubview:phoneField];
        
        inputView = [FLKeyboardView new];
        [inputView setKeyboardChangeable];
        inputView.textField = phoneField.textfield;
        phoneField.textfield.inputView = inputView;

    }
    
    loginButton.frame = CGRectMake(20, CGRectGetMaxY(phoneField.frame) + 5, SCREEN_WIDTH - 40, 39);
    _contentView.contentSize = CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(loginButton.frame) + 5);
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [[Flooz sharedInstance] showLoadView];
        [appDelegate clearSavedViewController];
        [[Flooz sharedInstance] loginWithPhone:phone[@"phone"]];
    }
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
    
    _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight + 55, 0);
}

- (void)keyboardWillDisappear
{
    _contentView.contentInset = UIEdgeInsetsZero;
}

@end
