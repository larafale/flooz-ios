//
//  SecureCodeViewController.m
//  Flooz
//
//  Created by olivier on 2014-03-17.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SecureCodeViewController.h"

#import "SecureCodeField.h"
#import "FLKeyboardView.h"

#import <UICKeyChainStore.h>
#import <LocalAuthentication/LocalAuthentication.h>

#define numberOfDigit 4

@interface SecureCodeViewController () {
    NSMutableDictionary *_userDic;
    UIView *_mainBody;
    UIView *_headerView;
    
    NSString *tempNewSecureCode;
    
    UILabel *_textExplication;
    
    FLKeyboardView *_keyboardView;
    
    FLTextFieldSignup *_usernameField;
    FLTextFieldSignup *_passwordField;
    UIButton *_passwordForgetButton;
    FLActionButton *_nextButton;
    
    NSString *_userSecretQuestion;
    
    UILabel *_secretExplication;
    UILabel *_secretQuestion;
    FLTextFieldSignup *_secretAnswer;
    FLTextFieldSignup *_secretPassword;
    FLTextFieldSignup *_secretPasswordConfirm;
    FLActionButton *_secretNextButton;
    UIButton *_secretForgotButton;
    
    UIButton *_forgotButton;
    UIButton *_cleanButton;
    UIButton *_touchIDButton;
    
    NSString *currentValue;
    CodePinView *_codePinView;
    NumPadAppleStyle *_padNumber;
    
    BOOL isSignup;
    UIImageView *backgroundImage;
}

@end

static BOOL canTouchID = YES;

@implementation SecureCodeViewController

@synthesize currentSecureMode;

- (id)init {
    self = [super init];
    if (self) {
        self.blockTouchID = NO;
    }
    return self;
}

- (id)initWithUser:(NSDictionary *)_user {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        isSignup = NO;
        if (_user) {
            _userDic = [_user mutableCopy];
            isSignup = YES;
            canTouchID = YES;
            
            if ([_userDic[@"hasSecureCode"] boolValue] && [_userDic[@"onKnowDevice"] boolValue]) {
                currentSecureMode = SecureCodeModeNormal;
            }
            else {
                currentSecureMode = SecureCodeModeForget;
            }
        }
        else {
            _userDic = [NSMutableDictionary new];
            currentSecureMode = SecureCodeModeChangeNew;
        }
        
        _isForChangeSecureCode = NO;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _userDic = [NSMutableDictionary new];
        
        _isForChangeSecureCode = NO;
        currentSecureMode = SecureCodeModeNormal;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (_isForChangeSecureCode) {
        currentSecureMode = SecureCodeModeChangeOld;
    }
    
    [self displayCorrectView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    {
        NSString *imageNamed = @"LaunchImage";
        if (IS_IPHONE4) {
            imageNamed = [imageNamed stringByAppendingString:@"-iphone4"];
        }
        backgroundImage = [UIImageView newWithImage:[UIImage imageNamed:imageNamed]];
        [self.view addSubview:backgroundImage];
    }
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, STATUSBAR_HEIGHT, PPScreenWidth(), 60.0f)];
    
    [self.view addSubview:_headerView];
    
    {
        UIImage *logoTitle = [UIImage imageNamed:@"home-title"];
        UIImageView *title = [[UIImageView alloc] initWithImage:logoTitle];
        [_headerView addSubview:title];
        
        CGRectSetX(title.frame, (CGRectGetWidth(_headerView.frame) - CGRectGetWidth(title.frame)) / 2.0f);
        CGRectSetY(title.frame, (CGRectGetHeight(_headerView.frame) - CGRectGetHeight(title.frame)) / 2.0f);
    }
    
    {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 2, 30, CGRectGetHeight(_headerView.frame))];
        [backButton setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissBack) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:backButton];
    }
    
    _mainBody = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_headerView.frame), PPScreenWidth(), PPScreenHeight() - CGRectGetMaxY(_headerView.frame))];
    [self.view addSubview:_mainBody];
    
    {
        _textExplication = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), 40)];
        _textExplication.textColor = [UIColor customGrey];
        _textExplication.font = [UIFont customTitleLight:18];
        _textExplication.numberOfLines = 0;
        _textExplication.textAlignment = NSTextAlignmentCenter;
        _textExplication.text = NSLocalizedString(@"SECORE_CODE_TEXT_SIGNUP_NEW", nil);
        CGSize s = [self sizeExpectedForView:_textExplication];
        CGRectSetHeight(_textExplication.frame, s.height * 2);
        
        [_mainBody addSubview:_textExplication];
        
        if (currentSecureMode == SecureCodeModeNormal) {
            _textExplication.text = NSLocalizedString(@"SECORE_CODE_TEXT_CURRENT", nil);
        }
        else if (currentSecureMode == SecureCodeModeChangeNew) {
            _textExplication.text = NSLocalizedString(@"SECORE_CODE_TEXT_NEW", nil);
        }
        else if (currentSecureMode == SecureCodeModeChangeConfirm) {
            _textExplication.text = NSLocalizedString(@"SECORE_CODE_TEXT_CONFIRM", nil);
        }
    }
    
    [self prepareViews];
    
    currentValue = @"";
}

