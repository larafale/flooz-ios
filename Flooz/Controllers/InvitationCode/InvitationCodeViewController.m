//
//  InvitationCodeViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-08-21.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "InvitationCodeViewController.h"

@interface InvitationCodeViewController () {
    UIView *_mainBody;
    
    FLTextFieldIcon *_codeField;
    
    NSMutableDictionary *dicCode;
    UILabel *textExplication;
}

@end

@implementation InvitationCodeViewController

- (id)initWithUser:(NSDictionary *)_user
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"CODE_INVITATION_TITLE", nil);
        if(_user){
            dicCode = [_user mutableCopy];
        }
        else {
            dicCode = [NSMutableDictionary new];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackground];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(checkInvitationCode)];
    
    float heightForMain =  PPScreenHeight() - STATUSBAR_HEIGHT - NAVBAR_HEIGHT - 250;
    NSLog(@"Main begin %f", heightForMain);
    _mainBody = [UIView newWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight() - STATUSBAR_HEIGHT - NAVBAR_HEIGHT - 216)];
    [self.view addSubview:_mainBody];
    
    _codeField = [[FLTextFieldIcon alloc] initWithIcon:@"" placeholder:@"CODE_INVITATION_TITLE" for:dicCode key:@"invitationCode" position:CGPointMake(0.0f, CGRectGetHeight(_mainBody.frame) / 2 - 45)];
    
    [_codeField addForNextClickTarget:self action:@selector(checkInvitationCode)];
    
    [_mainBody addSubview:_codeField];
    
    textExplication = [[UILabel alloc] initWithFrame:CGRectMake(14, CGRectGetMaxY(_codeField.frame) + 10, PPScreenWidth()-28, 50)];
    textExplication.textColor = [UIColor customPlaceholder];
    textExplication.font = [UIFont customTitleExtraLight:14];
    textExplication.numberOfLines = 0;
    textExplication.textAlignment = NSTextAlignmentCenter;
    textExplication.text = NSLocalizedString(@"CODE_INVITATION_EXPLICATION", nil);
    
    [_mainBody addSubview:textExplication];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_codeField becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myNotificationMethod:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)myNotificationMethod:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    float height = CGRectGetHeight(keyboardFrameBeginRect);
    float heightForMain = PPScreenHeight() - STATUSBAR_HEIGHT - NAVBAR_HEIGHT - height;
    CGRectSetHeight(_mainBody.frame, heightForMain);
    CGRectSetY(_codeField.frame, CGRectGetHeight(_mainBody.frame) / 2 - 45);
    CGRectSetY(textExplication.frame, CGRectGetMaxY(_codeField.frame) + 10);
}

- (void) checkInvitationCode {
    if (dicCode[@"invitationCode"] && ![dicCode[@"invitationCode"] isBlank]) {
        [[Flooz sharedInstance] verifyInvitationCode:dicCode[@"invitationCode"] success:^(id result) {
            [self dismissViewControllerAnimated:YES completion:^{}];
            [appDelegate showSignupWithUser:dicCode];
        } failure:^(NSError *error) {
            [_codeField becomeFirstResponder];
        }];
    }
}

@end
