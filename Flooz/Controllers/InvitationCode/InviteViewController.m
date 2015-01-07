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
    UILabel *_learnMore;

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
    CGFloat height = 10;
    
    if (!IS_IPHONE4) {
        UIImageView *logo = [UIImageView imageNamed:@"white-logo"];
        logo.image = [logo.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [logo setTintColor:[UIColor customBlue]];
        [logo setContentMode:UIViewContentModeScaleAspectFit];
        CGRectSetHeight(logo.frame, 60);
        CGRectSetX(logo.frame, CGRectGetWidth(_mainBody.frame) / 2 - CGRectGetWidth(logo.frame) / 2);
        CGRectSetY(logo.frame, height);
        [_mainBody addSubview:logo];
        
        height += CGRectGetHeight(logo.frame) + 10;
    }
    
    _textExplication = [[UILabel alloc] initWithFrame:CGRectMake(padding, height, PPScreenWidth() - padding * 2.0f, 50)];
    _textExplication.textColor = [UIColor customWhite];
    _textExplication.font = [UIFont customTitleExtraLight:18];
    if (IS_IPHONE4) {
        _textExplication.font = [UIFont customTitleExtraLight:17];
    }
    _textExplication.textAlignment = NSTextAlignmentCenter;
    _textExplication.numberOfLines = 0;
    [_textExplication setText:NSLocalizedString(@"INVITATION_CODE_EXPLICATION", nil)];
    [_textExplication heightToFit];
    CGRectSetY(_textExplication.frame, height);
    [_mainBody addSubview:_textExplication];
    
    height += CGRectGetHeight(_textExplication.frame);
    
    _learnMore = [[UILabel alloc] initWithFrame:CGRectMake(padding, height, PPScreenWidth() - padding * 2.0f, 20)];
    _learnMore.textColor = [UIColor customBlue];
    _learnMore.font = [UIFont customTitleLight:17];
    if (IS_IPHONE4) {
        _learnMore.font = [UIFont customTitleExtraLight:16];
    }
    _learnMore.textAlignment = NSTextAlignmentCenter;
    _learnMore.numberOfLines = 0;
    [_learnMore setText:NSLocalizedString(@"LEARN_MORE", nil)];
    [_learnMore heightToFit];
    [_learnMore setUserInteractionEnabled:YES];
    CGRectSetY(_learnMore.frame, height);
    [_learnMore addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openLearnMore)]];
    [_mainBody addSubview:_learnMore];

    height += CGRectGetHeight(_learnMore.frame) + 10;
    
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

- (void)openLearnMore {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.flooz.me/about/invitation"]];
}

- (void)validCode {
    [_codeTextfield resignFirstResponder];
    
    if (_userDic[@"coupon"] && ![_userDic[@"coupon"] isBlank]) {
        [[Flooz sharedInstance] showLoadView];
        _userDic[@"distinctId"] = [[Mixpanel sharedInstance] distinctId];
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

@end
