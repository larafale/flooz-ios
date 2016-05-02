//
//  CashinCreditCardViewController.m
//  Flooz
//
//  Created by Olive on 4/14/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLActionButton.h"
#import "FLTextField.h"
#import "CashinCreditCardViewController.h"

#define PADDING_SIDE 20.0f

@interface CashinCreditCardViewController () {
    UIScrollView *contentView;
    
    FLActionButton *deleteCardButtton;
    UIImageView *cardBackground;
    UILabel *cardNumber;
    UILabel *cardOwner;
    UILabel *cardExpire;
    
    NSMutableDictionary *dictionary;
    FLKeyboardView *inputView;
    
    UILabel *inputHint;
    STPPaymentCardTextField *paymentTextField;
    
    UILabel *amountHint;
    FLTextField *amountTextField;
    FLActionButton *sendButton;
    
    UIView *saveCardButton;
    UIImageView *saveCardImageView;
    UILabel *saveCardLabel;
    
    UIImageView *cardsLogo;
    UILabel *cardsInfos;
    
    Boolean saveCard;
}

@end

@implementation CashinCreditCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    saveCard = NO;
    
    dictionary = [NSMutableDictionary new];
    
    dictionary[@"random"] = [FLHelper generateRandomString];

    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"NAV_CASHIN", nil);
    
    contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    contentView.bounces = NO;
    
    inputHint = [[UILabel alloc] initWithText:NSLocalizedString(@"CASHIN_CARD_PAYMENT_INPUT_HINT", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15]];
    CGRectSetXY(inputHint.frame, PADDING_SIDE, 20);
    
    paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(inputHint.frame) + 5, PPScreenWidth() - (2 * PADDING_SIDE), 40)];
    paymentTextField.delegate = self;
    [paymentTextField setTextColor:[UIColor whiteColor]];
    [paymentTextField setFont:[UIFont customContentRegular:16]];
    [paymentTextField setPlaceholderColor:[UIColor customPlaceholder]];
    [paymentTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [paymentTextField setBorderColor:[UIColor clearColor]];
    [paymentTextField setNumberPlaceholder:@"•••• •••• •••• ••••"];
    [paymentTextField setTextErrorColor:[UIColor customRed]];
    paymentTextField.layer.borderColor = [UIColor customPlaceholder].CGColor;
    paymentTextField.layer.borderWidth = 1.0f;
    paymentTextField.layer.cornerRadius = 5.0f;
    
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
    
    amountHint = [[UILabel alloc] initWithText:NSLocalizedString(@"CASHIN_CARD_AMOUNT_INPUT_HINT", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15]];
    CGRectSetXY(amountHint.frame, PADDING_SIDE, 20);
    
    amountTextField = [[FLTextField alloc] initWithPlaceholder:@"0€" for:dictionary key:@"amount" frame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(amountHint.frame) + 5, PPScreenWidth() / 2 - 1.5 * PADDING_SIDE, 35)];
    amountTextField.floatLabelActiveColor = [UIColor clearColor];
    amountTextField.floatLabelPassiveColor = [UIColor clearColor];
    [amountTextField setType:FLTextFieldTypeFloatNumber];
    [amountTextField addForNextClickTarget:amountTextField action:@selector(resignFirstResponder)];
    
    inputView = [FLKeyboardView new];
    [inputView setKeyboardDecimal];
    inputView.textField = amountTextField;
    amountTextField.inputView = inputView;
    
    sendButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PPScreenWidth() / 2 + PADDING_SIDE / 2, CGRectGetMinY(amountTextField.frame), PPScreenWidth() / 2 - PADDING_SIDE * 1.5, 35) title:NSLocalizedString(@"GLOBAL_VALIDATE", nil)];
    [sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    cardsLogo = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(sendButton.frame) + 10, PPScreenWidth() - (2 * PADDING_SIDE), 80)];
    [cardsLogo setImage:[UIImage imageNamed:@"cards"]];
    [cardsLogo setContentMode:UIViewContentModeScaleAspectFit];
    
    cardsInfos = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(cardsLogo.frame) + 10, PPScreenWidth() - 2  * PADDING_SIDE, 0)];
    cardsInfos.textColor = [UIColor customPlaceholder];
    cardsInfos.textAlignment = NSTextAlignmentCenter;
    cardsInfos.font = [UIFont customContentRegular:14];
    cardsInfos.text = NSLocalizedString(@"CASHIN_CARD_INFOS", nil);
    cardsInfos.adjustsFontSizeToFitWidth = YES;
    cardsInfos.numberOfLines = 0;
    cardsInfos.minimumScaleFactor = 10. / saveCardLabel.font.pointSize;
    cardsInfos.lineBreakMode = NSLineBreakByWordWrapping;
    
    [cardsInfos setHeightToFit];
    
    [self createCardVisualView];
    
    [contentView addSubview:inputHint];
    [contentView addSubview:amountHint];
    [contentView addSubview:amountTextField];
    [contentView addSubview:paymentTextField];
    [contentView addSubview:amountTextField];
    [contentView addSubview:sendButton];
    [contentView addSubview:saveCardButton];
    [contentView addSubview:cardsLogo];
    [contentView addSubview:cardsInfos];
    
    [_mainBody addSubview:contentView];
    
    [self reloadView];
    
    [self registerForKeyboardNotifications];
    
    [self registerNotification:@selector(reloadView) name:kNotificationReloadCurrentUser object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_mainBody endEditing:YES];
}

