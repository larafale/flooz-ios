//
//  FLPaymentField.m
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLPaymentField.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@implementation FLPaymentField

- (id)initWithFrame:(CGRect)frame for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey
{
    self = [super initWithFrame:CGRectMake(0, frame.origin.y, frame.size.width, [[self class] height])];
    if (self) {
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        
        self.clipsToBounds = YES;
        
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
    
    [leftButton setBackgroundImage:[UIImage imageWithColor:[UIColor customBackgroundStatus]] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageWithColor:[UIColor customBackgroundStatus]] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateSelected];
    [rightButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateSelected];
    
    [leftButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    leftButton.imageEdgeInsets = rightButton.imageEdgeInsets = UIEdgeInsetsMake(- 60, 0, 0, 0);
    
    [leftButton addTarget:self action:@selector(didWalletTouch) forControlEvents:UIControlEventTouchUpInside];
    [rightButton addTarget:self action:@selector(didCardTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:leftButton];
    [self addSubview:rightButton];
    
    {
        leftText = [[UILabel alloc] initWithFrame:CGRectMakeWithSize(leftButton.frame.size)];
        rightText = [[UILabel alloc] initWithFrame:CGRectMakeWithSize(rightButton.frame.size)];
        
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
        amount.font = [UIFont customContentRegular:10];
        amount.layer.cornerRadius = 10.;
        
        amount.text = [FLHelper formatedAmount:[[[Flooz sharedInstance] currentUser] amount]];
        
        [leftButton addSubview:amount];
    }
    
    amount.textColor = leftText.textColor = [leftButton titleColorForState:UIControlStateNormal];
    rightText.textColor = [rightButton titleColorForState:UIControlStateNormal];
}

- (void)createBottomBar
{
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
    topBar.backgroundColor = [UIColor customSeparator:0.5];
    
    [self addSubview:topBar];
    
    {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, CGRectGetHeight(self.frame))];
        separator.backgroundColor = [UIColor customSeparator];
        
        [self addSubview:separator];
    }
    
    {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 1, 0, 1, CGRectGetHeight(self.frame))];
        separator.backgroundColor = [UIColor customSeparator];
        
        [self addSubview:separator];
    }
    
    {
        UIView *square = [[UIView alloc] initWithFrame:CGRectMakeSize(14, 14)];
        
        square.backgroundColor = [UIColor customBackgroundStatus];
        
        square.transform = CGAffineTransformMakeRotation(RADIANS(45));
        
        square.center = CGRectGetFrameCenter(self.frame);
        
        [self addSubview:square];
    }
}

- (void)setStyleLight
{
    self.backgroundColor = [UIColor customBackgroundHeader];
}

- (void)didWalletTouch
{
    if(_dictionary){
        [_dictionary setValue:[FLTransaction transactionPaymentMethodToParams:TransactionPaymentMethodWallet] forKey:_dictionaryKey];
    }
    
    if(leftButton.selected){
        return;
    }
    
    leftButton.selected = YES;
    rightButton.selected = NO;
    
    amount.textColor = leftText.textColor = [leftButton titleColorForState:UIControlStateSelected];
    rightText.textColor = [rightButton titleColorForState:UIControlStateNormal];
    
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
    
    leftButton.selected = NO;
    rightButton.selected = YES;
    
    amount.textColor = leftText.textColor = [leftButton titleColorForState:UIControlStateNormal];
    rightText.textColor = [rightButton titleColorForState:UIControlStateSelected];
    
    if(_dictionary){
        [_dictionary setValue:[FLTransaction transactionPaymentMethodToParams:TransactionPaymentMethodCreditCard] forKey:_dictionaryKey];
    }
    
    [_delegate didCreditCardSelected];
}

- (void)reloadUser
{
    amount.text = [FLHelper formatedAmount:[[[Flooz sharedInstance] currentUser] amount]];
}

@end
