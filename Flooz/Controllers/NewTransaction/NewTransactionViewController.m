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

#import "EventViewController.h"

#import "CreditCardViewController.h"
#import "FLContainerViewController.h"
#import "TimelineViewController.h"

@interface NewTransactionViewController (){
    NSMutableDictionary *transaction;
    
    FLValidNavBar *navBar;
    
    FLNewTransactionBar *transactionBar;
    FLNewTransactionBar *transactionBarKeyboard;
    
    TransactionType _transactionType;
    FLNewTransactionAmount *amountInput;
    FLTextView *content;
    
    FLSelectFriendButton *friend;
}

@end

@implementation NewTransactionViewController

- (id)initWithTransactionType:(TransactionType)transactionType;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        transaction = [NSMutableDictionary new];
        
        _transactionType = transactionType;
        [transaction setValue:[FLTransaction transactionTypeToParams:transactionType] forKey:@"method"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self registerForKeyboardNotifications];
    
    self.view.backgroundColor = [UIColor customBackground];
    
    transactionBarKeyboard = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self];
    
    CGFloat offset = 0;
    
    {
        navBar = [FLValidNavBar new];
        [_contentView addSubview:navBar];
        
        [navBar cancelAddTarget:self action:@selector(dismiss)];
        [navBar validAddTarget:self action:@selector(valid)];
        
        offset = CGRectGetMaxY(navBar.frame);
    }
 
    {
        if(_transactionType == TransactionTypeEvent){
            FLTextFieldTitle *title = [[FLTextFieldTitle alloc] initWithTitle:@"FIELD_TRANSACTION_TITLE" placeholder:@"FIELD_TRANSACTION_TITLE_PLACEHOLDER" for:transaction key:@"name" position:CGPointMake(0, offset)];
            [title setInputAccessoryView:transactionBarKeyboard];
            [_contentView addSubview:title];
            
            offset = CGRectGetMaxY(title.frame);
        }

        if(_transactionType == TransactionTypeEvent){
            FLSelectAmount *selectAmount = [[FLSelectAmount alloc] initWithFrame:CGRectMakePosition(0, offset) for:transaction];
            [_contentView addSubview:selectAmount];
            
            selectAmount.delegate = self;
            
            offset = CGRectGetMaxY(selectAmount.frame);
        }
        
        {
            amountInput = [[FLNewTransactionAmount alloc] initFor:transaction key:@"amount"];
            [amountInput setInputAccessoryView:transactionBarKeyboard];
            [_contentView addSubview:amountInput];
            CGRectSetY(amountInput.frame, offset);
            offset = CGRectGetMaxY(amountInput.frame);
        }

        if(_transactionType != TransactionTypeEvent){
            friend = [[FLSelectFriendButton alloc] initWithFrame:CGRectMakePosition(0, CGRectGetMaxY(amountInput.frame)) dictionary:transaction];
            friend.delegate = self;

            [_contentView addSubview:friend];
            
            offset = CGRectGetMaxY(friend.frame);
        }
        
        if(_transactionType == TransactionTypePayment){
            FLPaymentField *payementField = [[FLPaymentField alloc] initWithFrame:CGRectMake(0, offset, CGRectGetWidth(_contentView.frame), 0) for:transaction key:@"source"];
            payementField.delegate = self;
            [_contentView addSubview:payementField];
            
            offset = CGRectGetMaxY(payementField.frame);
        }
        
        NSString *contentPlaceholder = @"FIELD_TRANSACTION_CONTENT_PLACEHOLDER";
        if(_transactionType == TransactionTypeEvent){
            contentPlaceholder = @"FIELD_TRANSACTION_EVENT_PLACEHOLDER";
        }
        
        content = [[FLTextView alloc] initWithPlaceholder:contentPlaceholder for:transaction key:@"why" position:CGPointMake(0, offset)];
        [content setInputAccessoryView:transactionBarKeyboard];
        [_contentView addSubview:content];

        transactionBar = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self];
        [_contentView addSubview:transactionBar];
        
        offset = CGRectGetMaxY(content.frame);
    }
    
    if(_transactionType == TransactionTypeEvent){
        [self didAmountFreeSelected];
    }
    
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), offset);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame) - _contentView.frame.origin.y);
    
    [friend reloadData];
    [self reloadTransactionBarData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTransactionBarData)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTransactionBarData)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

#pragma mark -

- (void)didAmountFixSelected
{
    [[self view] endEditing:YES];
    
    [transaction setValue:@100.0 forKey:@"amount"];
    
    [UIView animateWithDuration:.5 animations:^{
        CGRectSetHeight(amountInput.frame, [FLNewTransactionAmount height]);
        CGRectSetY(content.frame, content.frame.origin.y + [FLNewTransactionAmount height]);
    }];
}

- (void)didAmountFreeSelected
{
    // Sinon la valeur du clavier est sauvegarder a l envoi
    [[self view] endEditing:YES];
    
    [transaction setValue:nil forKey:@"amount"];
    
    [UIView animateWithDuration:.5 animations:^{
        CGRectSetHeight(amountInput.frame, 1);
        CGRectSetY(content.frame, content.frame.origin.y - [FLNewTransactionAmount height]);
    }];
}

#pragma mark - callbacks

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)valid
{
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    
    if(_transactionType == TransactionTypeEvent){
        [[Flooz sharedInstance] createEvent:transaction success:^(id result) {
            FLEvent *event = [[FLEvent alloc] initWithJSON:[result objectForKey:@"item"]];
            EventViewController *controller = [[EventViewController alloc] initWithEvent:event indexPath:nil];
            
            __strong UIViewController *presentingViewController = [self presentingViewController];
            
            [self dismissViewControllerAnimated:YES completion:^{
                presentingViewController.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
                
                [presentingViewController presentViewController:controller animated:NO completion:^{
                    presentingViewController.parentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                }];
            }];
        } failure:NULL];
    }
    else{
        [[Flooz sharedInstance] createTransaction:transaction success:^(id result) {
            FLContainerViewController *presentingViewController = (FLContainerViewController *)[self presentingViewController];
            TimelineViewController *timelineController = [[presentingViewController viewControllers] objectAtIndex:1];
            [self dismissViewControllerAnimated:YES completion:^{
                [[timelineController filterView] selectFilter:2];
            }];
        } failure:NULL];
    }
}

- (void)reloadTransactionBarData
{    
    [transactionBar reloadData];
    [transactionBarKeyboard reloadData];
}

#pragma mark - PaymentFielDelegate

- (void)didWalletSelected
{
}

- (void)didCreditCardSelected
{
}

- (void)presentCreditCardController
{
    CreditCardViewController *controller = [CreditCardViewController new];
    
    [self presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidAppear:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardDidAppear:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillDisappear
{
    _contentView.contentInset = UIEdgeInsetsZero;
}

@end
