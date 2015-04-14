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
    if (currentSecureMode == SecureCodeModeChangeNew) {
        [self.userDic setValue:pin forKey:@"secureCode"];
        [self.navigationController pushViewController:[[SignupSecureCodeViewController alloc] initWithMode:SecureCodeModeChangeConfirm] animated:YES];
    }
    else if (currentSecureMode == SecureCodeModeChangeConfirm) {
        if ([self.userDic[@"secureCode"] isEqualToString:pin]) {
            [[Flooz sharedInstance] showLoadView];
            
            NSString *deviceToken = [appDelegate currentDeviceToken];
            if (deviceToken) {
                [self.userDic setValue:deviceToken forKeyPath:@"device"];
            }
            NSData *dataPic = self.userDic[@"picId"];
            
            if (dataPic && [dataPic length] > 0)
                self.userDic[@"hasImage"] = @YES;
            
            [self.userDic removeObjectForKey:@"picId"];
            
            __block NSData *weakPic = dataPic;
            [[Flooz sharedInstance] signup:self.userDic success: ^(id result) {
                [[Flooz sharedInstance] hideLoadView];
                [UICKeyChainStore setString:pin forKey:[self keyForSecureCode]];
                
                if (weakPic && ![weakPic isEqual:[NSData new]]) {
                    [[Flooz sharedInstance] showLoadView];
                    [[Flooz sharedInstance] uploadDocument:weakPic field:@"picId" success:NULL failure:NULL];
                }
                [appDelegate goToAccountViewController];
            } failure: ^(NSError *error) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else {
            [_codePinView animationBadPin];
            [_codePinView clean];
        }
    }
}

@end