- (void)createCardVisualView {
    
    cardBackground = [UIImageView imageNamed:@"card-background"];
    
    CGFloat scaleRatio = CGRectGetHeight(cardBackground.frame) / CGRectGetWidth(cardBackground.frame);
    
    [cardBackground setFrame:CGRectMake(PADDING_SIDE, 20, PPScreenWidth() - PADDING_SIDE * 2, (PPScreenWidth() - PADDING_SIDE * 2) * scaleRatio)];
    [cardBackground setContentMode:UIViewContentModeScaleToFill];
    
    cardNumber = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, CGRectGetHeight(cardBackground.frame) / 2.0f - 10.0f, CGRectGetWidth(cardBackground.frame) - 20.0f*2, 30)];
    
    cardNumber.textColor = [UIColor whiteColor];
    cardNumber.font = [UIFont customCreditCard:22];
    cardNumber.adjustsFontSizeToFitWidth = YES;
    cardNumber.minimumScaleFactor = 15. / cardNumber.font.pointSize;
    
    [cardBackground addSubview:cardNumber];
    
    cardOwner = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(cardNumber.frame), CGRectGetMaxY(cardNumber.frame) + 20.0f, CGRectGetWidth(cardNumber.frame), 30)];
    cardOwner.textColor = [UIColor whiteColor];
    cardOwner.font = [UIFont customCreditCard:12];
    
    [cardBackground addSubview:cardOwner];
    
    cardExpire = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(cardNumber.frame), CGRectGetMaxY(cardNumber.frame) + 20.0f, CGRectGetWidth(cardNumber.frame), 30)];
    cardExpire.textColor = [UIColor whiteColor];
    
    cardExpire.font = [UIFont customCreditCard:12];
    
    [cardBackground addSubview:cardExpire];
    
    deleteCardButtton = [[FLActionButton alloc] initWithFrame:CGRectMake(PPScreenWidth() - PADDING_SIDE - 20, 10, 30, 30)];
    [deleteCardButtton setBackgroundColor:[UIColor customRed] forState:UIControlStateNormal];
    [deleteCardButtton setBackgroundColor:[UIColor customRed:0.5] forState:UIControlStateHighlighted];
    [deleteCardButtton setImage:[UIImage imageNamed:@"trash"] size:CGSizeMake(17, 17)];
    [deleteCardButtton centerImage];
    [deleteCardButtton addTarget:self action:@selector(didDeleteCardButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:cardBackground];
    [contentView addSubview:deleteCardButtton];
}

