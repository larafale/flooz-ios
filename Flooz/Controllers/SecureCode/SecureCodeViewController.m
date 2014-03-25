//
//  SecureCodeViewController.m
//  Flooz
//
//  Created by jonathan on 2014-03-17.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "SecureCodeViewController.h"

#import "SecureCodeField.h"
#import "FLKeyboardView.h"

#import <UICKeyChainStore.h>

@interface SecureCodeViewController (){
    UILabel *textCode;
    SecureCodeField *secureCodeField;
    FLKeyboardView *keyboardView;
    UIButton *passwordForget;
    NSMutableDictionary *user;
    
    FLTextFieldIcon *usernameField;
    FLTextFieldIcon *passwordField;
}

@end

@implementation SecureCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_SECURE_CODE", nil);
        _isForChangeSecureCode = NO;
        user = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackground];
    
    {
        textCode = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 200, 20)];
        
        textCode.textColor = [UIColor customBlueLight];
        textCode.font = [UIFont customContentRegular:14];
        
        [self.view addSubview:textCode];
    }
    
    {
        usernameField = [[FLTextFieldIcon alloc] initWithIcon:@"field-username" placeholder:@"FIELD_USERNAME" for:user key:@"login" position:CGPointMake(20, 50)];
        passwordField = [[FLTextFieldIcon alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD" for:user key:@"password" position:CGPointMake(20, CGRectGetMaxY(usernameField.frame))];
     
        usernameField.hidden = YES;
        passwordField.hidden = YES;
        
        [self.view addSubview:usernameField];
        [self.view addSubview:passwordField];
    }
    
    {
        passwordForget = [[UIButton alloc] initWithFrame:CGRectMake(0, 150, CGRectGetWidth(self.view.frame), 50)];
        passwordForget.titleLabel.textAlignment = NSTextAlignmentCenter;
        passwordForget.titleLabel.font = [UIFont customContentRegular:12];
        [passwordForget setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
        [passwordForget setTitle:NSLocalizedString(@"LOGIN_PASSWORD_FORGOT", nil) forState:UIControlStateNormal];
        
        [passwordForget addTarget:self action:@selector(didPasswordForgetTouch) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:passwordForget];
    }
    
    secureCodeField = [SecureCodeField new];
    [self.view addSubview:secureCodeField];
    CGRectSetY(secureCodeField.frame, 55);
    
    keyboardView = [FLKeyboardView new];
    [self.view addSubview:keyboardView];
 
    keyboardView.delegate = secureCodeField;
    secureCodeField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRectSetY(keyboardView.frame, CGRectGetHeight(self.view.frame) - CGRectGetHeight(keyboardView.frame));
    
    [self checkBlockBackButton];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didSecureCodeEnter:(NSString *)secureCode
{
    NSString *currentSecureCode = [UICKeyChainStore stringForKey:@"secureCode"];
 
    NSLog(@"currentCode: %@ %@", currentSecureCode, secureCode);
    
    // 1ere fois qu un code est entré
    if(!currentSecureCode){
        [UICKeyChainStore setString:secureCode forKey:@"secureCode"];
        [self dismissWithSuccess];
    }
    else if([currentSecureCode isEqual:secureCode]){
        if(_isForChangeSecureCode){
            [secureCodeField clean];
            [self clearSecureCode];
            [self checkBlockBackButton];
        }
        else{
            [self dismissWithSuccess];
        }
    }
    else{
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        anim.values = @[
                        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5., 0., 0.)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5., 0., 0.)]
                        ];
        anim.autoreverses = YES;
        anim.repeatCount = 2.;
        anim.delegate = self;
        anim.duration = 0.07;
        [secureCodeField.layer addAnimation:anim forKey:nil];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [secureCodeField clean];
}

- (void)dismissWithSuccess
{
    if([self navigationController]){
        if([[[self navigationController] viewControllers] count] == 1){
            [[self navigationController] dismissViewControllerAnimated:YES completion:_completeBlock];
        }
        else{
            [[self navigationController] popViewControllerAnimated:YES];
            
            if(_completeBlock){
                _completeBlock();
            }
        }
    }
    else{
        [self dismissViewControllerAnimated:YES completion:_completeBlock];
    }
}

- (void)checkBlockBackButton
{
    NSString *currentSecureCode = [UICKeyChainStore stringForKey:@"secureCode"];
    
    if(!currentSecureCode){
        textCode.text = NSLocalizedString(@"SECORE_CODE_TEXT_2", nil);
        passwordForget.hidden = YES;
        
        [[self navigationItem] setHidesBackButton:YES];
        [[self navigationItem] setLeftBarButtonItem:nil];
    }
    else{
        textCode.text = NSLocalizedString(@"SECORE_CODE_TEXT", nil);
        passwordForget.hidden = NO;
    }
}

- (void)clearSecureCode
{
    [UICKeyChainStore removeAllItems];
}

- (void)didPasswordForgetTouch
{
    passwordForget.hidden = YES;
    secureCodeField.hidden = YES;
    keyboardView.hidden = YES;
    
    usernameField.hidden = NO;
    passwordField.hidden = NO;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(login)];
}

- (void)login
{
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] loginForSecureCode:user success:^(id result) {
        
        [secureCodeField clean];
        [self clearSecureCode];
        [self checkBlockBackButton];
        
        self.navigationItem.rightBarButtonItem = nil;
        
        passwordForget.hidden = NO;
        secureCodeField.hidden = NO;
        keyboardView.hidden = NO;
        
        usernameField.hidden = YES;
        passwordField.hidden = YES;
    } failure:NULL];
}

@end
