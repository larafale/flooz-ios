//
//  secureCodeLoginViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-08-22.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "secureCodeLoginViewController.h"

#import <UICKeyChainStore.h>

@interface secureCodeLoginViewController () {
    NSMutableDictionary *_userDic;
    UIView *_mainBody;
    
    SecureCodeField *_secureCodeField;
    
    SecureCodeMode currentSecureMode;
    NSString *tempNewSecureCode;
    
    UIButton *passwordForget;
    UILabel *textExplication;
    UILabel *secondTextExplication;
}

@end

@implementation secureCodeLoginViewController

- (id)initWithUser:(NSDictionary *)_user
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"SECURE_LOGIN_TITLE", nil);
        if(_user){
            _userDic = [_user mutableCopy];
        }
        if ([_userDic[@"hasSecureCode"] boolValue]) {
            currentSecureMode = SecureCodeModeNormal;
        }
        else {
            currentSecureMode = SecureCodeModeChangeNew;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor customBackground];
    
    _mainBody = [UIView newWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight() - STATUSBAR_HEIGHT - NAVBAR_HEIGHT)];
    [self.view addSubview:_mainBody];
    
    // Do any additional setup after loading the view from its nib.
    FLKeyboardView *keyboardView = [FLKeyboardView new];
    CGRectSetY(keyboardView.frame, CGRectGetHeight(_mainBody.frame)-CGRectGetHeight(keyboardView.frame));
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(),  CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(keyboardView.frame))];
    [backView setBackgroundColor:[UIColor customBackground]];
    [_mainBody addSubview:backView];
    
    _secureCodeField = [SecureCodeField new];
    
    [_mainBody addSubview:keyboardView];
    keyboardView.delegate = _secureCodeField;
    _secureCodeField.delegate = self;
    
    textExplication = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, PPScreenWidth()-28, 50)];
    textExplication.textColor = [UIColor customPlaceholder];
    textExplication.font = [UIFont customTitleExtraLight:14];
    textExplication.numberOfLines = 0;
    textExplication.textAlignment = NSTextAlignmentCenter;
    
    if(currentSecureMode == SecureCodeModeNormal){
        textExplication.text = NSLocalizedString(@"SECORE_CODE_TEXT_CURRENT", nil);
    }
    else if(currentSecureMode == SecureCodeModeChangeNew){
        textExplication.text = NSLocalizedString(@"SECORE_CODE_CHOOSE", nil);
    }
    else if(currentSecureMode == SecureCodeModeChangeConfirm){
        textExplication.text = NSLocalizedString(@"SECORE_CODE_CHOOSE_CONFIRM", nil);
    }
    
    secondTextExplication = [[UILabel alloc] initWithFrame:CGRectMake(14, CGRectGetMaxY(_secureCodeField.frame), PPScreenWidth()-28, 50)];
    secondTextExplication.textColor = [UIColor customPlaceholder];
    secondTextExplication.font = [UIFont customTitleExtraLight:14];
    secondTextExplication.numberOfLines = 0;
    secondTextExplication.textAlignment = NSTextAlignmentCenter;
    secondTextExplication.text = NSLocalizedString(@"SECORE_CODE_TEXT_FIRST_TIME", nil);
    
    UIView *_mainContent = [UIView newWithFrame:CGRectMake(0, 0, PPScreenWidth(), 0)];
    [_mainContent addSubview:_secureCodeField];
    [_mainContent addSubview:textExplication];
    [_mainContent addSubview:secondTextExplication];
    
    CGSize s = [self sizeExpectedForView:textExplication];
    CGRectSetHeight(textExplication.frame, s.height);
    
    CGSize s2 = [self sizeExpectedForView:secondTextExplication];
    CGRectSetHeight(textExplication.frame, s2.height*2);
    
    CGRectSetY(_secureCodeField.frame, CGRectGetMaxY(textExplication.frame) + 5.0f);
    CGRectSetY(secondTextExplication.frame, CGRectGetMaxY(_secureCodeField.frame));
    CGRectSetHeight(_mainContent.frame, CGRectGetMaxY(secondTextExplication.frame));
    [_mainContent setCenter:CGPointMake(PPScreenWidth()/2, CGRectGetMidY(backView.frame) - 4)];
    [backView addSubview:_mainContent];
    
    {
        passwordForget = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(backView.frame) - 50, CGRectGetWidth(self.view.frame), 50)];
        passwordForget.titleLabel.textAlignment = NSTextAlignmentCenter;
        passwordForget.titleLabel.font = [UIFont customContentRegular:12];
        [passwordForget setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
        [passwordForget setTitle:NSLocalizedString(@"SECURE_CODE_FORGOT", nil) forState:UIControlStateNormal];
        
        [passwordForget addTarget:self action:@selector(didPasswordForgetTouch) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:passwordForget];
    }
    
    
    
    [self refreshText];
}

