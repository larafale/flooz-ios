//
//  CreditCardViewController.m
//  Flooz
//
//  Created by Arnaud Lays on 10/03/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "CreditCardViewController.h"
#import "FLTextFieldTitle2.h"
#import "3DSecureViewController.h"
#import "FLCreditCardScanner.h"
#import <mangopay/mangopay.h>

#define PADDING_SIDE 20.0f

@interface CreditCardViewController () {
    FLCreditCard *creditCard;
    NSMutableDictionary *_card;
    
    UIScrollView *_contentView;
    FLActionButton *_nextButton;
    
    UILabel *inputHint;
    FLTextField *holderTextField;
    STPPaymentCardTextField *paymentTextField;
    UIImageView *scanCardButton;
    
    UIView *saveCardButton;
    UIImageView *saveCardImageView;
    UILabel *saveCardLabel;
    
    NSMutableDictionary *dictionary;
    
    Boolean hideSaveCard;
    Boolean saveCard;
    
    FLCreditCardScanner *scanner;
    
    MPAPIClient *mangopayClient;
}

@end

@implementation CreditCardViewController

@synthesize customLabel;

- (id)init {
    self = [super init];
    if (self) {
        hideSaveCard = YES;
        saveCard = YES;

    }
    return self;
}

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super initWithTriggerData:data];
    if (self) {
        hideSaveCard = YES;
        saveCard = YES;

        if (self.triggerData && self.triggerData[@"hideSave"]) {
            hideSaveCard = [self.triggerData[@"hideSave"] boolValue];
        }
        
        if (self.triggerData && self.triggerData[@"save"]) {
            saveCard = [self.triggerData[@"save"] boolValue];
        }
        
        if (self.triggerData && self.triggerData[@"flooz"]) {
            _floozData = self.triggerData[@"flooz"];
        }

        if (self.triggerData && self.triggerData[@"item"]) {
            _itemData = self.triggerData[@"item"];
        }
    
        if (self.triggerData && self.triggerData[@"cashin"]) {
            _cashinData = self.triggerData[@"cashin"];
        }
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
        self.title = NSLocalizedString(@"NAV_CREDIT_CARD", nil);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dictionary = [NSMutableDictionary new];

    [self loadCardRegistrationData];

    [self resetContentView];
    
    [self addTapGestureForDismissKeyboard];
    
    [self registerNotification:@selector(reloadView) name:kNotificationReloadCurrentUser object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
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
    
    inputHint = [[UILabel alloc] initWithText:NSLocalizedString(@"CASHIN_CARD_PAYMENT_INPUT_HINT", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15]];
    CGRectSetXY(inputHint.frame, PADDING_SIDE, 20);
    
    holderTextField = [[FLTextField alloc] initWithPlaceholder:@"Nom du titulaire" for:dictionary key:@"holder" frame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(inputHint.frame) + 5, PPScreenWidth() - (2 * PADDING_SIDE), 30)];
    holderTextField.floatLabelActiveColor = [UIColor clearColor];
    holderTextField.floatLabelPassiveColor = [UIColor clearColor];
    [holderTextField setType:FLTextFieldTypeText];

    paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(PADDING_SIDE, 25, PPScreenWidth() - (2 * PADDING_SIDE), 40)];
    paymentTextField.delegate = self;
    [paymentTextField setTextColor:[UIColor whiteColor]];
    [paymentTextField setFont:[UIFont customContentRegular:16]];
    [paymentTextField setPlaceholderColor:[UIColor customPlaceholder]];
    [paymentTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [paymentTextField setBorderColor:[UIColor clearColor]];
    [paymentTextField setNumberPlaceholder:@"••••••••••••••••"];
    [paymentTextField setTextErrorColor:[UIColor customRed]];
    [paymentTextField addBottomBorderWithColor:[UIColor customBackground] andWidth:0.7];
    
    scanCardButton = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(paymentTextField.frame) - 33, CGRectGetMaxY(inputHint.frame) + 5, 33, 40)];
    [scanCardButton setImage:[[FLHelper imageWithImage:[UIImage imageNamed:@"bar-camera"] scaledToSize:CGSizeMake(25, 23)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [scanCardButton setTintColor:[UIColor customPlaceholder]];
    [scanCardButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanButtonClick)]];
    [scanCardButton setUserInteractionEnabled:YES];
    [scanCardButton setContentMode:UIViewContentModeCenter];
    [scanCardButton setHidden:YES];
    [scanCardButton addBottomBorderWithColor:[UIColor customBackground] andWidth:0.7];

//    if ([CardIOUtilities canReadCardWithCamera]) {
//        CGRectSetWidth(paymentTextField.frame, PPScreenWidth() - (2 * PADDING_SIDE) - 30);
//        [scanCardButton setHidden:NO];
//    }
    
    if ([[[Flooz sharedInstance] currentTexts] cardHolder]) {
        holderTextField.hidden = NO;
        if ([[[[Flooz sharedInstance] currentTexts] cardHolder] isEqualToString:@"true"]) {
            dictionary[@"holder"] = [[[Flooz sharedInstance] currentUser] fullname];
            [holderTextField reloadTextField];
        } else {
            dictionary[@"holder"] = @"";
            [holderTextField reloadTextField];
        }
        
        CGRectSetY(paymentTextField.frame, CGRectGetMaxY(holderTextField.frame) + 10);
        CGRectSetY(scanCardButton.frame, CGRectGetMaxY(holderTextField.frame) + 10);
    } else {
        holderTextField.hidden = YES;
        CGRectSetY(paymentTextField.frame, CGRectGetMaxY(inputHint.frame) + 5);
        CGRectSetY(scanCardButton.frame, CGRectGetMaxY(inputHint.frame) + 5);
    }

    saveCardButton = [[UIView alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(paymentTextField.frame) + 10, PPScreenWidth() - 2 * PADDING_SIDE, 30)];
    [saveCardButton setUserInteractionEnabled:YES];
    [saveCardButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSaveCardButtonClick)]];
    
    saveCardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 20, 20)];
    saveCardImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    saveCardLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(saveCardImageView.frame) + 10, 5, CGRectGetWidth(saveCardButton.frame) - CGRectGetMaxX(saveCardImageView.frame) - 10, 20)];
    saveCardLabel.textColor = [UIColor whiteColor];
    saveCardLabel.font = [UIFont customContentRegular:15];
    saveCardLabel.text = NSLocalizedString(@"CASHIN_CARD_CHECKBOX_TEXT", nil);
    saveCardLabel.adjustsFontSizeToFitWidth = YES;
    saveCardLabel.minimumScaleFactor = 10. / saveCardLabel.font.pointSize;
    
    [saveCardButton addSubview:saveCardImageView];
    [saveCardButton addSubview:saveCardLabel];
    
    [_contentView addSubview:inputHint];
    [_contentView addSubview:holderTextField];
    [_contentView addSubview:scanCardButton];
    [_contentView addSubview:paymentTextField];
    [_contentView addSubview:saveCardButton];
    
    [_contentView addSubview:_nextButton];
    
    if (hideSaveCard) {
        [saveCardButton setHidden:YES];
        CGRectSetY(_nextButton.frame, CGRectGetMaxY(paymentTextField.frame) + 20.0f);
    } else {
        CGRectSetY(_nextButton.frame, CGRectGetMaxY(saveCardButton.frame) + 20.0f);
        
        if (saveCard)
            [saveCardImageView setImage:[UIImage imageNamed:@"checkmark-on"]];
        else
            [saveCardImageView setImage:[UIImage imageNamed:@"checkmark-off"]];
    }
    
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
    else if (self.triggerData && self.triggerData[@"infos"] && ![self.triggerData[@"infos"] isBlank])
        [cbInfos setText:self.triggerData[@"infos"]];
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

            label.text = [NSString stringWithFormat:@"**** **** **** %@", [creditCard.number substringFromIndex:creditCard.number.length - 4]];
            
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

