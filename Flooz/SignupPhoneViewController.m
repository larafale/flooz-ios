//
//  SignupPhoneViewController.m
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLActionButton.h"
#import "FLKeyboardView.h"
#import "SignupPhoneViewController.h"

@interface SignupPhoneViewController () {
    FLTextFieldSignup *_phoneField;
    FLKeyboardView *_inputView;
    
    FLActionButton *_nextButton;
}

@end

@implementation SignupPhoneViewController


- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Phone", @"");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _phoneField = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"NumMobile", @"") for:self.userDic key:@"phone" position:CGPointMake(SIGNUP_PADDING_SIDE, self.firstItemY + 20.0f)];
    CGRectSetX(_phoneField.frame, (SCREEN_WIDTH - _phoneField.frame.size.width) / 2);
    [_phoneField addForTextChangeTarget:self action:@selector(testPhoneNumber)];
    [_phoneField addForNextClickTarget:self action:@selector(testPhoneNumber)];
    [_mainBody addSubview:_phoneField];
    
    _inputView = [FLKeyboardView new];
    [_inputView noneCloseButton];
    _inputView.textField = _phoneField.textfield;
    _phoneField.textfield.inputView = _inputView;
    
    _nextButton = [[FLActionButton alloc] initWithFrame:CGRectMake(SIGNUP_PADDING_SIDE, 0, PPScreenWidth() - SIGNUP_PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"SIGNUP_NEXT_BUTTON", nil)];
    [_nextButton setEnabled:NO];
    [_nextButton addTarget:self action:@selector(tryPhoneNumber) forControlEvents:UIControlEventTouchUpInside];
    CGRectSetY(_nextButton.frame, CGRectGetMaxY(_phoneField.frame) + 10.0f);
    [_mainBody addSubview:_nextButton];
    
    self.userDic = [NSMutableDictionary new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_phoneField becomeFirstResponder];
}

- (void)backToStartView {
    
}

- (void)displayChanges {
    [_phoneField setDictionary:self.userDic andKey:@"phone"];
}

- (void)testPhoneNumber {
    int lenght = 0;
    
    if (self.userDic[@"phone"] && ![self.userDic[@"phone"] isBlank] && ((NSString *)self.userDic[@"phone"]).length > 0)
        lenght = ((NSString *)self.userDic[@"phone"]).UTF8String[0] == '0' ? 10 : 12;
    
    if (self.userDic[@"phone"] && ![self.userDic[@"phone"] isBlank] && ((NSString *)self.userDic[@"phone"]).length >= lenght) {
        [_nextButton setEnabled:YES];
    }
    else {
        [_phoneField.textfield becomeFirstResponder];
        [_nextButton setEnabled:NO];
    }
}

- (void)tryPhoneNumber {
    [self.view endEditing:YES];
    int lenght = ((NSString *)self.userDic[@"phone"]).UTF8String[0] == '0' ? 10 : 12;

    if (self.userDic[@"phone"] && ![self.userDic[@"phone"] isBlank] && ((NSString *)self.userDic[@"phone"]).length >= lenght) {
        [_nextButton setEnabled:YES];
        
        [[Flooz sharedInstance] showLoadView];
        [appDelegate clearSavedViewController];
        [[Flooz sharedInstance] loginWithPhone:self.userDic[@"phone"]];
    }
    else {
        [_phoneField.textfield becomeFirstResponder];
        [_nextButton setEnabled:NO];
    }
}

- (void)dismissViewController {
    [super dismissViewController];
    
    [appDelegate displayHome];
}

@end
