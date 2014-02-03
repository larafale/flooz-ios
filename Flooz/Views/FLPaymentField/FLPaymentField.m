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
    self = [super initWithFrame:CGRectMake(0, frame.origin.y, SCREEN_WIDTH, 122)];
    if (self) {
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        
        [self didWalletTouch];
        
        [self createSeparators];
        [self createButtons];
    }
    return self;
}

- (void)createButtons
{
    CGFloat space = 15.;
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame))];
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., 0, CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame))];
    
    [leftButton setImage:[UIImage imageNamed:@"payment-field-wallet"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"payment-field-card"] forState:UIControlStateNormal];
    
    leftButton.imageEdgeInsets = rightButton.imageEdgeInsets = UIEdgeInsetsMake(- space, 0, 0, 0);
    
    [leftButton addTarget:self action:@selector(didWalletTouch) forControlEvents:UIControlEventTouchUpInside];
    [rightButton addTarget:self action:@selector(didCardTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:leftButton];
    [self addSubview:rightButton];
    
    {
        UILabel *leftText = [[UILabel alloc] initWithFrame:CGRectMakeWithSize(leftButton.frame.size)];
        UILabel *rightText = [[UILabel alloc] initWithFrame:CGRectMakeWithSize(rightButton.frame.size)];
        
        leftText.textColor = rightText.textColor = [UIColor whiteColor];
        leftText.textAlignment = rightText.textAlignment = NSTextAlignmentCenter;
        leftText.font = rightText.font = [UIFont customTitleExtraLight:14];
        
        leftText.text = NSLocalizedString(@"PAYEMENT_FIELD_WALLET", nil);
        rightText.text = NSLocalizedString(@"PAYEMENT_FIELD_CARD", nil);
        
        leftText.frame = CGRectSetY(leftText.frame, space);
        rightText.frame = CGRectSetY(rightText.frame, space);
        
        [leftButton addSubview:leftText];
        [rightButton addSubview:rightText];
    }
    
    {
        CGFloat width = 60;
        CGFloat x = (CGRectGetWidth(leftButton.frame) - width) / 2.;
        UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(x, 89, width, 19)];
        
        amount.textAlignment = NSTextAlignmentCenter;
        amount.backgroundColor = [UIColor colorWithIntegerRed:45 green:58 blue:70];
        amount.textColor = [UIColor whiteColor];
        amount.font = [UIFont customContentRegular:10];
        amount.layer.cornerRadius = 10.;
        
        amount.text = [FLHelper formatedAmount:[[[Flooz sharedInstance] currentUser] amount]];
        
        [leftButton addSubview:amount];
    }
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
    [_dictionary setValue:@"balance" forKey:_dictionaryKey];
}

- (void)didCardTouch
{
    [_dictionary setValue:@"card" forKey:_dictionaryKey];
}

@end