- (void)reloadView {
    if ([[[Flooz sharedInstance] currentUser] creditCard]) {
        FLCreditCard *creditCard = [[[Flooz sharedInstance] currentUser] creditCard];
        
        [inputHint setHidden:YES];
        [paymentTextField setHidden:YES];
        [saveCardButton setHidden:YES];
        
        [cardBackground setHidden:NO];
        [deleteCardButtton setHidden:NO];
        
        cardNumber.text = [NSString stringWithFormat:@"%@ **** **** %@", [creditCard.number substringToIndex:4], [creditCard.number substringFromIndex:creditCard.number.length - 4]];
        cardOwner.text = [creditCard.owner uppercaseString];
        [cardOwner setWidthToFit];
        
        cardExpire.text = [creditCard.expires uppercaseString];
        [cardExpire setWidthToFit];
        
        CGRectSetX(cardExpire.frame, CGRectGetWidth(cardBackground.frame) - CGRectGetWidth(cardExpire.frame) - 20.0f);
        
        CGRectSetY(amountHint.frame, CGRectGetMaxY(cardBackground.frame) + 20);
    } else {
        [cardBackground setHidden:YES];
        [deleteCardButtton setHidden:YES];
        
        [inputHint setHidden:NO];
        [paymentTextField setHidden:NO];
        [saveCardButton setHidden:NO];
        
        if (saveCard)
            [saveCardImageView setImage:[UIImage imageNamed:@"checkmark-on"]];
        else
            [saveCardImageView setImage:[UIImage imageNamed:@"checkmark-off"]];
        
        CGRectSetY(amountHint.frame, CGRectGetMaxY(saveCardButton.frame) + 20);
    }
    
    CGRectSetY(amountTextField.frame, CGRectGetMaxY(amountHint.frame));
    CGRectSetY(sendButton.frame, CGRectGetMaxY(amountHint.frame));
    CGRectSetY(cardsLogo.frame, CGRectGetMaxY(sendButton.frame) + 10);
    CGRectSetY(cardsInfos.frame, CGRectGetMaxY(cardsLogo.frame) + 5);
    
    contentView.contentSize = CGSizeMake(PPScreenWidth(), CGRectGetMaxY(cardsInfos.frame) + 10);
}

- (void)didSaveCardButtonClick {
    saveCard = !saveCard;
    [self reloadView];
}

- (void)didDeleteCardButtonClick {
    NSString *creditCardId = [[[[Flooz sharedInstance] currentUser] creditCard] cardId];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] removeCreditCard:creditCardId success: ^(id result) {

    }];
}

- (void)sendButtonClick {
    [self.view endEditing:YES];
    [self.view endEditing:NO];
    
    [[Flooz sharedInstance] showLoadView];
    
    NSMutableDictionary *data = [NSMutableDictionary new];
    
    [data setDictionary:dictionary];
    
    if ([[[Flooz sharedInstance] currentUser] creditCard]) {
        [data setObject:@{@"_id": [[[[Flooz sharedInstance] currentUser] creditCard] cardId]} forKey:@"card"];
    } else {
        NSMutableDictionary *card = [NSMutableDictionary new];
        
        if (paymentTextField.cardNumber && ![paymentTextField.cardNumber isBlank])
            card[@"number"] = paymentTextField.cardNumber;
        
        if (paymentTextField.cvc && ![paymentTextField.cvc isBlank])
            card[@"cvv"] = paymentTextField.cvc;
        
        if (paymentTextField.expirationMonth != 0 && paymentTextField.expirationYear != 0)
            card[@"expires"] = [NSString stringWithFormat:@"%02lu-%02lu", (unsigned long)paymentTextField.expirationMonth, (unsigned long)paymentTextField.expirationYear];
        
        card[@"hidden"] = @(!saveCard);
        
        [data setObject:card forKey:@"card"];
    }
    
    [[Flooz sharedInstance] cashinCard:data success:nil failure:nil];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRectSetHeight(contentView.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight + PPScreenWidth());
}

- (void)keyboardWillDisappear {
    CGRectSetHeight(contentView.frame, CGRectGetHeight(_mainBody.frame));
}

@end
