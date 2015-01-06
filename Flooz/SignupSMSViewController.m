//
//  SignupSMSViewController.m
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SignupUsernameViewController.h"
#import "SignupSMSViewController.h"

#define FULL_COUNTDOWN 60

@interface SignupSMSViewController () {
    FLTextFieldSignup *_codeField;
    FLKeyboardView *_inputView;
    
    FLActionButton *_nextButton;
    
    NSTimer *_timer;
    NSInteger _countDown;
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
    
    _codeField = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_SMS_CODE", @"") for:self.userDic key:@"smscode" position:CGPointMake(SIGNUP_PADDING_SIDE, self.firstItemY + 20.0f)];
    CGRectSetX(_codeField.frame, (SCREEN_WIDTH - _codeField.frame.size.width) / 2.);
    _codeField.textfield.textAlignment = NSTextAlignmentCenter;
    
    [_codeField addForTextChangeTarget:self action:@selector(codeChange)];
    [_mainBody addSubview:_codeField];
    
    _inputView = [FLKeyboardView new];
    [_inputView noneCloseButton];
    _inputView.textField = _codeField.textfield;
    _codeField.textfield.inputView = _inputView;
    
    _countDown = FULL_COUNTDOWN;
    NSString *countDownValue = [NSString stringWithFormat:@"%lu", (unsigned long)_countDown];
    
    _nextButton = [[FLActionButton alloc] initWithFrame:CGRectMake(SIGNUP_PADDING_SIDE, 0, PPScreenWidth() - SIGNUP_PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:[NSString stringWithFormat:NSLocalizedString(@"SMS_REFRESH_CODE", nil), countDownValue]];
    [_nextButton setEnabled:NO];
    [_nextButton addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    CGRectSetY(_nextButton.frame, CGRectGetMaxY(_codeField.frame) + 10.0f);
    [_mainBody addSubview:_nextButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_codeField becomeFirstResponder];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reloadTimerView:) userInfo:nil repeats:YES];
}

- (void)reloadTimerView:(NSTimer*)timer {
    if (_countDown > 0)
        --_countDown;
    
    NSString *countDownValue;
    if (_countDown > 0)
        countDownValue = [NSString stringWithFormat:@"%lu", (unsigned long)_countDown];
    else
        countDownValue = @"";
    
    if (!self.userDic[@"smscode"] || [self.userDic[@"smscode"] isBlank]) {
        [_nextButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"SMS_REFRESH_CODE", nil), countDownValue] forState:UIControlStateNormal];
        if (_countDown == 0)
            [_nextButton setEnabled:YES];
        else
            [_nextButton setEnabled:NO];
    } else {
        [_nextButton setTitle:NSLocalizedString(@"GLOBAL_VALIDATE", nil) forState:UIControlStateNormal];
        
        if (((NSString *)self.userDic[@"smscode"]).length == 4) {
            [_nextButton setEnabled:YES];
        }
    }
}

- (void)codeChange {
    if (self.userDic[@"smscode"] && ![self.userDic[@"smscode"] isBlank] && ((NSString *)self.userDic[@"smscode"]).length == 4) {
        [_nextButton setTitle:NSLocalizedString(@"GLOBAL_VALIDATE", nil) forState:UIControlStateNormal];
        [_nextButton setEnabled:YES];
    } else if (self.userDic[@"smscode"] && ![self.userDic[@"smscode"] isBlank]) {
        [_nextButton setTitle:NSLocalizedString(@"GLOBAL_VALIDATE", nil) forState:UIControlStateNormal];
        [_nextButton setEnabled:NO];
    } else {
        NSString *countDownValue;
        if (_countDown > 0)
            countDownValue = [NSString stringWithFormat:@"%lu", (unsigned long)_countDown];
        else
            countDownValue = @"";
        
        [_nextButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"SMS_REFRESH_CODE", nil), countDownValue] forState:UIControlStateNormal];

        if (_countDown == 0)
            [_nextButton setEnabled:YES];
        else
            [_nextButton setEnabled:NO];
    }
}

- (void)displayChanges {
    [_codeField reloadTextField];
}

- (void)nextStep {
    if (self.userDic[@"smscode"] && ![self.userDic[@"smscode"] isBlank] && ((NSString *)self.userDic[@"smscode"]).length == 4) {
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
            [_timer invalidate];
            _timer = nil;
            [self.navigationController pushViewController:[SignupUsernameViewController new] animated:YES];
        } failure:^(NSError *error) {
            
        }];
    } else {
        [[Flooz sharedInstance] sendSignupSMS:self.userDic[@"phone"]];
        _countDown = FULL_COUNTDOWN;
        NSString *countDownValue = [NSString stringWithFormat:@"%lu", (unsigned long)_countDown];
        [_nextButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"SMS_REFRESH_CODE", nil), countDownValue] forState:UIControlStateNormal];
        [_nextButton setEnabled:NO];
    }
}

@end
