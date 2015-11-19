//
//  SignupCreditCardViewController.m
//  Flooz
//
//  Created by Flooz on 6/3/15.
//  Copyright (c) 2015 Flooz. All rights reserved.
//

#import "SignupCreditCardViewController.h"
#import "FLTextFieldTitle2.h"
#import "FLKeyboardView.h"
#import "ScanPayViewController.h"

#define PADDING_SIDE 20.0f

@interface SignupCreditCardViewController () {
    NSMutableDictionary *_card;
    UIScrollView *_contentView;
    NSMutableArray *fieldsView;
    FLActionButton *_nextButton;
    FLActionButton *_skipButton;
}

@end

@implementation SignupCreditCardViewController

- (id)init {
    self = [super init];
    if (self) {
        self.userDic = [NSMutableDictionary new];
        self.title = NSLocalizedString(@"NAV_CREDIT_CARD_ADD", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[_headerView viewWithTag:666] removeFromSuperview];
    
    _card = [NSMutableDictionary new];
    _card[@"holder"] = [[[Flooz sharedInstance] currentUser] fullname];

    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    [_mainBody addSubview:_contentView];
    
    fieldsView = [NSMutableArray new];
    
    FLTextFieldTitle2 *ownerField = [[FLTextFieldTitle2 alloc] initWithTitle:@"" placeholder:@"SIGNUP_FIELD_CARD_OWNER_PLACEHOLDER" for:_card key:@"holder" position:CGPointMake(PADDING_SIDE, -2.0f)];
    [ownerField addForNextClickTarget:self action:@selector(didOwnerEndEditing)];
    [_contentView addSubview:ownerField];
    [fieldsView addObject:ownerField];
    
    
    FLTextFieldTitle2 *cardNumberField = [[FLTextFieldTitle2 alloc] initWithTitle:@"" placeholder:@"SIGNUP_FIELD_CARD_NUMBER_PLACEHOLDER" for:_card key:@"number" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(ownerField.frame) - 2.0f)];
    [cardNumberField setKeyboardType:UIKeyboardTypeDecimalPad];
    [cardNumberField setStyle:FLTextFieldTitle2StyleCardNumber];
    [cardNumberField addForNextClickTarget:self action:@selector(didNumberEndEditing)];
    [_contentView addSubview:cardNumberField];
    [fieldsView addObject:cardNumberField];
    {
        FLKeyboardView *inputViewField = [FLKeyboardView new];
        inputViewField.textField = cardNumberField.textfield;
        cardNumberField.textfield.inputView = inputViewField;
    }
//    {
//        UIImage *photo = [UIImage imageNamed:@"bar-camera"];
//        UIButton *scanCardButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(cardNumberField.frame) - 50.0f, 0.0f, 50.0f, CGRectGetHeight(cardNumberField.frame))];
//        [scanCardButton setImage:photo forState:UIControlStateNormal];
//        
//        CGSize size = photo.size;
//        [scanCardButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, -size.height + 10.0f, -size.width)];
//        
//        [scanCardButton addTarget:self action:@selector(presentScanPayViewController) forControlEvents:UIControlEventTouchUpInside];
//        if (!IS_IPHONE_4) {
//            //Not working with iphone 4
//            [cardNumberField addSubview:scanCardButton];
//        }
//    }
    
    FLTextFieldTitle2 *expireField = [[FLTextFieldTitle2 alloc] initWithTitle:@"" placeholder:@"SIGNUP_FIELD_CARD_EXPIRES_PLACEHOLDER" for:_card key:@"expires" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(cardNumberField.frame) - 2.0f)];
    [expireField setKeyboardType:UIKeyboardTypeDecimalPad];
    [expireField setStyle:FLTextFieldTitle2StyleCardExpire];
    [expireField addForNextClickTarget:self action:@selector(didExpiresEndEditing)];
    [_contentView addSubview:expireField];
    [fieldsView addObject:expireField];
    {
        FLKeyboardView *inputViewField = [FLKeyboardView new];
        inputViewField.textField = expireField.textfield;
        expireField.textfield.inputView = inputViewField;
    }
    
    FLTextFieldTitle2 *cvvField = [[FLTextFieldTitle2 alloc] initWithTitle:@"" placeholder:@"SIGNUP_FIELD_CARD_CVV_PLACEHOLDER" for:_card key:@"cvv" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(expireField.frame) - 2.0f)];
    [cvvField setKeyboardType:UIKeyboardTypeDecimalPad];
    [cvvField setStyle:FLTextFieldTitle2StyleCVV];
    [cvvField addForNextClickTarget:self action:@selector(didCVVEndEditing)];
    [_contentView addSubview:cvvField];
    [fieldsView addObject:cvvField];
    {
        FLKeyboardView *inputViewField = [FLKeyboardView new];
        inputViewField.textField = cvvField.textfield;
        cvvField.textfield.inputView = inputViewField;
    }
    
    _nextButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(cvvField.frame) + 10.0f, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"SIGNUP_NEXT_BUTTON_ADD", nil)];
    [_nextButton addTarget:self action:@selector(didValidTouch) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_nextButton];

    _skipButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(_nextButton.frame) + 10.0f, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"SIGNUP_SKIP_BUTTON", nil)];
    [_skipButton setBackgroundColor:[UIColor customBackground] forState:UIControlStateNormal];
    [_skipButton addTarget:self action:@selector(didSkipTouch) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_skipButton];

    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_mainBody.frame), CGRectGetMaxY(_nextButton.frame) + 40);
    
    UILabel *cbInfos = [[UILabel alloc] initWithText:NSLocalizedString(@"CREDIT_CARD_INFOS", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:14] textAlignment:NSTextAlignmentCenter numberOfLines:8];
    CGRectSetWidth(cbInfos.frame, CGRectGetWidth(_contentView.frame) - PADDING_SIDE * 2);
    CGRectSetHeight(cbInfos.frame, 130);
    CGRectSetXY(cbInfos.frame, PADDING_SIDE, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(cbInfos.frame) - PADDING_SIDE);
    [_contentView addSubview:cbInfos];
    
    [self verifAllFieldForCB];

    [self addTapGestureForDismissKeyboard];
}