#pragma mark - prepare Views

- (void)prepareViews {
    [self prepareViewNormal];
    [self prepareViewLogin];
    [self prepareViewEdit];
//    [self prepareViewSecret];
}

- (void)prepareViewNormal {
    {
        CGFloat xS = PPScreenWidth() / 3.5f;
        _codePinView = [[CodePinView alloc] initWithNumberOfDigit:numberOfDigit andFrame:CGRectMake(xS, CGRectGetMaxY(_textExplication.frame) - 5.0f, PPScreenWidth() - xS * 2.0f, 40.0f)];
        _codePinView.delegate = self;
        [_mainBody addSubview:_codePinView];
    }
    
    {
        _padNumber = [[NumPadAppleStyle alloc] initWithHeight:CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_codePinView.frame) - 20.0f];
        CGRectSetY(_padNumber.frame, CGRectGetMaxY(_codePinView.frame) + 10.0f);
        CGRectSetX(_padNumber.frame, (PPScreenWidth() - CGRectGetWidth(_padNumber.frame)) / 2.0f);
        [_padNumber setDelegate:self];
        [_mainBody addSubview:_padNumber];
    }
    
    {
        _forgotButton = [UIButton newWithFrame:CGRectMake(0.0f, CGRectGetHeight(_mainBody.frame) - 50.0f, PPScreenWidth() / 3.0f, 40.0f)];
        [_forgotButton setTitle:NSLocalizedString(@"Forgot", @"") forState:UIControlStateNormal];
        [_forgotButton addTarget:self action:@selector(didCodeForgetTouch) forControlEvents:UIControlEventTouchUpInside];
        [_forgotButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_forgotButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
        [_mainBody addSubview:_forgotButton];
    }
    
    {
        _cleanButton = [UIButton newWithFrame:CGRectMake(PPScreenWidth() / 3.0f * 2.0f, CGRectGetHeight(_mainBody.frame) - 50.0f, PPScreenWidth() / 3.0f, 40.0f)];
        [_cleanButton setTitle:NSLocalizedString(@"Erase", @"") forState:UIControlStateNormal];
        [_cleanButton addTarget:self action:@selector(clean) forControlEvents:UIControlEventTouchUpInside];
        [_cleanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cleanButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
        [_cleanButton setHidden:YES];
        [_mainBody addSubview:_cleanButton];
    }
    
    {
        _touchIDButton = [UIButton newWithFrame:CGRectMake(PPScreenWidth() / 3.0f * 2.0f, CGRectGetHeight(_mainBody.frame) - 50.0f, PPScreenWidth() / 3.0f, 40.0f)];
        [_touchIDButton setTitle:NSLocalizedString(@"SECORE_CODE_TOUCHID", nil) forState:UIControlStateNormal];
        [_touchIDButton addTarget:self action:@selector(useTouchID) forControlEvents:UIControlEventTouchUpInside];
        [_touchIDButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_touchIDButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
        [_touchIDButton setHidden:YES];
        [_mainBody addSubview:_touchIDButton];
    }
}

- (void)prepareViewLogin {
    {
        if (!isSignup) {
            [_userDic setValue:[[[Flooz sharedInstance] currentUser] username] forKey:@"login"];
        }
        _usernameField = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_USERNAME" for:_userDic key:@"login" position:CGPointMake(20.0f, 0.0f)];
        [_usernameField addForNextClickTarget:self action:@selector(focusPassword)];
        [_mainBody addSubview:_usernameField];
    }
    
    {
        [_userDic setObject:@"" forKey:@"password"];
        _passwordField = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_PASSWORD_LOGIN" for:_userDic key:@"password" position:CGPointMake(20.0f, CGRectGetMaxY(_usernameField.frame))];
        [_passwordField seTsecureTextEntry:YES];
        [_passwordField addForNextClickTarget:self action:@selector(checkNextOk)];
        [_passwordField addForTextChangeTarget:self action:@selector(checkNextOk)];
        [_mainBody addSubview:_passwordField];
    }
    
    {
        _passwordForgetButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(_mainBody.frame) - 216.0f - 40.0f, PPScreenWidth(), 30)];
        _passwordForgetButton.titleLabel.textAlignment = NSTextAlignmentRight;
        _passwordForgetButton.titleLabel.font = [UIFont customContentRegular:12];
        [_passwordForgetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_passwordForgetButton setTitle:NSLocalizedString(@"LOGIN_PASSWORD_FORGOT", nil) forState:UIControlStateNormal];
        [_passwordForgetButton addTarget:self action:@selector(didPasswordForgetTouch) forControlEvents:UIControlEventTouchUpInside];
        [_mainBody addSubview:_passwordForgetButton];
    }
    
    {
        _nextButton = [[FLActionButton alloc] initWithFrame:CGRectMake(20.0f, CGRectGetMaxY(_passwordField.frame) + 10.0f, PPScreenWidth() - 20.0f * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"SIGNUP_NEXT_BUTTON", nil)];
        [_nextButton setEnabled:YES];
        [_nextButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        [_mainBody addSubview:_nextButton];
    }
}

- (void)prepareViewSecret {
    
    _secretExplication = [[UILabel alloc] initWithText:NSLocalizedString(@"SETTINGS_SECRET_INFOS", nil) textColor:[UIColor whiteColor] font:[UIFont customContentRegular:17] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    CGRectSetPosition(_secretExplication.frame, CGRectGetWidth(_mainBody.frame) / 2 - CGRectGetWidth(_secretExplication.frame) / 2, 20);
    [_mainBody addSubview:_secretExplication];
    
    _secretQuestion = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_secretExplication.frame) + 10, CGRectGetWidth(_mainBody.frame) - 20, 20)];
    [_secretQuestion setFont:[UIFont customContentRegular:18]];
    [_secretQuestion setTextColor:[UIColor customBlue]];
    [_secretQuestion setTextAlignment:NSTextAlignmentCenter];
    [_mainBody addSubview:_secretQuestion];
    
    _secretAnswer = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_SECRET_ANSWER" for:_userDic key:@"secretAnswer" position:CGPointMake(20.0f, CGRectGetMaxY(_secretQuestion.frame))];
    [_secretAnswer addForNextClickTarget:self action:@selector(checkNextOk)];
    [_secretAnswer addForTextChangeTarget:self action:@selector(checkNextOk)];
    [_mainBody addSubview:_secretAnswer];
    
    _secretPassword = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_NEW_PASSWORD" for:_userDic key:@"newPassword" position:CGPointMake(20.0f, CGRectGetMaxY(_secretAnswer.frame))];
    [_secretPassword seTsecureTextEntry:YES];
    [_secretPassword addForNextClickTarget:self action:@selector(checkNextOk)];
    [_secretPassword addForTextChangeTarget:self action:@selector(checkNextOk)];
    [_mainBody addSubview:_secretPassword];
    
    _secretPasswordConfirm = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_PASSWORD_CONFIRMATION" for:_userDic key:@"confirm" position:CGPointMake(20.0f, CGRectGetMaxY(_secretPassword.frame))];
    [_secretPasswordConfirm seTsecureTextEntry:YES];
    [_secretPasswordConfirm addForNextClickTarget:self action:@selector(checkNextOk)];
    [_secretPasswordConfirm addForTextChangeTarget:self action:@selector(checkNextOk)];
    [_mainBody addSubview:_secretPasswordConfirm];
    
    _secretNextButton = [[FLActionButton alloc] initWithFrame:CGRectMake(20.0f, CGRectGetMaxY(_secretPasswordConfirm.frame) + 10.0f, PPScreenWidth() - 20.0f * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"SIGNUP_NEXT_BUTTON", nil)];
    [_secretNextButton setEnabled:NO];
    [_secretNextButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [_mainBody addSubview:_secretNextButton];

    _secretForgotButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_secretNextButton.frame) + 10, PPScreenWidth(), 30)];
    _secretForgotButton.titleLabel.textAlignment = NSTextAlignmentRight;
    _secretForgotButton.titleLabel.font = [UIFont customContentRegular:12];
    [_secretForgotButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_secretForgotButton setTitle:NSLocalizedString(@"LOGIN_SECRET_FORGOT", nil) forState:UIControlStateNormal];
    [_secretForgotButton addTarget:self action:@selector(didSecretForgetTouch) forControlEvents:UIControlEventTouchUpInside];
    [_mainBody addSubview:_secretForgotButton];
}

