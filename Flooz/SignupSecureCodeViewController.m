//
//  SignupSecureCodeViewController.m
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "CodePinView.h"
#import <UICKeyChainStore.h>
#import "SignupSecureCodeViewController.h"

@interface SignupSecureCodeViewController () {
    UIView *_mainContent;
    
    NSString *currentValue;
    CodePinView *_codePinView;
    SecureCodeMode currentSecureMode;
}

@end

#define numberOfDigit 4

@implementation SignupSecureCodeViewController

- (id)initWithMode:(SecureCodeMode)mode {
    self = [super init];
    if (self) {
        if (mode == SecureCodeModeChangeNew)
            self.title = NSLocalizedString(@"SIGNUP_PAGE_TITLE_SECURE_CODE", @"");
        currentSecureMode = mode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FLKeyboardView *keyboardView = [FLKeyboardView new];
    [keyboardView noneCloseButton];
    CGRectSetY(keyboardView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(keyboardView.frame));
    
    {
        _mainContent = [UIView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), 0)];
    }
    
    UILabel *firstTimeText;
    {
        firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), 50)];
        firstTimeText.textColor = [UIColor customGrey];
        firstTimeText.font = [UIFont customTitleLight:18];
        firstTimeText.numberOfLines = 0;
        firstTimeText.textAlignment = NSTextAlignmentCenter;
        if (currentSecureMode == SecureCodeModeChangeNew)
            firstTimeText.text = NSLocalizedString(@"SECORE_CODE_TEXT_SIGNUP_NEW", nil);
        else if (currentSecureMode == SecureCodeModeChangeConfirm)
            firstTimeText.text = NSLocalizedString(@"SECORE_CODE_TEXT_SIGNUP_CONFIRM", nil);
        CGSize s = [self sizeExpectedForView:firstTimeText];
        CGRectSetHeight(firstTimeText.frame, s.height * 2);
        
        [_mainContent addSubview:firstTimeText];
    }
    
    {
        _codePinView = [[CodePinView alloc] initWithNumberOfDigit:numberOfDigit andFrame:CGRectMake(PPScreenWidth() / 4.0f, CGRectGetMaxY(firstTimeText.frame) + 5.0f, PPScreenWidth() / 2.0f, 40.0f)];
        _codePinView.delegate = self;
        [_mainContent addSubview:_codePinView];
        
        keyboardView.delegate = _codePinView;
        [_mainBody addSubview:keyboardView];
    }
    
    CGRectSetHeight(_mainContent.frame, CGRectGetMaxY(_codePinView.frame));
    [_mainContent setCenter:CGPointMake(PPScreenWidth() / 2, (CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(keyboardView.frame)) / 2)];
    [_mainBody addSubview:_mainContent];
}

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

- (void)displayChanges {
    [_codePinView clean];
}

- (NSString *)keyForSecureCode {
    return [NSString stringWithFormat:@"secureCode-%@", [[[Flooz sharedInstance] currentUser] userId]];
}

- (void)pinEnd:(NSString *)pin {
    
    if (self.contentData && self.contentData[@"confirm"] && [self.contentData[@"confirm"] boolValue] && currentSecureMode == SecureCodeModeChangeNew) {
        [self.userDic setValue:pin forKey:@"secureCode"];
        SignupSecureCodeViewController *nextView = [[SignupSecureCodeViewController alloc] initWithMode:SecureCodeModeChangeConfirm];
        [nextView initWithData:self.contentData];
        [self.navigationController pushViewController:nextView animated:YES];
    } else {
        if (currentSecureMode == SecureCodeModeChangeNew ||
            (currentSecureMode == SecureCodeModeChangeConfirm && [self.userDic[@"secureCode"] isEqualToString:pin])) {
            
            [self.userDic setValue:pin forKey:@"secureCode"];
            
            [[Flooz sharedInstance] showLoadView];

            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] signupPassStep:@"secureCode" user:self.userDic success:^(NSDictionary *result) {
                [UICKeyChainStore setString:pin forKey:[self keyForSecureCode]];
                [SignupBaseViewController handleSignupRequestResponse:result withUserData:self.userDic andNavigationController:self.navigationController];

//                if ([result[@"step"][@"next"] isEqualToString:@"signup"]) {
//                    [[Flooz sharedInstance] showLoadView];
//                    [[Flooz sharedInstance] signupPassStep:@"signup" user:self.userDic success:^(NSDictionary *result) {
//                        [appDelegate resetTuto:YES];
//                        [[Flooz sharedInstance] updateCurrentUserAndAskResetCode:result];
//                        
//                        SignupBaseViewController *nextViewController = [SignupBaseViewController getViewControllerForStep:result[@"step"][@"next"] withData:result[@"step"]];
//                        
//                        if (nextViewController) {
//                            nextViewController.userDic = self.userDic;
//                            
//                            [self.navigationController pushViewController:nextViewController animated:YES];
//                        }
//                    } failure:^(NSError *error) {
//                        
//                    }];
//                } else {
//                    SignupBaseViewController *nextViewController = [SignupBaseViewController getViewControllerForStep:result[@"step"][@"next"] withData:result[@"step"]];
//                    
//                    if (nextViewController) {
//                        nextViewController.userDic = self.userDic;
//                        
//                        [self.navigationController pushViewController:nextViewController animated:YES];
//                    }
//                }
            } failure:^(NSError *error) {
                
            }];
        } else {
            [_codePinView animationBadPin];
            [_codePinView clean];
        }
    }
}

@end
