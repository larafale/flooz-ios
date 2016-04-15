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
    NSMutableDictionary *dictionary;
    FLKeyboardView *inputView;

    STPPaymentCardTextField *paymentTextField;
    FLTextField *amountTextField;
    FLActionButton *sendButton;
}

@end

@implementation CashinCreditCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dictionary = [NSMutableDictionary new];

    if (!self.title || [self.title isBlank])
        self.title = @"Charger par carte bancaire";
    
    paymentTextField = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(PADDING_SIDE, 25, PPScreenWidth() - (2 * PADDING_SIDE), 40)];
    paymentTextField.delegate = self;
    [paymentTextField setTextColor:[UIColor whiteColor]];
    [paymentTextField setFont:[UIFont customContentRegular:16]];
    [paymentTextField setPlaceholderColor:[UIColor customPlaceholder]];
    [paymentTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [paymentTextField setBorderColor:[UIColor clearColor]];
    [paymentTextField setNumberPlaceholder:@"•••• •••• •••• ••••"];
    [paymentTextField setTextErrorColor:[UIColor customRed]];
    
    amountTextField = [[FLTextField alloc] initWithPlaceholder:NSLocalizedString(@"CASHOUT_FIELD", nil) for:dictionary key:@"amount" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(paymentTextField.frame) + 10)];
    [amountTextField addForNextClickTarget:amountTextField action:@selector(resignFirstResponder)];
    
    inputView = [FLKeyboardView new];
    [inputView setKeyboardDecimal];
    inputView.textField = amountTextField;
    amountTextField.inputView = inputView;
    
    sendButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(amountTextField.frame) + 15, PPScreenWidth() - PADDING_SIDE * 2, 35) title:NSLocalizedString(@"GLOBAL_OK", nil)];
    [sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_mainBody addSubview:paymentTextField];
    [_mainBody addSubview:amountTextField];
    [_mainBody addSubview:sendButton];
}

- (void)sendButtonClick {
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] cashinValidate:dictionary success:nil failure:nil];
}

@end
