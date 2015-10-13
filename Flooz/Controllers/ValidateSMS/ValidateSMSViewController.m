//
//  ValidateSMSViewController.m
//  Flooz
//
//  Created by Epitech on 10/12/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "ValidateSMSViewController.h"

#define FULL_COUNTDOWN 60

@interface ValidateSMSViewController () {
    NSMutableDictionary *smsData;
    FLTextFieldSignup *_codeField;
    FLKeyboardView *_inputView;
    
    FLActionButton *_nextButton;
    
    NSTimer *_timer;
    NSTimer *_ktimer;
    NSInteger _countDown;
    
    BOOL resetSMS;
    
    CGFloat ratioiPhones;
    CGFloat firstItemY;
}

@end

@implementation ValidateSMSViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"SIGNUP_PAGE_TITLE_SMS", @"");
        resetSMS = YES;
        smsData = [NSMutableDictionary new];
        
        ratioiPhones = 1.0f;
        
        if (PPScreenHeight() < 568) {
            ratioiPhones = 1.2f;
        }
        
        firstItemY = 25.0f / ratioiPhones;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    ((FLNavigationController*)self.navigationController).blockBack = YES;

    _codeField = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_SMS_CODE", @"") for:smsData key:@"smscode" position:CGPointMake(SIGNUP_PADDING_SIDE, firstItemY + 20.0f)];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (resetSMS) {
        [[Flooz sharedInstance] sendSignupSMS:[Flooz sharedInstance].currentUser.phone];
        resetSMS = NO;
    }
    
    [_codeField becomeFirstResponder];
    
    if (!_timer)
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reloadTimerView:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_codeField resignFirstResponder];
}

- (void)reloadTimerView:(NSTimer*)timer {
    if (_countDown > 0)
        --_countDown;
    
    NSString *countDownValue;
    if (_countDown > 0)
        countDownValue = [NSString stringWithFormat:@"%lu", (unsigned long)_countDown];
    else
        countDownValue = @"";
    
    if (!smsData[@"smscode"] || [smsData[@"smscode"] isBlank]) {
        [_nextButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"SMS_REFRESH_CODE", nil), countDownValue] forState:UIControlStateNormal];
        if (_countDown == 0)
            [_nextButton setEnabled:YES];
        else
            [_nextButton setEnabled:NO];
    } else {
        [_nextButton setTitle:NSLocalizedString(@"GLOBAL_VALIDATE", nil) forState:UIControlStateNormal];
        [_nextButton setEnabled:YES];
    }
}

- (void)codeChange {
    if (smsData[@"smscode"] && ![smsData[@"smscode"] isBlank]) {
        [_nextButton setTitle:NSLocalizedString(@"GLOBAL_VALIDATE", nil) forState:UIControlStateNormal];
        [_nextButton setEnabled:YES];
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
    if (smsData[@"smscode"] && ![smsData[@"smscode"] isBlank]) {
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] checkPhoneForUser:smsData[@"smscode"] success:^(id result) {
            [self dismissViewController];
        } failure:nil];
    } else {
        [[Flooz sharedInstance] sendSignupSMS:[Flooz sharedInstance].currentUser.phone];
        _countDown = FULL_COUNTDOWN;
        NSString *countDownValue = [NSString stringWithFormat:@"%lu", (unsigned long)_countDown];
        [_nextButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"SMS_REFRESH_CODE", nil), countDownValue] forState:UIControlStateNormal];
        [_nextButton setEnabled:NO];
    }
}

@end
