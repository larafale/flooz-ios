//
//  PasswordViewController.m
//  Flooz
//
//  Created by jonathan on 2/14/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "PasswordViewController.h"
#import "FLTextFieldTitle2.h"

@interface PasswordViewController (){
    NSMutableDictionary *_password;
}

@end

@implementation PasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_PASSWORD", nil);
        
        _password = [NSMutableDictionary new];
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
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_CURRENT_PASSWORD" placeholder:@"" for:_password key:@"password" position:CGPointMake(20, 30)];
        [_contentView addSubview:view];
        [view seTsecureTextEntry:YES];
        height = CGRectGetMaxY(view.frame);
    }
        
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_NEW_PASSWORD" placeholder:@"" for:_password key:@"newPassword" position:CGPointMake(20, height + 50)];
        [_contentView  addSubview:view];
        [view seTsecureTextEntry:YES];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_PASSWORD_CONFIRMATION" placeholder:@"" for:_password key:@"confirm" position:CGPointMake(20, height + 50)];
        [_contentView  addSubview:view];
        [view seTsecureTextEntry:YES];
        height = CGRectGetMaxY(view.frame);
    }
    
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), height);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didValidTouch
{
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updatePassword:_password success:^(id result) {
        [self.navigationController popViewControllerAnimated:YES];
    } failure:NULL];
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
    CGFloat keyboardHeight = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillDisappear
{
    _contentView.contentInset = UIEdgeInsetsZero;
}

@end
