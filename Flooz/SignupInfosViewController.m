//
//  SignupInfosViewController.m
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "WebViewController.h"
#import "SignupInfosViewController.h"
#import "SignupSecureCodeViewController.h"

@interface SignupInfosViewController () {
    UIScrollView *_contentView;
    UIView *_contentViewInfo;
    
    FLTextFieldSignup *_firstname;
    FLTextFieldSignup *_lastname;
    FLTextFieldSignup *_email;
    FLTextFieldSignup *_birthday;
    FLTextFieldSignup *_password;
    
    FLActionButton *_nextButton;
    
    FLKeyboardView *inputView;
}

@end

@implementation SignupInfosViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Info", @"");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    {
        _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
        [_mainBody addSubview:_contentView];
    }
    
    _contentViewInfo = [UIView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    [_contentView addSubview:_contentViewInfo];
    
    
    {
        _lastname = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_LASTNAME" for:self.userDic key:@"lastName" position:CGPointMake(SIGNUP_PADDING_SIDE, 0.0f)];
        [_lastname addForNextClickTarget:self action:@selector(focusOnNextInfo)];
        [_contentViewInfo addSubview:_lastname];
    }
    
    {
        _firstname = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_FIRSTNAME" for:self.userDic key:@"firstName" position:CGPointMake(SIGNUP_PADDING_SIDE, CGRectGetMaxY(_lastname.frame) + 3.0f / self.ratioiPhones)];
        [_firstname addForNextClickTarget:self action:@selector(focusOnNextInfo)];
        [_contentViewInfo addSubview:_firstname];
    }
    
    {
        _email = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_EMAIL" for:self.userDic key:@"email" position:CGPointMake(SIGNUP_PADDING_SIDE, CGRectGetMaxY(_firstname.frame) + 3.0f / self.self.ratioiPhones)];
        [_email addForNextClickTarget:self action:@selector(focusOnNextInfo)];
        [_contentViewInfo addSubview:_email];
    }
    {
        _birthday = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_BIRTHDAY" for:self.userDic key:@"birthdate" position:CGPointMake(SIGNUP_PADDING_SIDE, CGRectGetMaxY(_email.frame) + 3.0f / self.ratioiPhones)];
        [_birthday addForNextClickTarget:self action:@selector(focusOnNextInfo)];
        [_contentViewInfo addSubview:_birthday];
        
        inputView = [FLKeyboardView new];
        inputView.textField = _birthday.textfield;
        _birthday.textfield.inputView = inputView;
    }
    {
        _password = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_PASSWORD" for:self.userDic key:@"password" position:CGPointMake(SIGNUP_PADDING_SIDE, CGRectGetMaxY(_birthday.frame) + 3.0f / self.ratioiPhones)];
        [_password seTsecureTextEntry:YES];
        [_password addForNextClickTarget:self action:@selector(focusOnNextInfo)];
        [_contentViewInfo addSubview:_password];
    }
    
    {
        TTTAttributedLabel *tttLabel = [TTTAttributedLabel newWithFrame:CGRectMake(10, CGRectGetHeight(_contentView.frame) - 45.0f, PPScreenWidth() - 20, 45)];
        {
            NSString *labelText = NSLocalizedString(@"SIGNUP_READ_CGU", @"");
            [tttLabel setNumberOfLines:0];
            [tttLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [tttLabel setTextAlignment:NSTextAlignmentCenter];
            [tttLabel setTextColor:[UIColor customPlaceholder]];
            [tttLabel setFont:[UIFont customTitleExtraLight:13]];
            NSRange CGURange = [labelText rangeOfString:@"conditions générales d'utilisation"];
            [tttLabel setText:labelText afterInheritingLabelAttributesAndConfiguringWithBlock: ^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                if (CGURange.location != NSNotFound) {
                    [mutableAttributedString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:(id)@1 range:CGURange];
                }
                return mutableAttributedString;
            }];
            [tttLabel sizeToFit];
            [tttLabel setLinkAttributes:@{ NSForegroundColorAttributeName : [UIColor customPlaceholder] }];
            [tttLabel addLinkToURL:[NSURL URLWithString:@"action://show-CGU"] withRange:CGURange];
            [tttLabel setDelegate:self];
            [_contentView addSubview:tttLabel];
            
            _contentView.contentSize = CGSizeMake(CGRectGetWidth(_mainBody.frame), CGRectGetMaxY(tttLabel.frame));
        }
    }
    
    {
        _nextButton = [[FLActionButton alloc] initWithFrame:CGRectMake(SIGNUP_PADDING_SIDE, 0, PPScreenWidth() - SIGNUP_PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"SIGNUP_NEXT_BUTTON", nil)];
        [_nextButton setEnabled:YES];
        [_nextButton addTarget:self action:@selector(checkEmail) forControlEvents:UIControlEventTouchUpInside];
        CGRectSetY(_nextButton.frame, CGRectGetMaxY(_password.frame) + 15.0f);
        [_contentViewInfo addSubview:_nextButton];
    }
    
    [self addTapGestureForDismissKeyboard];
}

