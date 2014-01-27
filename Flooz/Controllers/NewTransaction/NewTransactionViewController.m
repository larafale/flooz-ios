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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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

        
        FLNewTransactionAmount *amountInput = [FLNewTransactionAmount new];
        [_contentView addSubview:amountInput];
        
        amountInput.frame = CGRectSetY(amountInput.frame, CGRectGetMaxY(title.frame));
        
        FLTextFieldTitle *to = [[FLTextFieldTitle alloc] initWithTitle:@"FIELD_TRANSACTION_TO" placeholder:@"FIELD_TRANSACTION_TO_PLACEHOLDER" for:transaction key:@"to" position:CGPointMake(0, CGRectGetMaxY(amountInput.frame))];
        
        [_contentView addSubview:to];
        
        
        FLTextField *content = [[FLTextField alloc] initWithPlaceholder:@"FIELD_TRANSACTION_CONTENT_PLACEHOLDER" for:transaction key:@"content" position:CGPointMake(0, CGRectGetMaxY(to.frame))];
        
        [_contentView addSubview:content];

        
        FLPaymentField *payementField = [[FLPaymentField alloc] initWithFrame:CGRectMakePosition(0, CGRectGetMaxY(content.frame))];
        [_contentView addSubview:payementField];

        transactionBar = [[FLNewTransactionBar alloc] initWithFrame:CGRectMakePosition(0, CGRectGetMaxY(payementField.frame))];
        [_contentView addSubview:transactionBar];
        
        [amountInput setInputAccessoryView:transactionBar];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _contentView.frame = CGRectMake(0, CGRectGetMaxY(navBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)valid
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)onKeyboardHide:(NSNotification *)notification
{
//    NSLog(@"hidden");
//    transactionBar.frame = CGRectMakePosition(0, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame) - 100);
    NSLogFrame(transactionBar.frame);
}

@end