- (void)prepareViewEdit {
    _keyboardView = [FLKeyboardView new];
    CGRectSetY(_keyboardView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(_keyboardView.frame));
    [_mainBody addSubview:_keyboardView];
    _keyboardView.delegate = _codePinView;
}

- (void)focusPassword {
    [_passwordField becomeFirstResponder];
}

- (void)useTouchID {
    LAContext *laContext = [[LAContext alloc] init];
    
    laContext.localizedFallbackTitle = NSLocalizedString(@"SECORE_CODE_TOUCHID_FALLBACK", nil);
    
    [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"SECORE_CODE_TOUCHID_MSG", nil) reply:^(BOOL success, NSError *error) {
        if (success) {
            [self dismissWithSuccess:YES];
        }
        else {
            if (!error) {
                [appDelegate displayMessage:NSLocalizedString(@"GLOBAL_ERROR", nil) content:NSLocalizedString(@"SECORE_CODE_TOUCHID_ERROR", nil) style:FLAlertViewStyleError time:@3 delay:@0];
            }
            [_codePinView animationBadPin];
        }
    }];
}

+ (BOOL)canUseTouchID {
    if ([[[UIDevice currentDevice] systemVersion] intValue] < 8)
        return NO;
    
    LAContext *laContext = [[LAContext alloc] init];
    
    NSError *error = nil;
    
    if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        if (!error)
            return YES;
        return NO;
    }
    return NO;
}

