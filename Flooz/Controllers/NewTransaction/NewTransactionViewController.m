//
//  NewTransactionViewController.m
//  Flooz
//
//  Created by jonathan on 1/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "NewTransactionViewController.h"

#import "FLNewTransactionAmount.h"
#import "FLPaymentField.h"
#import "FLNewTransactionBar.h"
#import "FLSelectAmount.h"
#import "FLSelectFriendButton.h"

@interface NewTransactionViewController (){
    NSMutableDictionary *transaction;
    
    FLValidNavBar *navBar;
    UIScrollView *_contentView;
    
    FLNewTransactionBar *transactionBar;
    
    TransactionType _transactionType;
    FLNewTransactionAmount *amountInput;
    FLTextView *content;
}

@end

@implementation NewTransactionViewController

- (id)initWithTransactionType:(TransactionType)transactionType;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        transaction = [NSMutableDictionary new];
        
        _transactionType = transactionType;
        [transaction setValue:[FLTransaction TransactionTypeToParams:transactionType] forKey:@"method"];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor customBackground];
    
    {
        navBar = [FLValidNavBar new];
        [self.view addSubview:navBar];
        
        [navBar cancelAddTarget:self action:@selector(dismiss)];
        [navBar validAddTarget:self action:@selector(valid)];
    }
    
    {
        _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        [self.view addSubview:_contentView];
    }
    
    {
        CGFloat offset = 0;
        
        if(_transactionType == TransactionTypeEvent){
            FLTextFieldTitle *title = [[FLTextFieldTitle alloc] initWithTitle:@"FIELD_TRANSACTION_TITLE" placeholder:@"FIELD_TRANSACTION_TITLE_PLACEHOLDER" for:transaction key:@"why" position:CGPointMake(0, 0)];
            
            [_contentView addSubview:title];
            
            offset = CGRectGetMaxY(title.frame);
        }

        if(_transactionType == TransactionTypeEvent){
            FLSelectAmount *selectAmount = [[FLSelectAmount alloc] initWithFrame:CGRectMakePosition(0, offset) for:transaction];
            [_contentView addSubview:selectAmount];
            
            selectAmount.delegate = self;
            
            offset = CGRectGetMaxY(selectAmount.frame);
        }
        
        
        amountInput = [[FLNewTransactionAmount alloc] initFor:transaction key:@"amount"];
        [amountInput setInputAccessoryView:[[FLNewTransactionBar alloc] initWithFor:transaction]];
        [_contentView addSubview:amountInput];
        amountInput.frame = CGRectSetY(amountInput.frame, offset);
        offset = CGRectGetMaxY(amountInput.frame);
        
        if(_transactionType != TransactionTypeEvent){
            FLSelectFriendButton *friend = [[FLSelectFriendButton alloc] initWithFrame:CGRectMakePosition(0, CGRectGetMaxY(amountInput.frame)) dictionary:transaction];
            friend.delegate = self;

            [_contentView addSubview:friend];
            
            offset = CGRectGetMaxY(friend.frame);
        }
        
        
        if(_transactionType == TransactionTypePayment){
            FLPaymentField *payementField = [[FLPaymentField alloc] initWithFrame:CGRectMakePosition(0, offset) for:transaction key:@"source"];
            [_contentView addSubview:payementField];
            
            offset = CGRectGetMaxY(payementField.frame);
        }

        
        NSString *contentPlaceholder = @"FIELD_TRANSACTION_CONTENT_PLACEHOLDER";
        if(_transactionType == TransactionTypeEvent){
            contentPlaceholder = @"FIELD_TRANSACTION_EVENT_PLACEHOLDER";
        }
        
        content = [[FLTextView alloc] initWithPlaceholder:contentPlaceholder for:transaction key:@"content" position:CGPointMake(0, offset)];
        
        [_contentView addSubview:content];

        
        transactionBar = [[FLNewTransactionBar alloc] initWithFor:transaction];
        [_contentView addSubview:transactionBar];
    }
    
    if(_transactionType == TransactionTypeEvent){
        [self didAmountFreeSelected];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _contentView.frame = CGRectMake(0, CGRectGetMaxY(navBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    transactionBar.frame = CGRectSetY(transactionBar.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame) - _contentView.frame.origin.y);
}

#pragma mark -

- (void)didAmountFixSelected
{
    [UIView animateWithDuration:.5 animations:^{
        amountInput.frame = CGRectSetHeight(amountInput.frame, [FLNewTransactionAmount height]);
        content.frame = CGRectSetY(content.frame, content.frame.origin.y + [FLNewTransactionAmount height]);
    }];
}

- (void)didAmountFreeSelected
{
    [transaction setValue:nil forKey:@"amount"];
    
    [UIView animateWithDuration:.5 animations:^{
        amountInput.frame = CGRectSetHeight(amountInput.frame, 1);
        content.frame = CGRectSetY(content.frame, content.frame.origin.y - [FLNewTransactionAmount height]);
    }];
}

#pragma mark - callbacks

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)valid
{
    NSLog(@"%@", transaction);
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createTransaction:transaction success:^(id result) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } failure:NULL];
}

@end