- (void)loadCardRegistrationData {
    [[Flooz sharedInstance] getCardRegistrationData:^(id result) {
        NSDictionary *cardData = @{@"cardRegistrationURL": result[@"item"][@"CardRegistrationURL"],
                                   @"preregistrationData": result[@"item"][@"PreregistrationData"],
                                   @"cardType": result[@"item"][@"CardType"],
                                   @"clientId": [Flooz sharedInstance].currentTexts.mangopayOptions.clientId,
                                   @"cardPreregistrationId": result[@"item"][@"Id"],
                                   @"baseURL": [Flooz sharedInstance].currentTexts.mangopayOptions.baseURL,
                                   @"accessKey": result[@"item"][@"AccessKey"]};
        
        self->mangopayClient = [[MPAPIClient alloc] initWithCard:cardData];
    } failure:nil];
}

- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField {
    
}

#pragma mark - CardIO

- (void)scanButtonClick {
    [self.view endEditing:YES];
    [self.view endEditing:NO];
    
    scanner = nil;
    scanner = [[FLCreditCardScanner alloc] initWithDelegate:self];
    [scanner show];
}

- (void)cardIOView:(CardIOView *)cardIOView didScanCard:(CardIOCreditCardInfo *)info {
    if (info) {
        STPCardParams *params = [STPCardParams new];
        params.number = info.cardNumber;
        params.expMonth = info.expiryMonth;
        params.expYear = info.expiryYear;
        params.cvc = info.cvv;
        
        [scanner dismiss];
        scanner = nil;
        
        [paymentTextField setCardParams:params];
        [paymentTextField becomeFirstResponder];
    }
    else {
        [scanner dismiss];
        scanner = nil;
    }
}