- (void)didPasswordForgetTouch
{
    currentSecureMode = SecureCodeModeForget;
    [appDelegate showLoginWithUser:_userDic];
}

- (void)didSecureCodeEnter:(NSString *)secureCode {
    if(currentSecureMode == SecureCodeModeNormal){
        [_userDic setValue:secureCode forKey:@"password"];
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] loginWithCodeForUser:_userDic success:nil failure:^(NSError *error) {
            [_secureCodeField clean];
            [[Flooz sharedInstance] hideLoadView];
        }];
    }
    else if (currentSecureMode == SecureCodeModeChangeNew) {
        tempNewSecureCode = secureCode;
        currentSecureMode = SecureCodeModeChangeConfirm;
        [_secureCodeField clean];
        [self refreshText];
    }
    else if(currentSecureMode == SecureCodeModeChangeConfirm){
        if ([tempNewSecureCode isEqualToString:secureCode]) {
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] updateUser:@{@"secureCode": secureCode} success:^(id result) {
                [[Flooz sharedInstance] hideLoadView];
                [UICKeyChainStore setString:secureCode forKey:[self keyForSecureCode]];
                [appDelegate goToAccountViewController];
            } failure:NULL];
        }
        else {
            currentSecureMode = SecureCodeModeChangeNew;
            [self startAnmiationBadCode];
            [_secureCodeField clean];
            [self refreshText];
        }
    }
}

- (void)startAnmiationBadCode
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.values = @[
                    [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5., 0., 0.)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5., 0., 0.)]
                    ];
    anim.autoreverses = YES;
    anim.repeatCount = 2.;
    anim.delegate = self;
    anim.duration = 0.08;
    [_secureCodeField.layer addAnimation:anim forKey:nil];
}

- (void)refreshText {
    if(currentSecureMode == SecureCodeModeNormal){
        textExplication.text = NSLocalizedString(@"SECORE_CODE_TEXT_CURRENT", nil);
        [passwordForget setHidden:NO];
        [secondTextExplication setHidden:YES];
    }
    else if(currentSecureMode == SecureCodeModeChangeNew){
        textExplication.text = NSLocalizedString(@"SECORE_CODE_CHOOSE", nil);
        [passwordForget setHidden:YES];
        [secondTextExplication setHidden:NO];
    }
    else if(currentSecureMode == SecureCodeModeChangeConfirm){
        textExplication.text = NSLocalizedString(@"SECORE_CODE_CHOOSE_CONFIRM", nil);
        [passwordForget setHidden:YES];
        [secondTextExplication setHidden:YES];
    }
}

- (NSString *)keyForSecureCode
{
    return [NSString stringWithFormat:@"secureCode-%@", [[[Flooz sharedInstance] currentUser] userId]];
}

- (CGSize)sizeExpectedForView:(UIView *)view {
    CGSize expectedSize;
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        expectedSize = [label.text sizeWithAttributes:@{NSFontAttributeName: label.font}];
    }
    else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        expectedSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
    }
    return expectedSize;
}

@end
