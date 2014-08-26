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
    UIView *_mainBody;
    
    UILabel *textCode;
    UILabel *firstTimeText;
    SecureCodeField *secureCodeField;
    FLKeyboardView *keyboardView;
    UIButton *passwordForget;
    NSMutableDictionary *user;
    
    FLTextFieldIcon *usernameField;
    FLTextFieldIcon *passwordField;
    
    SecureCodeMode currentSecureMode;
    NSString *tempNewSecureCode;
}

@end

@implementation SecureCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_SECURE_CODE", nil);
        
        user = [NSMutableDictionary new];
        
        _isForChangeSecureCode = NO;
        currentSecureMode = SecureCodeModeNormal;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackground];
    
    _mainBody = [UIView newWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight() - STATUSBAR_HEIGHT - NAVBAR_HEIGHT)];
    [self.view addSubview:_mainBody];
    
    keyboardView = [FLKeyboardView new];
    CGRectSetY(keyboardView.frame, CGRectGetHeight(_mainBody.frame)-CGRectGetHeight(keyboardView.frame));
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(),  CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(keyboardView.frame))];
    [backView setBackgroundColor:[UIColor customBackground]];
    [_mainBody addSubview:backView];
    
    
    secureCodeField = [SecureCodeField new];
    
    [_mainBody addSubview:keyboardView];
    keyboardView.delegate = secureCodeField;
    secureCodeField.delegate = self;
    
    textCode = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, PPScreenWidth()-28, 50)];
    textCode.textColor = [UIColor customPlaceholder];
    textCode.font = [UIFont customTitleExtraLight:14];
    textCode.numberOfLines = 0;
    textCode.textAlignment = NSTextAlignmentCenter;
    
    if(currentSecureMode == SecureCodeModeNormal){
        textCode.text = NSLocalizedString(@"SECORE_CODE_TEXT_CURRENT", nil);
    }
    else if(currentSecureMode == SecureCodeModeForget){
        textCode.text = NSLocalizedString(@"SECORE_CODE_TEXT_LOGIN", nil);
    }
    else if(currentSecureMode == SecureCodeModeChangeOld){
        textCode.text = NSLocalizedString(@"SECORE_CODE_TEXT_OLD", nil);
    }
    else if(currentSecureMode == SecureCodeModeChangeNew){
        textCode.text = NSLocalizedString(@"SECORE_CODE_TEXT_NEW", nil);
    }
    else if(currentSecureMode == SecureCodeModeChangeConfirm){
        textCode.text = NSLocalizedString(@"SECORE_CODE_TEXT_CONFIRM", nil);
    }
    
    firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(14, CGRectGetMaxY(secureCodeField.frame), PPScreenWidth()-28, 50)];
    firstTimeText.textColor = [UIColor customPlaceholder];
    firstTimeText.font = [UIFont customTitleExtraLight:14];
    firstTimeText.numberOfLines = 0;
    firstTimeText.textAlignment = NSTextAlignmentCenter;
    firstTimeText.text = NSLocalizedString(@"SECORE_CODE_TEXT_FIRST_TIME", nil);
    
    UIView *_mainContent = [UIView newWithFrame:CGRectMake(0, 0, PPScreenWidth(), 0)];
    [_mainContent addSubview:secureCodeField];
    [_mainContent addSubview:textCode];
    [_mainContent addSubview:firstTimeText];
    
    CGSize s = [self sizeExpectedForView:textCode];
    CGRectSetHeight(textCode.frame, s.height);
    
    CGSize s2 = [self sizeExpectedForView:firstTimeText];
    CGRectSetHeight(firstTimeText.frame, s2.height*2);
    
    CGRectSetY(secureCodeField.frame, CGRectGetMaxY(textCode.frame) + 10.0f);
    CGRectSetY(firstTimeText.frame, CGRectGetMaxY(secureCodeField.frame));
    CGRectSetHeight(_mainContent.frame, CGRectGetMaxY(firstTimeText.frame));
    [_mainContent setCenter:CGPointMake(PPScreenWidth()/2, CGRectGetMidY(backView.frame) - 4)];
    [backView addSubview:_mainContent];
    
    {
        passwordForget = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(backView.frame) - 50, PPScreenWidth(), 50)];
        passwordForget.titleLabel.textAlignment = NSTextAlignmentCenter;
        passwordForget.titleLabel.font = [UIFont customContentRegular:12];
        [passwordForget setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
        [passwordForget setTitle:NSLocalizedString(@"SECURE_CODE_FORGOT", nil) forState:UIControlStateNormal];
        
        [passwordForget addTarget:self action:@selector(didPasswordForgetTouch) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:passwordForget];
    }
    
    {
        usernameField = [[FLTextFieldIcon alloc] initWithIcon:@"field-username" placeholder:@"FIELD_USERNAME" for:user key:@"login" position:CGPointMake(20, CGRectGetMaxY(textCode.frame) + 10.0f)];
        passwordField = [[FLTextFieldIcon alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD" for:user key:@"password" position:CGPointMake(20, CGRectGetMaxY(usernameField.frame))];
        [passwordField seTsecureTextEntry:YES];
        
        [_mainContent addSubview:usernameField];
        [_mainContent addSubview:passwordField];
        CGRectSetHeight(_mainContent.frame, CGRectGetMaxY(passwordField.frame));
        [_mainContent setCenter:CGPointMake(PPScreenWidth()/2, CGRectGetMidY(backView.frame) - 4)];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if([[self class] secureCodeForCurrentUser] == nil){
        currentSecureMode = SecureCodeModeChangeNew;
    }
    else if(_isForChangeSecureCode){
        currentSecureMode = SecureCodeModeChangeOld;
    }
    
    [self refreshController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Sinon le bouton retour ne disparait pas
    [self refreshController];

    CGRectSetY(keyboardView.frame, CGRectGetHeight(_mainBody.frame)-CGRectGetHeight(keyboardView.frame));
}

- (void)didSecureCodeEnter:(NSString *)secureCode
{
    NSString *currentSecureCode = [[self class] secureCodeForCurrentUser];
 
    NSLog(@"currentCode: %@ %@", currentSecureCode, secureCode);
    
    if(currentSecureMode == SecureCodeModeNormal){
        if([currentSecureCode isEqual:secureCode]){
            [self dismissWithSuccess];
        }
        else{
            [self startAnmiationBadCode];
        }
    }
    else if(currentSecureMode == SecureCodeModeChangeOld){
        if([currentSecureCode isEqual:secureCode]){
            [secureCodeField clean];
            currentSecureMode = SecureCodeModeChangeNew;
            [self refreshController];
        }
        else{
            [self startAnmiationBadCode];
        }
    }
    else if(currentSecureMode == SecureCodeModeChangeNew){
        tempNewSecureCode = secureCode;
        currentSecureMode = SecureCodeModeChangeConfirm;
        [secureCodeField clean];
        [self refreshController];
    }
    else if(currentSecureMode == SecureCodeModeChangeConfirm){
        if([tempNewSecureCode isEqual:secureCode]){
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] updateUser:@{@"secureCode": secureCode} success:^(id result) {
                [[Flooz sharedInstance] hideLoadView];
                [[self class] setSecureCodeForCurrentUser:secureCode];
                [self dismissWithSuccess];
            } failure:NULL];
        }
        else{
            [self startAnmiationBadCode];
            
            currentSecureMode = SecureCodeModeChangeNew;
            [self refreshController];
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
    [secureCodeField.layer addAnimation:anim forKey:nil];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    keyboardView.userInteractionEnabled = NO;
    passwordForget.userInteractionEnabled = NO;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [secureCodeField clean];
    keyboardView.userInteractionEnabled = YES;
    passwordForget.userInteractionEnabled = YES; // Sinon peut appuyer sur le bouton derriere le clavier
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

- (void)didPasswordForgetTouch
{
    currentSecureMode = SecureCodeModeForget;
    [self refreshController];
}

- (void)refreshController
{
    NSString *currentSecureCode = [[self class] secureCodeForCurrentUser];
    
    // Visibilité
    if(currentSecureMode == SecureCodeModeForget){
        passwordForget.hidden = YES;
        secureCodeField.hidden = YES;
        keyboardView.hidden = YES;
        
        usernameField.hidden = NO;
        passwordField.hidden = NO;
        
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(login)];
    }
    else{
        passwordForget.hidden = NO;
        secureCodeField.hidden = NO;
        keyboardView.hidden = NO;
        
        usernameField.hidden = YES;
        passwordField.hidden = YES;
        
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    if(currentSecureMode == SecureCodeModeChangeNew){
        firstTimeText.hidden = NO;
        passwordForget.hidden = YES;
    }
    else{
        firstTimeText.hidden = YES;
    }
    
    if(currentSecureMode == SecureCodeModeChangeNew || currentSecureMode == SecureCodeModeChangeConfirm){
        passwordForget.hidden = YES;
    }
    
    if(!currentSecureCode){        
        self.navigationItem.hidesBackButton = YES;
        //self.navigationItem.leftBarButtonItem = nil;
    }

    BOOL isFirstView = textCode.text == nil || [textCode.text isBlank];
    
    // Textes
    if(currentSecureMode == SecureCodeModeNormal){
        textCode.text = NSLocalizedString(@"SECORE_CODE_TEXT_CURRENT", nil);
    }
    else if(currentSecureMode == SecureCodeModeForget){
        textCode.text = NSLocalizedString(@"SECORE_CODE_TEXT_LOGIN", nil);
    }
    else if(currentSecureMode == SecureCodeModeChangeOld){
        textCode.text = NSLocalizedString(@"SECORE_CODE_TEXT_OLD", nil);
    }
    else if(currentSecureMode == SecureCodeModeChangeNew){
        textCode.text = NSLocalizedString(@"SECORE_CODE_TEXT_NEW", nil);
    }
    else if(currentSecureMode == SecureCodeModeChangeConfirm){
        textCode.text = NSLocalizedString(@"SECORE_CODE_TEXT_CONFIRM", nil);
    }
    
    
    if(!isFirstView){
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        animation.values = @[
                                  @1,
                                  @0,
                                  @1
                                  ];
        
        animation.repeatCount = 1;
        animation.duration  = .8;
        
        [textCode.layer addAnimation:animation forKey:@"opacity"];
    }
}

#pragma mark - SecureCode

+ (NSString *)keyForSecureCode
{
    return [NSString stringWithFormat:@"secureCode-%@", [[[Flooz sharedInstance] currentUser] userId]];
}

+ (NSString *)secureCodeForCurrentUser
{
    return [UICKeyChainStore stringForKey:[self keyForSecureCode]];
}

+ (void)setSecureCodeForCurrentUser:(NSString *)secureCode
{
    [UICKeyChainStore setString:secureCode forKey:[self keyForSecureCode]];
}

+ (BOOL)hasSecureCodeForCurrentUser
{
    return [self secureCodeForCurrentUser] != nil;
}

+ (void)clearSecureCode
{
    [UICKeyChainStore removeItemForKey:[self keyForSecureCode]];
}

#pragma mark -helpers
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