+ (void)useToucheID:(CompleteBlock)successBlock passcodeCallback:(CompleteBlock)passcodeBlock cancelCallback:(CompleteBlock)cancelBlock {
    LAContext *laContext = [[LAContext alloc] init];
    
    laContext.localizedFallbackTitle = NSLocalizedString(@"SECORE_CODE_TOUCHID_FALLBACK", nil);
    
    [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"SECORE_CODE_TOUCHID_MSG", nil) reply:^(BOOL success, NSError *error) {
        if (success) {
            successBlock();
            canTouchID = YES;
        }
        else {
            if (error.code == LAErrorUserFallback) {
                passcodeBlock();
                return;
            }
            if (error.code == LAErrorUserCancel) {
                cancelBlock();
                return ;
            } else if (!error) {
                [appDelegate displayMessage:NSLocalizedString(@"GLOBAL_ERROR", nil) content:NSLocalizedString(@"SECORE_CODE_TOUCHID_ERROR", nil) style:FLAlertViewStyleError time:@3 delay:@0];
                passcodeBlock();
            }
            else
                passcodeBlock();
            canTouchID = NO;
        }
    }];
}

#pragma mark - change Views

- (void)displayCorrectView {
    [self.view endEditing:YES];
    [self refreshText];
    [self clean];
    
    [backgroundImage setHidden:YES];
    [_textExplication setHidden:YES];
    
    [_codePinView setHidden:YES];
    [_padNumber setHidden:YES];
    [_forgotButton setHidden:YES];
    [_cleanButton setHidden:YES];
    
    [_usernameField setHidden:YES];
    [_passwordField setHidden:YES];
    [_passwordForgetButton setHidden:YES];
    [_nextButton setHidden:YES];
    [_touchIDButton setHidden:YES];
    
    [_secretAnswer setHidden:YES];
    [_secretExplication setHidden:YES];
    [_secretNextButton setHidden:YES];
    [_secretPassword setHidden:YES];
    [_secretPasswordConfirm setHidden:YES];
    [_secretQuestion setHidden:YES];
    [_secretForgotButton setHidden:YES];
    
    [_keyboardView setHidden:YES];
    
    if (currentSecureMode == SecureCodeModeNormal || currentSecureMode == SecureCodeModeChangeOld) {
        CGRectSetY(_textExplication.frame, 0);
        CGRectSetY(_codePinView.frame, CGRectGetMaxY(_textExplication.frame) - 5.0f);

        [backgroundImage setHidden:NO];
        [_textExplication setHidden:NO];
        [_codePinView setHidden:NO];
        [_padNumber setHidden:NO];
        [_forgotButton setHidden:NO];
        [_cleanButton setHidden:YES];
        if ([[self class] canUseTouchID] && canTouchID && !self.blockTouchID) {
            [_touchIDButton setHidden:NO];
        }
    }
    else if (currentSecureMode == SecureCodeModeForget) {
        [_usernameField setHidden:NO];
        [_passwordField setHidden:NO];
        [_passwordForgetButton setHidden:NO];
        [_nextButton setHidden:NO];
        
        [_passwordField becomeFirstResponder];
    }
    else if (currentSecureMode == SecureCodeModeChangePass) {
        [_usernameField setHidden:NO];
        [_usernameField seTsecureTextEntry:YES];
        [_usernameField.textfield setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"FIELD_NEW_PASSWORD", nil) attributes:@{NSForegroundColorAttributeName: [UIColor customPlaceholder]}]];
        
        [_passwordField setHidden:NO];
        [_passwordField.textfield setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"FIELD_PASSWORD_CONFIRMATION", nil) attributes:@{NSForegroundColorAttributeName: [UIColor customPlaceholder]}]];
        [_nextButton setHidden:NO];
        
        [_usernameField becomeFirstResponder];
    }
    else if (currentSecureMode == SecureCodeModeChangeNew || currentSecureMode == SecureCodeModeChangeConfirm) {
        
        CGRectSetY(_textExplication.frame, CGRectGetMinY(_keyboardView.frame) / 2 - 30);
        CGRectSetY(_codePinView.frame, CGRectGetMaxY(_textExplication.frame) - 5.0f);

        [_textExplication setHidden:NO];
        [_codePinView setHidden:NO];
        [_keyboardView setHidden:NO];
    }
    else if (currentSecureMode == SecureCodeModeSecret) {
        
        [_secretQuestion setText:_userSecretQuestion];
        [_secretQuestion setHeightToFit];
        
        CGRectSetY(_secretAnswer.frame, CGRectGetMaxY(_secretQuestion.frame) + 10);
        CGRectSetY(_secretPassword.frame, CGRectGetMaxY(_secretAnswer.frame) + 10);
        CGRectSetY(_secretPasswordConfirm.frame, CGRectGetMaxY(_secretPassword.frame) + 10);
        CGRectSetY(_secretNextButton.frame, CGRectGetMaxY(_secretPasswordConfirm.frame) + 10);
        CGRectSetY(_secretForgotButton.frame, CGRectGetMaxY(_secretNextButton.frame) + 10);
        
        [_secretAnswer setHidden:NO];
        [_secretExplication setHidden:NO];
        [_secretNextButton setHidden:NO];
        [_secretPassword setHidden:NO];
        [_secretPasswordConfirm setHidden:NO];
        [_secretQuestion setHidden:NO];
        [_secretForgotButton setHidden:NO];
    }
}

