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
#import "CardIO.h"
#import "FLCreditCardScanner.h"

#define PADDING_SIDE 20.0f

@interface CashinCreditCardViewController () {
    UIScrollView *contentView;
    
    FLActionButton *deleteCardButtton;
    UIImageView *cardBackground;
    UILabel *cardNumber;
    UILabel *cardOwner;
    UILabel *cardExpire;
    
    NSMutableDictionary *dictionary;
    
    UILabel *inputHint;
    FLTextField *holderTextField;
    UIImageView *scanCardButton;
    STPPaymentCardTextField *paymentTextField;
    
    UILabel *amountHint;
    
    NSInteger selectedAmount;
    UIView *amountCheckboxView;
    NSMutableArray *amountChecboxes;
    
    FLTextField *amountTextField;
    FLActionButton *sendButton;
    
    UIView *saveCardButton;
    UIImageView *saveCardImageView;
    UILabel *saveCardLabel;
    
    UIImageView *cardsLogo;
    UILabel *cardsInfos;
    
    Boolean saveCard;
    
    FLCreditCardScanner *scanner;
}

@end

@implementation CashinCreditCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    saveCard = NO;
    selectedAmount = -1;
    
    dictionary = [NSMutableDictionary new];
    
    dictionary[@"random"] = [FLHelper generateRandomString];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"NAV_CASHIN", nil);
    
    contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    contentView.bounces = NO;
    
    inputHint = [[UILabel alloc] initWithText:NSLocalizedString(@"CASHIN_CARD_PAYMENT_INPUT_HINT", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15]];
    CGRectSetXY(inputHint.frame, PADDING_SIDE, 20);
    
    holderTextField = [[FLTextField alloc] initWithPlaceholder:@"Nom du titulaire" for:dictionary key:@"holder" frame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(inputHint.frame) + 5, PPScreenWidth() - (2 * PADDING_SIDE), 30)];
    holderTextField.floatLabelActiveColor = [UIColor clearColor];
    holderTextField.floatLabelPassiveColor = [UIColor clearColor];
    [holderTextField setType:FLTextFieldTypeText];
    
    paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(inputHint.frame) + 5, PPScreenWidth() - (2 * PADDING_SIDE), 40)];
    paymentTextField.delegate = self;
    [paymentTextField setTextColor:[UIColor whiteColor]];
    [paymentTextField setFont:[UIFont customContentRegular:16]];
    [paymentTextField setPlaceholderColor:[UIColor customPlaceholder]];
    [paymentTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [paymentTextField setBorderColor:[UIColor clearColor]];
    [paymentTextField setNumberPlaceholder:@"•••• •••• •••• ••••"];
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
    
    if ([CardIOUtilities canReadCardWithCamera]) {
        CGRectSetWidth(paymentTextField.frame, PPScreenWidth() - (2 * PADDING_SIDE) - 30);
        [scanCardButton setHidden:NO];
    }
    
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
    
    amountHint = [[UILabel alloc] initWithText:NSLocalizedString(@"CASHIN_CARD_AMOUNT_INPUT_HINT", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15]];
    CGRectSetXY(amountHint.frame, PADDING_SIDE, 20);
    
    amountCheckboxView = [[UIView alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(amountHint.frame) + 5, PPScreenWidth() - PADDING_SIDE * 2, 30)];
    
    NSArray *buttonsTitles = @[@"20€", @"50€", @"100€", @"Autre"];
    
    CGFloat xOffset = 0.0f;
    CGFloat margin = 7.0f;
    CGFloat buttonWidth = (CGRectGetWidth(amountCheckboxView.frame) - (buttonsTitles.count - 1) * margin) / buttonsTitles.count;
    
    for (NSString *title in buttonsTitles) {
        UILabel *button = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, 0, buttonWidth, 35)];
        button.text = title;
        button.textColor = [UIColor customBlue];
        button.font = [UIFont customContentBold:14];
        button.textAlignment = NSTextAlignmentCenter;
        button.layer.cornerRadius = 4.;
        button.layer.masksToBounds = YES;
        button.layer.borderColor = [UIColor customBlue].CGColor;
        button.layer.borderWidth = 1.;
        button.userInteractionEnabled = YES;
        [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didAmountCheckboxClicked:)]];
        
        [amountCheckboxView addSubview:button];
        
        xOffset += buttonWidth + margin;
    }
    
    amountTextField = [[FLTextField alloc] initWithPlaceholder:@"0€" for:dictionary key:@"amount" frame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(amountHint.frame) + 5, PPScreenWidth() - 2 * PADDING_SIDE, 35)];
    amountTextField.floatLabelActiveColor = [UIColor clearColor];
    amountTextField.floatLabelPassiveColor = [UIColor clearColor];
    [amountTextField setType:FLTextFieldTypeFloatNumber];
    [amountTextField addForNextClickTarget:amountTextField action:@selector(resignFirstResponder)];
    amountTextField.hidden = YES;
    [amountTextField setType:FLTextFieldTypeFloatNumber];
    
    sendButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE * 2, CGRectGetMinY(amountCheckboxView.frame) + 5, PPScreenWidth() - PADDING_SIDE * 4, 35) title:NSLocalizedString(@"GLOBAL_VALIDATE", nil)];
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
    
    if ([Flooz sharedInstance].currentTexts.card && ![[Flooz sharedInstance].currentTexts.card isBlank])
        [cardsInfos setText:[Flooz sharedInstance].currentTexts.card];
    
    [cardsInfos setHeightToFit];
    
    [self createCardVisualView];
    
    [contentView addSubview:amountCheckboxView];
    [contentView addSubview:inputHint];
    [contentView addSubview:amountHint];
    [contentView addSubview:scanCardButton];
    [contentView addSubview:amountTextField];
    [contentView addSubview:holderTextField];
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
    [super viewWillAppear:animated];
    [self reloadView];
    [CardIOUtilities preload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
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
        [scanCardButton setHidden:YES];
        [saveCardButton setHidden:YES];
        
        [cardBackground setHidden:NO];
        [deleteCardButtton setHidden:NO];
        
        cardNumber.text = [NSString stringWithFormat:@"**** **** **** %@", [creditCard.number substringFromIndex:creditCard.number.length - 4]];
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
        
        [scanCardButton setHidden:YES];

        CGRectSetWidth(paymentTextField.frame, PPScreenWidth() - (2 * PADDING_SIDE));
        
        if ([CardIOUtilities canReadCardWithCamera]) {
            CGRectSetWidth(paymentTextField.frame, PPScreenWidth() - (2 * PADDING_SIDE) - 30);
            [scanCardButton setHidden:NO];
        }
        
        [paymentTextField setHidden:NO];
        [saveCardButton setHidden:NO];
        
        if (saveCard)
            [saveCardImageView setImage:[UIImage imageNamed:@"checkmark-on"]];
        else
            [saveCardImageView setImage:[UIImage imageNamed:@"checkmark-off"]];
        
        CGRectSetY(amountHint.frame, CGRectGetMaxY(saveCardButton.frame) + 20);
    }
    
    CGRectSetY(amountCheckboxView.frame, CGRectGetMaxY(amountHint.frame) + 10);
    
    int i = 0;
    for (UILabel *label in amountCheckboxView.subviews) {
        if (selectedAmount == i) {
            label.backgroundColor = [UIColor customBlue];
            label.textColor = [UIColor whiteColor];
        } else {
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor customBlue];
        }
        ++i;
    }
    
    if (selectedAmount == 3) {
        amountTextField.hidden = NO;
        CGRectSetY(amountTextField.frame, CGRectGetMaxY(amountCheckboxView.frame) + 10);
        CGRectSetY(sendButton.frame, CGRectGetMaxY(amountTextField.frame) + 10);
        CGRectSetY(cardsLogo.frame, CGRectGetMaxY(sendButton.frame) + 10);
        CGRectSetY(cardsInfos.frame, CGRectGetMaxY(cardsLogo.frame) + 7);
        
        contentView.contentSize = CGSizeMake(PPScreenWidth(), CGRectGetMaxY(cardsInfos.frame) + 10);
    } else {
        amountTextField.hidden = YES;
        CGRectSetY(sendButton.frame, CGRectGetMaxY(amountCheckboxView.frame) + 20);
        CGRectSetY(cardsLogo.frame, CGRectGetMaxY(sendButton.frame) + 10);
        CGRectSetY(cardsInfos.frame, CGRectGetMaxY(cardsLogo.frame) + 7);
        
        contentView.contentSize = CGSizeMake(PPScreenWidth(), CGRectGetMaxY(cardsInfos.frame) + 10);
    }
}

