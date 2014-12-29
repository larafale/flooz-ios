//
//  InviteViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-16.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "InviteViewController.h"
#import "FLPopupAskInviteCode.h"
#import "FLPopupEnterInviteCode.h"
#import "PendingInvitationViewController.h"

@interface InviteViewController () {
    NSMutableDictionary *_userDic;
    
    FLTextFieldSignup *_codeTextfield;
    
    UILabel *_textExplication;
    
    UIButton *_validCode;
}

@end

@implementation InviteViewController

- (id)initWithUser:(NSDictionary *)user {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (user) {
            _userDic = [user mutableCopy];
            self.showBack = YES;
            self.title = NSLocalizedString(@"CODE_INVITATION_TITLE", nil);
        }
        else {
            _userDic = [NSMutableDictionary new];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - prepare Views

- (void)prepareViews {
    CGFloat padding = 15.0f;
    CGFloat height = padding;
    
    _textExplication = [[UILabel alloc] initWithFrame:CGRectMake(padding, height, PPScreenWidth() - padding * 2.0f, 200)];
    _textExplication.textColor = [UIColor customGrey];
    _textExplication.font = [UIFont customTitleExtraLight:18];
    if (IS_IPHONE4) {
        _textExplication.font = [UIFont customTitleExtraLight:17];
    }
    _textExplication.textAlignment = NSTextAlignmentCenter;
    _textExplication.numberOfLines = 0;
    _textExplication.text = NSLocalizedString(@"INVITATION_CODE_EXPLICATION", nil);
    [_textExplication heightToFit];
    CGRectSetY(_textExplication.frame, height);
    [_mainBody addSubview:_textExplication];
    
    height = CGRectGetHeight(_mainBody.frame) - padding * 3 - 35 * 2;
    
    _codeTextfield = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"INVITATION_CODE_PLACEHOLDER", @"") for:_userDic key:@"coupon" position:CGPointMake(padding * 2, height)];
    CGRectSetWidth(_codeTextfield.frame, CGRectGetWidth(_mainBody.frame) - (4 * padding));
    [_codeTextfield addForNextClickTarget:self action:@selector(validCode)];
    [_codeTextfield addForTextChangeTarget:self action:@selector(canValidate)];
    [_mainBody addSubview:_codeTextfield];
    
    height += CGRectGetHeight(_codeTextfield.frame) + padding;
    
    _validCode = [[UIButton alloc] initWithFrame:CGRectMake(padding * 2, height, CGRectGetWidth(_mainBody.frame) - (4 * padding), 35)];
    
    [_validCode setTitle:NSLocalizedString(@"SIGNUP_NEXT_BUTTON", nil) forState:UIControlStateNormal];
    [_validCode setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_validCode setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
    [_validCode setTitleColor:[UIColor customPlaceholder] forState:UIControlStateHighlighted];
    
    [_validCode setEnabled:NO];
    [_validCode setBackgroundColor:[UIColor customBackground]];
    [_validCode addTarget:self action:@selector(validCode) forControlEvents:UIControlEventTouchUpInside];
    [_mainBody addSubview:_validCode];    
}

- (void)validCode {
    [_codeTextfield resignFirstResponder];
    
    if (_userDic[@"coupon"] && ![_userDic[@"coupon"] isBlank]) {
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] verifyInvitationCode:_userDic success:nil failure:nil];
    }
}

- (void)canValidate {
    if (_userDic[@"coupon"] && ![_userDic[@"coupon"] isBlank]) {
        [_validCode setEnabled:YES];
        [_validCode setBackgroundColor:[UIColor customBlue]];
    } else {
        [_validCode setEnabled:NO];
        [_validCode setBackgroundColor:[UIColor customBackground]];
    }
}

- (void)showAskPopup {
    if (_userDic[@"pendingInvitation"] && [_userDic[@"pendingInvitation"] boolValue]) {
        [self.navigationController pushViewController:[PendingInvitationViewController new] animated:YES];
    }
    else {
        [[[FLPopupAskInviteCode alloc] initWithUser:_userDic andCompletionBlock:^{
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] askInvitationCode:_userDic success:^(id result) {
                _userDic[@"pendingInvitation"] = @YES;
                [self showAskPopup];
            } failure:nil];
        }] show];
    }
}

@end