- (void)focusOnNextInfo {
    if ([_lastname isFirstResponder]) {
        [_lastname resignFirstResponder];
        [_firstname becomeFirstResponder];
    }
    else if ([_firstname isFirstResponder]) {
        [_firstname resignFirstResponder];
        [_email becomeFirstResponder];
    }
    else if ([_email isFirstResponder]) {
        [_email resignFirstResponder];
        [_birthday becomeFirstResponder];
    }
    else if ([_birthday isFirstResponder]) {
        [_birthday resignFirstResponder];
        [_password becomeFirstResponder];
    }
    else if ([_password isFirstResponder]) {
        [_password resignFirstResponder];
    }
    else {
        [self checkEmail];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([[url scheme] hasPrefix:@"action"]) {
        if ([[url host] hasPrefix:@"show-CGU"]) {
            [self displayCGU];
        }
    }
}

- (void)displayCGU {
    WebViewController *controller = [WebViewController new];
    controller.showCross = YES;
    [controller setUrl:@"https://www.flooz.me/cgu?layout=webview"];
    controller.title = NSLocalizedString(@"INFORMATIONS_TERMS", nil);
    UINavigationController *controller2 = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:controller2 animated:YES completion:NULL];
}

- (void)displayChanges {
    [_lastname reloadTextField];
    [_firstname reloadTextField];
    [_email reloadTextField];
    [_birthday reloadTextField];
    [_password reloadTextField];
    
    [self.userDic removeObjectForKey:@"secureCode"];
}

- (void)checkEmail {
    if (!self.userDic[@"lastName"] || [self.userDic[@"lastName"] isBlank]) {
        [_lastname becomeFirstResponder];
        return;
    }
    if (!self.userDic[@"firstName"] || [self.userDic[@"firstName"] isBlank]) {
        [_firstname becomeFirstResponder];
        return;
    }
    if (!self.userDic[@"email"] || [self.userDic[@"email"] isBlank]) {
        [_email becomeFirstResponder];
        return;
    }
    if (!self.userDic[@"birthdate"] || !([self.userDic[@"birthdate"] length] == 12 || [self.userDic[@"birthdate"] length] == 14)) {
        [_birthday becomeFirstResponder];
        return;
    }
    if (!self.userDic[@"password"] || [self.userDic[@"password"] isBlank]) {
        [_password becomeFirstResponder];
        return;
    }
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] checkSignup:self.userDic success: ^(id result) {
        [self.navigationController pushViewController:[[SignupSecureCodeViewController alloc] initWithMode:SecureCodeModeChangeNew] animated:YES];
    } failure: ^(NSError *error) {
        [_lastname becomeFirstResponder];
    }];
}

- (void)addTapGestureForDismissKeyboard {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [_mainBody addGestureRecognizer:tapGesture];
    [_contentView addGestureRecognizer:tapGesture];
    [_headerView addGestureRecognizer:tapGesture];
    [_contentViewInfo addGestureRecognizer:tapGesture];
    [self registerForKeyboardNotifications];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight + 30, 0);
}

- (void)keyboardWillDisappear {
    _contentView.contentInset = UIEdgeInsetsZero;
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

@end