- (void)didAmountCheckboxClicked:(UITapGestureRecognizer *)sender {
    NSInteger pos = [amountCheckboxView.subviews indexOfObject:sender.view];
    
    if (pos != NSNotFound) {
        selectedAmount = pos;
    } else {
        selectedAmount = -1;
    }
    
    [self reloadView];
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

- (void)scanButtonClick {
    [self.view endEditing:YES];
    [self.view endEditing:NO];
    
    scanner = nil;
    scanner = [[FLCreditCardScanner alloc] initWithDelegate:self];
    [scanner show];
}

- (void)sendButtonClick {
    [self.view endEditing:YES];
    [self.view endEditing:NO];
    
    [[Flooz sharedInstance] showLoadView];
    
    NSMutableDictionary *data = [NSMutableDictionary new];
    
    if (selectedAmount == 3) {
        [data setDictionary:dictionary];
    } else if (selectedAmount >= 0) {
        switch (selectedAmount) {
            case 0:
                data[@"amount"] = @"20";
                break;
            case 1:
                data[@"amount"] = @"50";
                break;
            case 2:
                data[@"amount"] = @"100";
                break;
            default:
                break;
        }
    }
    
    [data removeObjectForKey:@"holder"];
    
    if ([[[Flooz sharedInstance] currentUser] creditCard]) {
        [data setObject:@{@"_id": [[[[Flooz sharedInstance] currentUser] creditCard] cardId]} forKey:@"card"];
    } else {
        NSMutableDictionary *card = [NSMutableDictionary new];
        
        if (dictionary[@"holder"] && [[[Flooz sharedInstance] currentTexts] cardHolder]) {
            card[@"holder"] = dictionary[@"holder"];
        }
        
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
