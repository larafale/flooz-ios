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
}

@end

@implementation SecureCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_SECURE_CODE", nil);
        _isForChangeSecureCode = NO;
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
            [[self navigationController] dismissViewControllerAnimated:YES completion:NULL];
        }
        else{
            [[self navigationController] popViewControllerAnimated:YES];
        }
        
        if(_completeBlock){
            _completeBlock();
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
        
        [[self navigationItem] setHidesBackButton:YES];
        [[self navigationItem] setLeftBarButtonItem:nil];
    }
    else{
        textCode.text = NSLocalizedString(@"SECORE_CODE_TEXT", nil);
    }
}

- (void)clearSecureCode
{
    [UICKeyChainStore removeAllItems];
}

@end
