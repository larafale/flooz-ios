//
//  SignupSMSViewController.m
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SignupUsernameViewController.h"
#import "SignupSMSViewController.h"

@interface SignupSMSViewController () {
    FLTextFieldSignup *_codeField;
    FLKeyboardView *_inputView;
    
    FLActionButton *_nextButton;
}

@end


@implementation SignupSMSViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"SIGNUP_PAGE_TITLE_SMS", @"");
        self.userDic = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _codeField = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_SMS_CODE", @"") for:self.userDic key:@"smscode" position:CGPointMake(SIGNUP_PADDING_SIDE, CGRectGetMaxY(_headerView.frame) + 5)];
    CGRectSetX(_codeField.frame, (SCREEN_WIDTH - _codeField.frame.size.width) / 2.);
    _codeField.textfield.textAlignment = NSTextAlignmentCenter;

    [_codeField addForTextChangeTarget:self action:@selector(codeChange)];
    [_mainBody addSubview:_codeField];
    
    _inputView = [FLKeyboardView new];
    [_inputView noneCloseButton];
    _inputView.textField = _codeField.textfield;
    _codeField.textfield.inputView = _inputView;
    
    _nextButton = [[FLActionButton alloc] initWithFrame:CGRectMake(SIGNUP_PADDING_SIDE, 0, PPScreenWidth() - SIGNUP_PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"GLOBAL_VALIDATE", nil)];
    [_nextButton setEnabled:NO];
    [_nextButton addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    CGRectSetY(_nextButton.frame, CGRectGetMaxY(_codeField.frame) + 10.0f);
    [_mainBody addSubview:_nextButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_codeField becomeFirstResponder];
}

- (void)codeChange {
    if (self.userDic[@"smscode"] && ![self.userDic[@"smscode"] isBlank] && ((NSString *)self.userDic[@"smscode"]).length == 4) {
        [_nextButton setEnabled:YES];
    } else {
        [_nextButton setEnabled:NO];
    }
}

- (void)displayChanges {
    [_codeField reloadTextField];
}

- (void)nextStep {
    NSMutableDictionary *dic = [self.userDic mutableCopy];
    if (dic[@"birthdate"])
        [dic setObject:[[Flooz sharedInstance] formatBirthDate:self.userDic[@"birthdate"]] forKey:@"birthdate"];
    if (self.userDic[@"picId"]) {
        [dic setValue:@YES forKey:@"hasImage"];
    }
    else {
        [dic setValue:@NO forKey:@"hasImage"];
    }
    [dic removeObjectForKey:@"picId"];

    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] signupPassStep:@"sms" user:dic success:^(id result) {
        [self.navigationController pushViewController:[SignupUsernameViewController new] animated:YES];
    } failure:^(NSError *error) {
        
    }];
}

@end
