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

@interface NewTransactionViewController (){
    NSMutableDictionary *transaction;
    
    FLValidNavBar *navBar;
    UIScrollView *_contentView;
    
    FLNewTransactionBar *transactionBar;
}

@end

@implementation NewTransactionViewController

- (id)initWithTransactionType:(TransactionType)transactionType;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        transaction = [NSMutableDictionary new];
        
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
        FLTextFieldTitle *title = [[FLTextFieldTitle alloc] initWithTitle:@"FIELD_TRANSACTION_TITLE" placeholder:@"FIELD_TRANSACTION_TITLE_PLACEHOLDER" for:transaction key:@"why" position:CGPointMake(0, 0)];
        
        [_contentView addSubview:title];

        
        FLNewTransactionAmount *amountInput = [[FLNewTransactionAmount alloc] initFor:transaction key:@"amount"];
        [amountInput setInputAccessoryView:[[FLNewTransactionBar alloc] initWithFor:transaction]];
        [_contentView addSubview:amountInput];
        
        amountInput.frame = CGRectSetY(amountInput.frame, CGRectGetMaxY(title.frame));
        
        FLTextFieldTitle *to = [[FLTextFieldTitle alloc] initWithTitle:@"FIELD_TRANSACTION_TO" placeholder:@"FIELD_TRANSACTION_TO_PLACEHOLDER" for:transaction key:@"to" position:CGPointMake(0, CGRectGetMaxY(amountInput.frame))];
        
        [_contentView addSubview:to];
        
        
        FLTextView *content = [[FLTextView alloc] initWithPlaceholder:@"FIELD_TRANSACTION_CONTENT_PLACEHOLDER" for:transaction key:@"content" position:CGPointMake(0, CGRectGetMaxY(to.frame))];
        
        [_contentView addSubview:content];

        if([[transaction objectForKey:@"method"] isEqualToString:[FLTransaction TransactionTypeToParams:TransactionTypePayment]]){
            FLPaymentField *payementField = [[FLPaymentField alloc] initWithFrame:CGRectMakePosition(0, CGRectGetMaxY(content.frame)) for:transaction key:@"source"];
            [_contentView addSubview:payementField];
        }

        transactionBar = [[FLNewTransactionBar alloc] initWithFor:transaction];
        [_contentView addSubview:transactionBar];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _contentView.frame = CGRectMake(0, CGRectGetMaxY(navBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    transactionBar.frame = CGRectSetY(transactionBar.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame) - _contentView.frame.origin.y);
}

#pragma mark - callbacks

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)valid
{
    NSLog(@"%@", transaction);
    [[Flooz sharedInstance] createTransaction:transaction success:^(id result) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } failure:NULL];
}

@end
