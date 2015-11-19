//
//  ValidateSecureCodeViewController.m
//  Flooz
//
//  Created by Epitech on 10/12/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import <UICKeyChainStore.h>
#import "ValidateSecureCodeViewController.h"

#define numberOfDigit 4

@interface ValidateSecureCodeViewController () {
    UIView *_mainContent;
    
    NSString *currentValue;
    CodePinView *_codePinView;
    SecureCodeMode currentSecureMode;
}

@end

@implementation ValidateSecureCodeViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"NAV_SECURECODE", @"");
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ((FLNavigationController*)self.navigationController).blockBack = YES;

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
        firstTimeText.text = NSLocalizedString(@"SECORE_CODE_TEXT_SIGNUP_NEW", nil);
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
    
    UILabel *infos;
    {
        infos = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, CGRectGetMaxY(_codePinView.frame) + 25.0f, PPScreenWidth() - 30.0f, 50)];
        infos.textColor = [UIColor customGrey];
        infos.font = [UIFont customTitleLight:18];
        infos.numberOfLines = 0;
        [infos setLineBreakMode:NSLineBreakByWordWrapping];
        infos.textAlignment = NSTextAlignmentCenter;
        infos.text = [Flooz sharedInstance].currentTexts.json[@"secureCode"];
        [infos setHeightToFit];
        
        [_mainContent addSubview:infos];
    }
    
    CGRectSetHeight(_mainContent.frame, CGRectGetMaxY(infos.frame));
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
    NSString *pinCode = [pin copy];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updateUser:@{@"secureCode": pinCode} success:^(id result) {
        [UICKeyChainStore setString:pinCode forKey:[self keyForSecureCode]];
        [self dismissViewController];
    } failure:^(NSError *error) {
        
    }];
}

@end
