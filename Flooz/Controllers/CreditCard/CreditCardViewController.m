//
//  CreditCardViewController.m
//  Flooz
//
//  Created by Arnaud Lays on 10/03/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "CreditCardViewController.h"
#import "FLTextFieldTitle2.h"
#import "FLKeyboardView.h"
#import "ScanPayViewController.h"
#import "3DSecureViewController.h"

#define PADDING_SIDE 20.0f

@interface CreditCardViewController () {
    FLCreditCard *creditCard;
    NSMutableDictionary *_card;
    
    UIScrollView *_contentView;
    FLActionButton *_nextButton;
    
    STPPaymentCardTextField *paymentTextField;
}

@end

@implementation CreditCardViewController

@synthesize customLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_CREDIT_CARD", nil);
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshTitle {
    FLUser *currentUser = [[Flooz sharedInstance] currentUser];
    if ([currentUser creditCard]) {
        self.title = NSLocalizedString(@"NAV_CREDIT_CARD", nil);
    }
    else {
        self.title = NSLocalizedString(@"NAV_CREDIT_CARD_ADD", nil);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self resetContentView];
    
    [self addTapGestureForDismissKeyboard];
}

- (void)viewWillAppear:(BOOL)animated {
    [[Flooz sharedInstance] updateCurrentUserWithSuccess:^{
        [self reloadView];
    }];
    [self reloadView];
}

- (void)reloadView {
    [_mainBody.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    [_mainBody addSubview:_contentView];
    
    FLUser *currentUser = [[Flooz sharedInstance] currentUser];
    if ([currentUser creditCard] && [currentUser creditCard].cardId && [currentUser creditCard].owner && [currentUser creditCard].number) {
        creditCard = [currentUser creditCard];
        [self prepareViewForDelete];
    }
    else {
        [self prepareViewForCreate];
    }
    
    [self refreshTitle];
}

- (void)addTapGestureForDismissKeyboard {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [_mainBody addGestureRecognizer:tapGesture];
    [_contentView addGestureRecognizer:tapGesture];
    [self registerForKeyboardNotifications];
}

- (void)createNextButton {
    _nextButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, 0, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"GLOBAL_SAVE", nil)];
    
    [_nextButton setEnabled:YES];
}

- (void)resetContentView {
    _card = [NSMutableDictionary new];
    for (UIView *view in[_contentView subviews]) {
        [view removeFromSuperview];
    }
    
    _card[@"holder"] = [[[Flooz sharedInstance] currentUser] fullname];
}

- (void)prepareViewForCreate {
    
    [self createNextButton];
    [_nextButton addTarget:self action:@selector(didValidTouch) forControlEvents:UIControlEventTouchUpInside];
    
    paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(PADDING_SIDE, 25, PPScreenWidth() - (2 * PADDING_SIDE), 40)];
    paymentTextField.delegate = self;
    [paymentTextField setTextColor:[UIColor whiteColor]];
    [paymentTextField setFont:[UIFont customContentRegular:16]];
    [paymentTextField setPlaceholderColor:[UIColor customPlaceholder]];
    [paymentTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [paymentTextField setBorderColor:[UIColor clearColor]];
    [paymentTextField setNumberPlaceholder:@"•••• •••• •••• ••••"];
    [paymentTextField setTextErrorColor:[UIColor customRed]];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(paymentTextField.frame), PPScreenWidth() - (2 * PADDING_SIDE), 1)];
    [separator setBackgroundColor:[UIColor customBackground]];
    
    [_contentView addSubview:paymentTextField];
    [_contentView addSubview:separator];
    
    [_contentView addSubview:_nextButton];
    CGRectSetY(_nextButton.frame, CGRectGetMaxY(paymentTextField.frame) + 20.0f);
    [_nextButton setTitle:NSLocalizedString(@"GLOBAL_SAVE", @"") forState:UIControlStateNormal];
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_mainBody.frame), CGRectGetMaxY(_nextButton.frame) + 40);
    
    UIImageView *cards = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(_nextButton.frame) + 15, PPScreenWidth() - (2 * PADDING_SIDE), 80)];
    [cards setImage:[UIImage imageNamed:@"cards"]];
    [cards setContentMode:UIViewContentModeScaleAspectFit];
    
    [_contentView addSubview:cards];
    
    UILabel *cbInfos = [[UILabel alloc] initWithText:NSLocalizedString(@"CREDIT_CARD_INFOS", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:14] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    [cbInfos setLineBreakMode:NSLineBreakByWordWrapping];
    
    if (customLabel && ![customLabel isBlank])
        [cbInfos setText:customLabel];
    else if ([Flooz sharedInstance].currentTexts.card && ![[Flooz sharedInstance].currentTexts.card isBlank])
        [cbInfos setText:[Flooz sharedInstance].currentTexts.card];
    
    CGRectSetWidth(cbInfos.frame, CGRectGetWidth(_contentView.frame) - PADDING_SIDE * 2);
    [cbInfos sizeToFit];
    CGRectSetXY(cbInfos.frame, CGRectGetWidth(_contentView.frame) / 2 - CGRectGetWidth(cbInfos.frame) / 2, CGRectGetMaxY(cards.frame) + 15);
    [_contentView addSubview:cbInfos];
}