#pragma mark - Verification

- (void)didSaveCardButtonClick {
    saveCard = !saveCard;
    
    if (saveCard)
        [saveCardImageView setImage:[UIImage imageNamed:@"checkmark-on"]];
    else
        [saveCardImageView setImage:[UIImage imageNamed:@"checkmark-off"]];
}

- (void)didValidTouch {
    [[self view] endEditing:YES];
    
    if (dictionary[@"holder"] && [[[Flooz sharedInstance] currentTexts] cardHolder]) {
        _card[@"holder"] = dictionary[@"holder"];
    }
    
    if (paymentTextField.cardNumber && ![paymentTextField.cardNumber isBlank])
        _card[@"number"] = paymentTextField.cardNumber;
    
    if (paymentTextField.cvc && ![paymentTextField.cvc isBlank])
        _card[@"cvv"] = paymentTextField.cvc;
    
    if (paymentTextField.expirationMonth != 0 && paymentTextField.expirationYear != 0)
        _card[@"expires"] = [NSString stringWithFormat:@"%02lu-%02lu", (unsigned long)paymentTextField.expirationMonth, (unsigned long)paymentTextField.expirationYear];
    
    if (!hideSaveCard)
        _card[@"hidden"] = @(!saveCard);

    if (self.floozData && self.floozData.allKeys.count) {
        _card[@"flooz"] = self.floozData;
    }

    if (self.itemData && self.itemData.allKeys.count) {
        _card[@"item"] = self.itemData;
    }

    if (self.cashinData && self.cashinData.allKeys.count) {
        _card[@"cashin"] = self.cashinData;
    }

    [[Flooz sharedInstance] showLoadView];
    [mangopayClient appendCardInfo:paymentTextField.cardNumber cardExpirationDate:[NSString stringWithFormat:@"%02lu%02lu", (unsigned long)paymentTextField.expirationMonth, (unsigned long)paymentTextField.expirationYear] cardCvx:paymentTextField.cvc];
    
    [mangopayClient registerCard:^(NSDictionary *response, NSError *error) {
        if (error)
            NSLog(@"Error: %@", error);
        else {
            [[Flooz sharedInstance] updateUser:@{@"pspCardId": response[@"CardId"]} success:^(id result) {
                [self reloadView];
            } failure:nil];
        }
    }];
}

- (void)didRemoveCardTouch {
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] removeCreditCard:^(id result) {
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
