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
    
    FLActionButton *_validCode;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_codeTextfield becomeFirstResponder];
}

#pragma mark - prepare Views

- (void)prepareViews {
    CGFloat padding = 15.0f;
    CGFloat height = padding;
    
    if (!IS_IPHONE4) {
        UIImageView *logo = [UIImageView imageNamed:@"white-logo"];
        logo.image = [logo.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [logo setTintColor:[UIColor customBlue]];
        [logo setContentMode:UIViewContentModeScaleAspectFit];
        CGRectSetHeight(logo.frame, 60);
        CGRectSetX(logo.frame, CGRectGetWidth(_mainBody.frame) / 2 - CGRectGetWidth(logo.frame) / 2);
        CGRectSetY(logo.frame, height);
        [_mainBody addSubview:logo];
        
        height += CGRectGetHeight(logo.frame) + padding;
    }
    
    _textExplication = [[UILabel alloc] initWithFrame:CGRectMake(padding, height, PPScreenWidth() - padding * 2.0f, 45)];
    _textExplication.textColor = [UIColor customWhite];
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
    
    height += CGRectGetHeight(_textExplication.frame) + padding * 2;
    
    _codeTextfield = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"INVITATION_CODE_PLACEHOLDER", @"") for:_userDic key:@"coupon" position:CGPointMake(padding * 2, height)];
    _codeTextfield.textfield.textAlignment = NSTextAlignmentCenter;
    CGRectSetWidth(_codeTextfield.frame, CGRectGetWidth(_mainBody.frame) - (4 * padding));
    [_codeTextfield addForNextClickTarget:self action:@selector(validCode)];
    [_codeTextfield addForTextChangeTarget:self action:@selector(canValidate)];
    [_mainBody addSubview:_codeTextfield];
    
    height += CGRectGetHeight(_codeTextfield.frame) + padding;
    
    _validCode = [[FLActionButton alloc] initWithFrame:CGRectMake(padding * 2, height, CGRectGetWidth(_mainBody.frame) - (4 * padding), FLActionButtonDefaultHeight) title:NSLocalizedString(@"Join", nil)];
    _validCode.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_validCode addTarget:self action:@selector(validCode) forControlEvents:UIControlEventTouchUpInside];
    [_validCode setEnabled:NO];
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
