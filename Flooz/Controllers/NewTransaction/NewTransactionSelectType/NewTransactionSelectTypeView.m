//
//  NewTransactionSelectTypeView.m
//  Flooz
//
//  Created by jonathan on 2014-03-17.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "NewTransactionSelectTypeView.h"

@implementation NewTransactionSelectTypeView

- (id)initWithFrame:(CGRect)frame for:(NSMutableDictionary *)dictionary
{
    self = [super initWithFrame:CGRectMake(0, frame.origin.y, SCREEN_WIDTH, 42)];
    if (self) {
        _dictionary = dictionary;
        
        [self createSeparator];
        [self createButtons];
        
        if([[_dictionary objectForKey:@"method"] isEqualToString:[FLTransaction transactionTypeToParams:TransactionTypePayment]]){
            [self didButtonLeftTouch];
        }
        else{
            [self didButtonRightTouch];
        }
    }
    return self;
}

- (void)createSeparator
{
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), 1)];
    bottomBar.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:bottomBar];
}

- (void)createButtons
{
    buttonLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))];
    buttonRight = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(buttonLeft.frame), 0, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))];
    
    [buttonLeft setBackgroundImage:[UIImage imageWithColor:[UIColor customBackgroundStatus]] forState:UIControlStateSelected];
    [buttonRight setBackgroundImage:[UIImage imageWithColor:[UIColor customBackgroundStatus]] forState:UIControlStateSelected];
    
    buttonLeft.titleLabel.font = buttonRight.titleLabel.font = [UIFont customContentRegular:13];

    [buttonLeft setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
    [buttonRight setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
    [buttonLeft setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [buttonRight setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [buttonLeft setTitle:NSLocalizedString(@"MENU_NEW_TRANSACTION_PAYMENT", nil) forState:UIControlStateNormal];
    [buttonRight setTitle:NSLocalizedString(@"MENU_NEW_TRANSACTION_COLLECT", nil) forState:UIControlStateNormal];
    
    [buttonLeft addTarget:self action:@selector(didButtonLeftTouch) forControlEvents:UIControlEventTouchUpInside];
    [buttonRight addTarget:self action:@selector(didButtonRightTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:buttonLeft];
    [self addSubview:buttonRight];
}

- (void)didButtonLeftTouch
{
    if(buttonLeft.selected){
        return;
    }
    
    buttonLeft.selected = YES;
    buttonRight.selected = NO;

    [_dictionary setValue:[FLTransaction transactionTypeToParams:TransactionTypePayment] forKey:@"method"];
    [_delegate didTypePaymentelected];
}

- (void)didButtonRightTouch
{
    if(buttonRight.selected){
        return;
    }
    
    buttonLeft.selected = NO;
    buttonRight.selected = YES;
    
    [_dictionary setValue:[FLTransaction transactionTypeToParams:TransactionTypeCollection] forKey:@"method"];
    [_delegate didTypeCollectSelected];
}

@end