- (void)addTapGestureForDismissKeyboard {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [_mainBody addGestureRecognizer:tapGesture];
    [_contentView addGestureRecognizer:tapGesture];
    [_headerView addGestureRecognizer:tapGesture];
    [self registerForKeyboardNotifications];
}

#pragma mark - ScanPay

- (void)presentScanPayViewController {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusAuthorized) {
        ScanPayViewController *scanPayViewController = [[ScanPayViewController alloc] initWithToken:@"be38035037ed6ca3cba7089b" useConfirmationView:YES useManualEntry:YES];
        
        [scanPayViewController startScannerWithViewController:self success: ^(SPCreditCard *card) {
            [_card setValue:card.number forKey:@"number"];
            [_card setValue:card.cvc forKey:@"cvv"];
            
            NSString *expires = [NSString stringWithFormat:@"%@-%@", card.month, card.year];
            
            [_card setValue:expires forKey:@"expires"];
            
            for (FLTextFieldTitle2 * view in fieldsView) {
                [view reloadData];
            }
            if ([self verifAllFieldForCB])
                [self didValidTouch];
        } cancel: ^{
            [fieldsView[1] becomeFirstResponder];
        }];
    } else if (authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted){
                ScanPayViewController *scanPayViewController = [[ScanPayViewController alloc] initWithToken:@"be38035037ed6ca3cba7089b" useConfirmationView:YES useManualEntry:YES];
                
                [scanPayViewController startScannerWithViewController:self success: ^(SPCreditCard *card) {
                    [_card setValue:card.number forKey:@"number"];
                    [_card setValue:card.cvc forKey:@"cvv"];
                    
                    NSString *expires = [NSString stringWithFormat:@"%@-%@", card.month, card.year];
                    
                    [_card setValue:expires forKey:@"expires"];
                    
                    for (FLTextFieldTitle2 * view in fieldsView) {
                        [view reloadData];
                    }
                    if ([self verifAllFieldForCB])
                        [self didValidTouch];
                } cancel: ^{
                    [fieldsView[1] becomeFirstResponder];
                }];
            } else {
                
            }
        }];
    } else {
        UIAlertView* curr = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CAMERA_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CAMERA_CONTENT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_SETTINGS", nil), nil];
        [curr setTag:125];
        dispatch_async(dispatch_get_main_queue(), ^{
            [curr show];
        });
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 125 && buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - Verification

- (void)didOwnerEndEditing {
    [fieldsView[1] becomeFirstResponder];
    [self verifAllFieldForCB];
}

- (void)didNumberEndEditing {
    [fieldsView[2] becomeFirstResponder];
    [self verifAllFieldForCB];
}

- (void)didExpiresEndEditing {
    [fieldsView[3] becomeFirstResponder];
    [self verifAllFieldForCB];
}

- (void)didCVVEndEditing {
    [[self view] endEditing:YES];
    [self verifAllFieldForCB];
}

- (BOOL)verifAllFieldForCB {
    BOOL verifOk = YES;

    return verifOk;
}

- (void)didSkipTouch {
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] signupPassStep:@"cardSkip" user:nil success: ^(id result) {
        [SignupBaseViewController handleSignupRequestResponse:result withUserData:self.userDic andNavigationController:self.navigationController];
    } failure:^(NSError *error) {
        
    }];
}

- (void)didValidTouch {
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] signupPassStep:@"card" user:_card success: ^(id result) {
        [SignupBaseViewController handleSignupRequestResponse:result withUserData:self.userDic andNavigationController:self.navigationController];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight + 30, 0);
}

- (void)keyboardWillDisappear {
    _contentView.contentInset = UIEdgeInsetsZero;
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

@end