- (void)refreshText {
    if (currentSecureMode == SecureCodeModeNormal || currentSecureMode == SecureCodeModeChangeOld) {
        _textExplication.text = NSLocalizedString(@"SECORE_CODE_TEXT_CURRENT", nil);
    }
    else if (currentSecureMode == SecureCodeModeChangeNew) {
        _textExplication.text = NSLocalizedString(@"SECORE_CODE_TEXT_NEW", nil);
    }
    else if (currentSecureMode == SecureCodeModeChangeConfirm) {
        _textExplication.text = NSLocalizedString(@"SECORE_CODE_TEXT_CONFIRM", nil);
    }
    else if (currentSecureMode == SecureCodeModeChangePass) {
        _textExplication.text = NSLocalizedString(@"SECORE_CODE_TEXT_CHANGE_PASS", nil);
    }
    else if (currentSecureMode == SecureCodeModeForget) {
        _textExplication.text = NSLocalizedString(@"SECORE_CODE_TEXT_LOGIN", nil);
    }
}

#pragma mark - pinCodeDelegate

- (void)pinChange:(BOOL)pinStarts {
    [_cleanButton setHidden:!pinStarts];
    if ([[self class] canUseTouchID])
        [_touchIDButton setHidden:pinStarts];
}

- (void)pinEnd:(NSString *)pin {
    if (currentSecureMode == SecureCodeModeChangeNew) {
        tempNewSecureCode = pin;
        currentSecureMode = SecureCodeModeChangeConfirm;
        
        [self clean];
        [self displayCorrectView];
    }
    else {
        if (currentSecureMode == SecureCodeModeChangeConfirm) {
            if ([tempNewSecureCode isEqual:pin]) {
                [[Flooz sharedInstance] showLoadView];
                [[Flooz sharedInstance] updateUser:@{ @"secureCode": pin } success: ^(id result) {
                    [[Flooz sharedInstance] hideLoadView];
                    [[self class] setSecureCodeForCurrentUser:pin];
                    
                    if (isSignup) {
                        [appDelegate goToAccountViewController];
                    }
                    else {
                        [self dismissWithSuccess:YES];
                    }
                } failure:NULL];
            }
            else {
                currentSecureMode = SecureCodeModeChangeNew;
                [_codePinView animationBadPin];
                [self clean];
                [self displayCorrectView];
            }
        }
        else if (currentSecureMode == SecureCodeModeNormal || currentSecureMode == SecureCodeModeChangeOld) {
            NSString *currentSecureCode = [[self class] secureCodeForCurrentUser];
            
            if (currentSecureCode != nil && currentSecureCode.length == 4 && currentSecureMode == SecureCodeModeNormal) {
                if ([currentSecureCode isEqual:pin]) {
                    if (currentSecureMode == SecureCodeModeNormal)
                        [self dismissWithSuccess:YES];
                    else if (currentSecureMode == SecureCodeModeChangeOld) {
                        currentSecureMode = SecureCodeModeChangeNew;
                        [self clean];
                        [self displayCorrectView];
                    }
                }
                else
                {
                    [_codePinView animationBadPin];
                    [self clean];
                }
            }
            else {
                [[Flooz sharedInstance] showLoadView];
                [[Flooz sharedInstance] checkSecureCodeForUser:pin success:^(id result) {
                    [self.class setSecureCodeForCurrentUser:pin];
                    if (currentSecureMode == SecureCodeModeNormal)
                        [self dismissWithSuccess:YES];
                    else if (currentSecureMode == SecureCodeModeChangeOld) {
                        currentSecureMode = SecureCodeModeChangeNew;
                        [self clean];
                        [self displayCorrectView];
                    }
                } failure:^(NSError *error) {
                    [_codePinView animationBadPin];
                    [self clean];
                }];
            }
        }
    }
}

