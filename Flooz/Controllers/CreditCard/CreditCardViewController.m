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
	NSMutableArray *fieldsView;
	UIScrollView *_contentView;
	FLActionButton *_nextButton;
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
	fieldsView = [NSMutableArray new];
	for (UIView *view in[_contentView subviews]) {
		[view removeFromSuperview];
	}

	_card[@"holder"] = [[[Flooz sharedInstance] currentUser] fullname];
}

- (void)prepareViewForCreate {

	{
		[self createNextButton];
		[_nextButton addTarget:self action:@selector(didValidTouch) forControlEvents:UIControlEventTouchUpInside];
	}

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
//	{
//        UIImage *photo = [[UIImage imageNamed:@"bar-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//		UIButton *scanCardButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(cardNumberField.frame) - 50.0f, 0.0f, 50.0f, CGRectGetHeight(cardNumberField.frame))];
//		[scanCardButton setImage:photo forState:UIControlStateNormal];
//        [scanCardButton setTintColor:[UIColor customPlaceholder]];
//
//		CGSize size = photo.size;
//		[scanCardButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, -size.height + 10.0f, -size.width)];
//
//		[scanCardButton addTarget:self action:@selector(presentScanPayViewController) forControlEvents:UIControlEventTouchUpInside];
//        if (!IS_IPHONE_4) {
//            //Not working with iphone 4
//            [cardNumberField addSubview:scanCardButton];
//        }
//	}

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

	[_contentView addSubview:_nextButton];
	CGRectSetY(_nextButton.frame, CGRectGetMaxY(cvvField.frame) + 10.0f);
	[_nextButton setTitle:NSLocalizedString(@"SIGNUP_NEXT_BUTTON_ADD", @"") forState:UIControlStateNormal];
	_contentView.contentSize = CGSizeMake(CGRectGetWidth(_mainBody.frame), CGRectGetMaxY(_nextButton.frame) + 40);

    
    UILabel *cbInfos = [[UILabel alloc] initWithText:NSLocalizedString(@"CREDIT_CARD_INFOS", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:14] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    [cbInfos setLineBreakMode:NSLineBreakByWordWrapping];
    
    if (customLabel && ![customLabel isBlank])
        [cbInfos setText:customLabel];
    else if ([Flooz sharedInstance].currentTexts.card && ![[Flooz sharedInstance].currentTexts.card isBlank])
        [cbInfos setText:[Flooz sharedInstance].currentTexts.card];
    
    CGRectSetWidth(cbInfos.frame, CGRectGetWidth(_contentView.frame) - PADDING_SIDE * 2);
    [cbInfos sizeToFit];
    CGRectSetXY(cbInfos.frame, CGRectGetWidth(_contentView.frame) / 2 - CGRectGetWidth(cbInfos.frame) / 2, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(cbInfos.frame) - PADDING_SIDE);
    [_contentView addSubview:cbInfos];
    
    [self verifAllFieldForCB];
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

        UILabel *cardNumber = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, CGRectGetHeight(view.frame) / 2.0f, CGRectGetWidth(view.frame) - 20.0f*2, 30)];
		{
            UILabel *label = cardNumber;
			label.textColor = [UIColor whiteColor];
			label.font = [UIFont customTitleExtraLight:22];

            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:creditCard.number];
			[attributedString addAttribute:NSKernAttributeName value:@(2.5) range:NSMakeRange(0, attributedString.length)];

			label.attributedText = attributedString;
			[view addSubview:label];
		}

		{
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(cardNumber.frame), CGRectGetMaxY(cardNumber.frame) + 5.0f, CGRectGetWidth(cardNumber.frame), 30)];
			label.textColor = [UIColor whiteColor];

			label.font = [UIFont customContentRegular:14];
			label.text = [creditCard.owner uppercaseString];
			[label setWidthToFit];
			[view addSubview:label];
		}
	}

	{
        MARGE_LEFT_RIGHT += 6;
		FLActionButton *button = [[FLActionButton alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, CGRectGetHeight(_contentView.frame) - 60.0f, CGRectGetWidth(_contentView.frame) - (2 * MARGE_LEFT_RIGHT), FLActionButtonDefaultHeight) title:NSLocalizedString(@"CREDIT_CARD_REMOVE", nil)];

        [button setBackgroundColor:[UIColor customBackgroundStatus] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor customBackgroundStatus:0.5f] forState:UIControlStateDisabled];
        [button setBackgroundColor:[UIColor customBackgroundStatus:0.5f] forState:UIControlStateHighlighted];
		[button setImage:[UIImage imageNamed:@"trash"] size:CGSizeMake(16, 16)];

		button.titleLabel.font = [UIFont customTitleExtraLight:15];

		[button addTarget:self action:@selector(didRemoveCardTouch) forControlEvents:UIControlEventTouchUpInside];

		[_contentView addSubview:button];
	}
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
//	if (!_card[@"number"] || !_card[@"cvv"] || !_card[@"expires"] || !_card[@"holder"] ||
//	    [_card[@"number"] isBlank] || [_card[@"cvv"] isBlank] || [_card[@"expires"] isBlank] || [_card[@"holder"] isBlank]) {
//		verifOk = NO;
////		[_nextButton setEnabled:NO];
//	}
//	else {
////		[_nextButton setEnabled:YES];
//	}
	return verifOk;
}

- (void)didValidTouch {
	[[self view] endEditing:YES];

//    [_nextButton setEnabled:NO];
    
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
