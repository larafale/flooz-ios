//
//  FLPaymentField.m
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLPaymentField.h"

@implementation FLPaymentField

- (id)initWithFrame:(CGRect)frame for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey
{
    self = [super initWithFrame:CGRectMake(0, frame.origin.y, frame.size.width, [[self class] height])];
    if (self) {
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        
        self.clipsToBounds = YES;
        
        [self createSeparators];
        [self createButtons];
        [self createBottomBar];
    }
    return self;
}

+ (CGFloat)height
{
    return 122;
}

- (void)createButtons
{
    leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame))];
    rightButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., 0, CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame))];
    
    [leftButton setImage:[UIImage imageNamed:@"payment-field-wallet"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"payment-field-wallet-selected"] forState:UIControlStateSelected];
    [rightButton setImage:[UIImage imageNamed:@"payment-field-card"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"payment-field-card-selected"] forState:UIControlStateSelected];
    
    leftButton.imageEdgeInsets = rightButton.imageEdgeInsets = UIEdgeInsetsMake(- 60, 0, 0, 0);
    
    [leftButton addTarget:self action:@selector(didWalletTouch) forControlEvents:UIControlEventTouchUpInside];
    [rightButton addTarget:self action:@selector(didCardTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:leftButton];
    [self addSubview:rightButton];
    
    {
        leftText = [[UILabel alloc] initWithFrame:CGRectMakeWithSize(leftButton.frame.size)];
        rightText = [[UILabel alloc] initWithFrame:CGRectMakeWithSize(rightButton.frame.size)];
        
        leftText.textColor = rightText.textColor = [UIColor whiteColor];
        leftText.textAlignment = rightText.textAlignment = NSTextAlignmentCenter;
        leftText.font = rightText.font = [UIFont customTitleExtraLight:14];
        
        leftText.text = NSLocalizedString(@"PAYEMENT_FIELD_WALLET", nil);
        rightText.text = NSLocalizedString(@"PAYEMENT_FIELD_CARD", nil);
        
        [leftButton addSubview:leftText];
        [rightButton addSubview:rightText];
    }
    
    {
        CGFloat width = 60;
        CGFloat x = (CGRectGetWidth(leftButton.frame) - width) / 2.;
        amount = [[UILabel alloc] initWithFrame:CGRectMake(x, 79, width, 19)];
        
        amount.textAlignment = NSTextAlignmentCenter;
        amount.backgroundColor = [UIColor colorWithIntegerRed:45 green:58 blue:70];
        amount.textColor = [UIColor whiteColor];
        amount.font = [UIFont customContentRegular:10];
        amount.layer.cornerRadius = 10.;
        
        amount.text = [FLHelper formatedAmount:[[[Flooz sharedInstance] currentUser] amount]];
        
        [leftButton addSubview:amount];
    }
}

- (void)createBottomBar
{
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
    topBar.backgroundColor = [UIColor customSeparator:0.5];
    
    [self addSubview:topBar];
}

- (void)createSeparators
{
    CGFloat MARGE = 19;
    CGFloat HEIGHT = 30.;
    
    UIView *separator1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., MARGE, 1, HEIGHT)];
    UIView *separator2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame) - HEIGHT - MARGE, 1, HEIGHT)];
    
    separator1.backgroundColor = separator2.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:separator1];
    [self addSubview:separator2];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2. - 25, MARGE + HEIGHT, 50, CGRectGetHeight(self.frame) - 2 * (MARGE + HEIGHT))];
    
    text.textAlignment = NSTextAlignmentCenter;
    text.textColor = [UIColor customBlueLight];
    text.font = [UIFont customContentRegular:10];
    text.text = NSLocalizedString(@"GLOBAL_OR", nil);
    
    [self addSubview:text];
}

- (void)setStyleLight
{
    self.backgroundColor = [UIColor customBackgroundHeader];
}

- (void)didWalletTouch
{
    if(leftButton.selected){
        return;
    }
    
    amount.textColor = leftText.textColor = [UIColor customBlue];
    rightText.textColor = [UIColor whiteColor];
    
    leftButton.selected = YES;
    rightButton.selected = NO;
    
    if(_dictionary){
        [_dictionary setValue:[FLTransaction transactionPaymentMethodToParams:TransactionPaymentMethodWallet] forKey:_dictionaryKey];    
    }
    
    [_delegate didWalletSelected];
}

- (void)didCardTouch
{
    if(rightButton.selected){
        return;
    }
    
    if(![[[Flooz sharedInstance] currentUser] creditCard]){
        [_delegate presentCreditCardController];
        return;
    }
    
    
    amount.textColor = leftText.textColor = [UIColor whiteColor];
    rightText.textColor = [UIColor customBlue];
    
    leftButton.selected = NO;
    rightButton.selected = YES;
    
    if(_dictionary){
        [_dictionary setValue:[FLTransaction transactionPaymentMethodToParams:TransactionPaymentMethodCreditCard] forKey:_dictionaryKey];
    }
    
    [_delegate didCreditCardSelected];
}

@end