- (void)numberPressed:(NSInteger)number {
    currentValue = [currentValue stringByAppendingString:[NSString stringWithFormat:@"%d", (int)number]];
    [_codePinView setPin:currentValue];
}

- (void)clean {
    currentValue = @"";
    [_cleanButton setHidden:YES];
    //	[_cleanButton setEnabled:NO];
    [_codePinView clean];
}

- (void)didSecretForgetTouch {
    NSString *number;
    
    if ([Flooz sharedInstance].currentUser != nil)
        number = [Flooz sharedInstance].currentUser.phone;
    else
        number = _userDic[@"login"];

    [appDelegate displayMailWithMessage:[NSString stringWithFormat:NSLocalizedString(@"FORGOT_SECRET", @""), number] object:NSLocalizedString(@"FORGOT_OBJECT", nil) recipients:@[NSLocalizedString(@"FORGOT_RECIPIENTS", nil)] andMessageError:NSLocalizedString(@"ALERT_NO_MAIL_MESSAGE", nil) inViewController:self];
}

- (void)didCodeForgetTouch {
    [appDelegate displayMessage:@"Récupérer votre code" content:@"Veuillez vous identifier pour réinitialiser votre code à 4 chiffres." style:FLAlertViewStyleInfo time:@3 delay:@0];
    currentSecureMode = SecureCodeModeForget;
    [self displayCorrectView];
}