- (void)prepareViewForDelete {
    self.navigationItem.rightBarButtonItem = nil;
    [self resetContentView];
    
    UIImageView *view = [UIImageView imageNamed:@"card-background"];
    
    CGFloat scaleRatio = CGRectGetHeight(view.frame) / CGRectGetWidth(view.frame);
    CGFloat MARGE_LEFT_RIGHT = 20;
    
    [view setFrame:CGRectMake(MARGE_LEFT_RIGHT, 20, PPScreenWidth() - MARGE_LEFT_RIGHT * 2, (PPScreenWidth() - MARGE_LEFT_RIGHT * 2) * scaleRatio)];
    [view setContentMode:UIViewContentModeScaleToFill];
    
    {
        [_contentView addSubview:view];
        
        UILabel *cardNumber = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, CGRectGetHeight(view.frame) / 2.0f - 10.0f, CGRectGetWidth(view.frame) - 20.0f*2, 30)];
        {
            UILabel *label = cardNumber;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont customCreditCard:22];
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 15. / label.font.pointSize;

            label.text = [NSString stringWithFormat:@"%@ **** **** %@", [creditCard.number substringToIndex:4], [creditCard.number substringFromIndex:creditCard.number.length - 4]];
            
            [view addSubview:label];
        }
        
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(cardNumber.frame), CGRectGetMaxY(cardNumber.frame) + 20.0f, CGRectGetWidth(cardNumber.frame), 30)];
            label.textColor = [UIColor whiteColor];
            
            label.font = [UIFont customCreditCard:12];
            label.text = [creditCard.owner uppercaseString];
            [label setWidthToFit];
            [view addSubview:label];
        }
        
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(cardNumber.frame), CGRectGetMaxY(cardNumber.frame) + 20.0f, CGRectGetWidth(cardNumber.frame), 30)];
            label.textColor = [UIColor whiteColor];
            
            label.font = [UIFont customCreditCard:12];
            label.text = [creditCard.expires uppercaseString];
            [label setWidthToFit];
            
            CGRectSetX(label.frame, CGRectGetWidth(view.frame) - CGRectGetWidth(label.frame) - 20.0f);
            
            [view addSubview:label];
        }
    }
    
    {
        MARGE_LEFT_RIGHT += 6;
        FLActionButton *button = [[FLActionButton alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, CGRectGetHeight(_contentView.frame) - 65.0f, CGRectGetWidth(_contentView.frame) - (2 * MARGE_LEFT_RIGHT), FLActionButtonDefaultHeight) title:NSLocalizedString(@"CREDIT_CARD_REMOVE", nil)];
        
        [button setBackgroundColor:[UIColor customBackgroundStatus] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor customBackgroundStatus:0.5f] forState:UIControlStateDisabled];
        [button setBackgroundColor:[UIColor customBackgroundStatus:0.5f] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:@"trash"] size:CGSizeMake(16, 16)];
        
        button.titleLabel.font = [UIFont customTitleExtraLight:15];
        
        [button addTarget:self action:@selector(didRemoveCardTouch) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:button];
    }
}

- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField {
    
}

#pragma mark - ScanPay

- (void)presentScanPayViewController {
    
//    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    
//    if (authStatus == AVAuthorizationStatusAuthorized) {
//        ScanPayViewController *scanPayViewController = [[ScanPayViewController alloc] initWithToken:@"be38035037ed6ca3cba7089b" useConfirmationView:YES useManualEntry:YES];
//        
//        [scanPayViewController startScannerWithViewController:self success: ^(SPCreditCard *card) {
//            [_card setValue:card.number forKey:@"number"];
//            [_card setValue:card.cvc forKey:@"cvv"];
//            
//            NSString *expires = [NSString stringWithFormat:@"%@-%@", card.month, card.year];
//            
//            [_card setValue:expires forKey:@"expires"];
//            
//            for (FLTextFieldTitle2 * view in fieldsView) {
//                [view reloadData];
//            }
//        } cancel: ^{
//            [fieldsView[1] becomeFirstResponder];
//        }];
//    } else if (authStatus == AVAuthorizationStatusNotDetermined){
//        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//            if (granted){
//                ScanPayViewController *scanPayViewController = [[ScanPayViewController alloc] initWithToken:@"be38035037ed6ca3cba7089b" useConfirmationView:YES useManualEntry:YES];
//                
//                [scanPayViewController startScannerWithViewController:self success: ^(SPCreditCard *card) {
//                    [_card setValue:card.number forKey:@"number"];
//                    [_card setValue:card.cvc forKey:@"cvv"];
//                    
//                    NSString *expires = [NSString stringWithFormat:@"%@-%@", card.month, card.year];
//                    
//                    [_card setValue:expires forKey:@"expires"];
//                    
//                    for (FLTextFieldTitle2 * view in fieldsView) {
//                        [view reloadData];
//                    }
//                } cancel: ^{
//                    [fieldsView[1] becomeFirstResponder];
//                }];
//            } else {
//                
//            }
//        }];
//    } else {
//        UIAlertView* curr = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CAMERA_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CAMERA_CONTENT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_SETTINGS", nil), nil];
//        [curr setTag:125];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [curr show];
//        });
//    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 125 && buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - Verification

- (void)didValidTouch {
    [[self view] endEditing:YES];
    
    //    [_nextButton setEnabled:NO];
    
    _card[@"number"] = paymentTextField.cardNumber;
    _card[@"cvv"] = paymentTextField.cvc;
    _card[@"expires"] = [NSString stringWithFormat:@"%02lu-%02lu", (unsigned long)paymentTextField.expirationMonth, (unsigned long)paymentTextField.expirationYear];
    
    if (self.floozData && self.floozData.allKeys.count) {
        _card[@"flooz"] = self.floozData;
    }
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createCreditCard:_card atSignup:NO success: ^(id result) {
        if (![Secure3DViewController getInstance]) {
            FLUser *currentUser = [[Flooz sharedInstance] currentUser];
            creditCard = [currentUser creditCard];
            [self dismissViewController];
        }
    }];
}

- (void)didRemoveCardTouch {
    NSString *creditCardId = [[[[Flooz sharedInstance] currentUser] creditCard] cardId];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] removeCreditCard:creditCardId success: ^(id result) {
        creditCard = nil;
        [[[Flooz sharedInstance] currentUser] setCreditCard:nil];
        [self reloadView];
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