- (void)didPasswordForgetTouch {
    NSString *number;
    
    if ([Flooz sharedInstance].currentUser != nil)
        number = [Flooz sharedInstance].currentUser.email;
    else
        number = _userDic[@"login"];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] passwordForget:number success:^(NSDictionary *result){
//        if ([result[@"item"][@"type"] isEqualToString:@"password:secret"]) {
//            _userSecretQuestion = result[@"item"][@"question"];
//            currentSecureMode = SecureCodeModeSecret;
//            [self displayCorrectView];
//        } else {
//            [appDelegate displayMailWithMessage:[NSString stringWithFormat:NSLocalizedString(@"FORGOT_MESSAGE", @""), number] object:NSLocalizedString(@"FORGOT_OBJECT", nil) recipients:@[NSLocalizedString(@"FORGOT_RECIPIENTS", nil)] andMessageError:NSLocalizedString(@"ALERT_NO_MAIL_MESSAGE", nil) inViewController:self];
//        }
    } failure:^(NSError *error) {
//        [appDelegate displayMailWithMessage:[NSString stringWithFormat:NSLocalizedString(@"FORGOT_MESSAGE", @""), number] object:NSLocalizedString(@"FORGOT_OBJECT", nil) recipients:@[NSLocalizedString(@"FORGOT_RECIPIENTS", nil)] andMessageError:NSLocalizedString(@"ALERT_NO_MAIL_MESSAGE", nil) inViewController:self];
    }];
}

- (BOOL)checkNextOk {
//    if (currentSecureMode == SecureCodeModeSecret) {
//        if (!_userDic[@"secretAnswer"] || [_userDic[@"secretAnswer"] isBlank]) {
//            [_secretNextButton setEnabled:NO];
//            return NO;
//        }
//        if (!_userDic[@"newPassword"] || [_userDic[@"newPassword"] isBlank]) {
//            [_secretNextButton setEnabled:NO];
//            return NO;
//        }
//        if (!_userDic[@"confirm"] || [_userDic[@"confirm"] isBlank]) {
//            [_secretNextButton setEnabled:NO];
//            return NO;
//        }
//        
//        [_secretNextButton setEnabled:YES];
//        return YES;
//    } else {
//        if (!_userDic[@"login"] || [_userDic[@"login"] isBlank]) {
//            [_usernameField becomeFirstResponder];
//            [_nextButton setEnabled:NO];
//            return NO;
//        }
//        if (!_userDic[@"password"] || [_userDic[@"password"] length] < 1) {
//            [_passwordField becomeFirstResponder];
//            [_nextButton setEnabled:NO];
//            return NO;
//        }
//        
//        if (currentSecureMode == SecureCodeModeChangePass && ![_userDic[@"login"] isEqualToString:_userDic[@"password"]]) {
//            [_nextButton setEnabled:NO];
//            return NO;
//        }
//        
//        [_nextButton setEnabled:YES];
//        return YES;
//    }
    return YES;
}

- (void)login {
    if ([self checkNextOk]) {
        if (currentSecureMode == SecureCodeModeChangePass) {
            [[Flooz sharedInstance] showLoadView];
            
            [[Flooz sharedInstance] updatePassword:@{@"phone" : _userDic[@"phone"], @"newPassword": _userDic[@"login"], @"confirm" : _userDic[@"password"] } success:^(id result) {
                [[Flooz sharedInstance] showLoadView];
                [[Flooz sharedInstance] loginWithPseudoAndPassword:@{@"login": _userDic[@"phone"], @"password": _userDic[@"login"]} success: ^(id result) {
                    if ([_userDic[@"secureCode"] boolValue])
                        [appDelegate goToAccountViewController];
                    else {
                        currentSecureMode = SecureCodeModeChangeNew;
                        [self displayCorrectView];
                    }
                }];
            } failure:nil];
        }
        else if (currentSecureMode == SecureCodeModeSecret) {
            [[Flooz sharedInstance] showLoadView];
            
            NSString *number;
            if ([Flooz sharedInstance].currentUser != nil)
                number = [Flooz sharedInstance].currentUser.phone;
            else
                number = _userDic[@"login"];

            [[Flooz sharedInstance] updatePassword:@{@"phone" : number, @"newPassword": _userDic[@"newPassword"], @"confirm" : _userDic[@"confirm"], @"secretAnswer" : _userDic[@"secretAnswer"] } success:^(id result) {
                if (isSignup) {
                    currentSecureMode = SecureCodeModeForget;
                    [self displayCorrectView];
                } else {
                    currentSecureMode = SecureCodeModeChangeNew;
                    [self displayCorrectView];
                }
            } failure:nil];
        }
        else if (isSignup) {
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] loginWithPseudoAndPassword:_userDic success: ^(id result) {
                if ([_userDic[@"hasSecureCode"] boolValue])
                    [appDelegate goToAccountViewController];
                else {
                    currentSecureMode = SecureCodeModeChangeNew;
                    [self displayCorrectView];
                }
            }];
        }
        else {
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] loginForSecureCode:_userDic success: ^(id result) {
                currentSecureMode = SecureCodeModeChangeNew;
                [self displayCorrectView];
            } failure:nil];
        }
    }
}

#pragma mark - SecureCode

+ (NSString *)keyForSecureCode {
    return [NSString stringWithFormat:@"secureCode-%@", [[[Flooz sharedInstance] currentUser] userId]];
}

+ (NSString *)secureCodeForCurrentUser {
    return [UICKeyChainStore stringForKey:[self keyForSecureCode]];
}

+ (void)setSecureCodeForCurrentUser:(NSString *)secureCode {
    [UICKeyChainStore setString:secureCode forKey:[self keyForSecureCode]];
}

+ (BOOL)hasSecureCodeForCurrentUser {
    return [self secureCodeForCurrentUser] != nil;
}

+ (void)clearSecureCode {
    [UICKeyChainStore removeItemForKey:[self keyForSecureCode]];
}

#pragma mark -helpers
- (CGSize)sizeExpectedForView:(UIView *)view {
    CGSize expectedSize;
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        expectedSize = [label.text sizeWithAttributes:@{ NSFontAttributeName: label.font }];
    }
    else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        expectedSize = [button.titleLabel.text sizeWithAttributes:@{ NSFontAttributeName: button.titleLabel.font }];
    }
    return expectedSize;
}

- (void)dismissBack {
    [self dismissWithSuccess:NO];
}

- (void)dismissWithSuccess:(BOOL)success {
    CompleteBlock completion = nil;
    if (success) {
        completion = _completeBlock;
    }
    if ([self navigationController]) {
        if ([[[self navigationController] viewControllers] count] == 1) {
            [[self navigationController] dismissViewControllerAnimated:YES completion:completion];
        }
        else {
            [[self navigationController] popViewControllerAnimated:YES];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            
            if (completion) {
                completion();
            }
        }
    }
    else {
        [self dismissViewControllerAnimated:YES completion:completion];
    }
}

@end
