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
#import "NewTransactionSelectTypeView.h"

#import "EventViewController.h"

#import "CreditCardViewController.h"
#import "FLContainerViewController.h"
#import "TimelineViewController.h"
#import "NewTransactionDatePicker.h"

#import "AppDelegate.h"
#import "FLContainerViewController.h"

#import "SecureCodeViewController.h"

#import "UIView+FindFirstResponder.h"

@interface NewTransactionViewController (){
    NSMutableDictionary *transaction;
    
    FLNewTransactionBar *transactionBar;
    FLNewTransactionBar *transactionBarKeyboard;
    
    FLPaymentField *payementField;
    
    BOOL isEvent;
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
        
        isEvent = (transactionType == TransactionTypeEvent);
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
    
    {
        [_navBar cancelAddTarget:self action:@selector(dismiss)];
        [_navBar validAddTarget:self action:@selector(valid)];
    }
    
    CGFloat offset = 0;
    
    {
        if(isEvent){
            FLTextFieldTitle *title = [[FLTextFieldTitle alloc] initWithTitle:@"FIELD_TRANSACTION_TITLE" placeholder:@"FIELD_TRANSACTION_TITLE_PLACEHOLDER" for:transaction key:@"name" position:CGPointMake(0, offset)];
            [title setInputAccessoryView:transactionBarKeyboard];
            [_contentView addSubview:title];
            
            offset = CGRectGetMaxY(title.frame);
        }
        
        if(isEvent){
            NewTransactionDatePicker *view = [[NewTransactionDatePicker alloc] initWithTitle:@"FIELD_TRANSACTION_DATE" for:transaction key:@"endAt" position:CGPointMake(0, offset)];
            [view setInputAccessoryView:transactionBarKeyboard];
            [_contentView addSubview:view];
            
            offset = CGRectGetMaxY(view.frame);
        }
        
        if(isEvent){
            FLSelectAmount *selectAmount = [[FLSelectAmount alloc] initWithFrame:CGRectMakePosition(0, offset)];
            [_contentView addSubview:selectAmount];
            
            selectAmount.delegate = self;
            
            offset = CGRectGetMaxY(selectAmount.frame);
        }
        else{
            //            NewTransactionSelectTypeView *view = [[NewTransactionSelectTypeView alloc] initWithFrame:CGRectMakePosition(0, offset) for:transaction];
            //            [_contentView addSubview:view];
            //
            //            view.delegate = self;
            //
            //            offset = CGRectGetMaxY(view.frame);
        }
        
        
        if(isEvent){
            amountInput = [[FLNewTransactionAmount alloc] initFor:transaction key:@"goal"];
            [amountInput hideSeparatorTop];
        }
        else{
            amountInput = [[FLNewTransactionAmount alloc] initFor:transaction key:@"amount"];
        }
        {
            [amountInput setInputAccessoryView:transactionBarKeyboard];
            [_contentView addSubview:amountInput];
            CGRectSetY(amountInput.frame, offset);
            offset = CGRectGetMaxY(amountInput.frame);
        }
        
        if(!isEvent){
            friend = [[FLSelectFriendButton alloc] initWithFrame:CGRectMakePosition(0, CGRectGetMaxY(amountInput.frame)) dictionary:transaction];
            friend.delegate = self;
            
            [_contentView addSubview:friend];
            
            offset = CGRectGetMaxY(friend.frame);
        }
        
        //        if(!isEvent){
        //            payementField = [[FLPaymentField alloc] initWithFrame:CGRectMake(0, offset, CGRectGetWidth(_contentView.frame), 0) for:transaction key:@"source"];
        //            payementField.delegate = self;
        //            [_contentView addSubview:payementField];
        //
        //            if([[transaction objectForKey:@"method"] isEqualToString:[FLTransaction transactionTypeToParams:TransactionTypeCollection]]){
        //                CGRectSetHeight(payementField.frame, 1);
        //            }
        //
        //            offset = CGRectGetMaxY(payementField.frame);
        //        }
        
        NSString *contentPlaceholder = @"FIELD_TRANSACTION_CONTENT_PLACEHOLDER";
        if(isEvent){
            contentPlaceholder = @"FIELD_TRANSACTION_EVENT_PLACEHOLDER";
        }
        
        content = [[FLTextView alloc] initWithPlaceholder:contentPlaceholder for:transaction key:@"why" position:CGPointMake(0, offset - 1)];
        [content setInputAccessoryView:transactionBarKeyboard];
        [_contentView addSubview:content];
        
        transactionBar = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self];
        [_contentView addSubview:transactionBar];
        
        offset = CGRectGetMaxY(content.frame);
    }
    
    if(isEvent){
        //        [self didAmountFixSelected]; // Seulement si sur montant libre, utilise pour gerer les vues
    }
    else if([[transaction objectForKey:@"method"] isEqualToString:[FLTransaction transactionTypeToParams:TransactionTypePayment]]){
        [payementField didWalletTouch];
    }
    
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), offset);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame));
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRectSetY(transactionBar.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame));
}

#pragma mark -

- (void)didAmountFixSelected
{
    [[self view] endEditing:YES];
    
    if(isEvent){
        [transaction setValue:@100.0 forKey:@"goal"];
    }
    else{
        [transaction setValue:@100.0 forKey:@"amount"];
    }
    
    [UIView animateWithDuration:.5 animations:^{
        CGRectSetHeight(amountInput.frame, [FLNewTransactionAmount height]);
        CGRectSetY(content.frame, content.frame.origin.y + [FLNewTransactionAmount height]);
        _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), CGRectGetMaxY(content.frame));
    }];
}

- (void)didAmountFreeSelected
{
    // Sinon la valeur du clavier est sauvegarder a l envoi
    [[self view] endEditing:YES];
    
    [transaction setValue:nil forKey:@"amount"];
    [transaction setValue:nil forKey:@"goal"];
    
    [UIView animateWithDuration:.5 animations:^{
        CGRectSetHeight(amountInput.frame, 1);
        CGRectSetY(content.frame, content.frame.origin.y - [FLNewTransactionAmount height]);
        _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), CGRectGetMaxY(content.frame));
    }];
}

- (void)didTypePaymentelected
{
    [[self view] endEditing:YES];
    
    // Car remit a zero par didTypeCollectSelected
    [payementField didWalletTouch];
    [self didWalletSelected];
    
    if(CGRectGetHeight(payementField.frame) <= 1){
        [UIView animateWithDuration:.5 animations:^{
            CGRectSetHeight(payementField.frame, [FLPaymentField height]);
            CGRectSetY(content.frame, content.frame.origin.y + [FLPaymentField height]);
            _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), CGRectGetMaxY(content.frame));
        }];
    }
}

- (void)didTypeCollectSelected
{
    [[self view] endEditing:YES];
    
    [transaction setValue:nil forKey:@"source"];
    
    if(CGRectGetHeight(payementField.frame) > 1){
        [UIView animateWithDuration:.5 animations:^{
            CGRectSetHeight(payementField.frame, 0);
            CGRectSetY(content.frame, content.frame.origin.y - [FLPaymentField height] - 1);
            _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), CGRectGetMaxY(content.frame));
        }];
    }
}

#pragma mark - callbacks

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)valid
{
    [[self view] endEditing:YES];
    
    if(isEvent){
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] createEvent:transaction success:^(id result) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"reloadEvents" object:nil]];
            
            [self dismissViewControllerAnimated:YES completion:^{
                FLContainerViewController *rootController = (FLContainerViewController *)appDelegate.window.rootViewController;
                [rootController.navbarView loadControllerWithIndex:2];
            }];
        } failure:NULL];
    }
    else{
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] createTransactionValidate:transaction success:^(id result) {
            
            CompleteBlock completeBlock = ^{
                [[Flooz sharedInstance] showLoadView];
                [[Flooz sharedInstance] createTransaction:transaction success:^(id result) {
                    FLContainerViewController *presentingViewController = (FLContainerViewController *)[self presentingViewController];
                    TimelineViewController *timelineController = [[presentingViewController viewControllers] objectAtIndex:1];
                    [self dismissViewControllerAnimated:YES completion:^{
                        [[timelineController filterView] selectFilter:2];
                        FLContainerViewController *rootController = (FLContainerViewController *)appDelegate.window.rootViewController;
                        [rootController.navbarView loadControllerWithIndex:1];
                    }];
                } failure:NULL];
            };
            
            if([[transaction objectForKey:@"method"] isEqualToString:[FLTransaction transactionTypeToParams:TransactionTypePayment]]){
                
                SecureCodeViewController *controller = [SecureCodeViewController new];
                controller.completeBlock = completeBlock;
                
                [self presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
            }
            else{
                completeBlock();
            }
            
        } noCreditCard:^(){
            [self presentCreditCardController];
        }];
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
    
    transactionBar.hidden = YES;
    UIView *firstResponder = [self.view findFirstResponder];
    if([[firstResponder superview] isKindOfClass:[FLTextView class]]){
        _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        CGFloat y = _contentView.contentSize.height - (CGRectGetHeight(_contentView.frame) - keyboardHeight);
        [_contentView setContentOffset:CGPointMake(0, MAX(y, 0)) animated:YES];
    }
}

- (void)keyboardWillDisappear
{
    _contentView.contentInset = UIEdgeInsetsZero;
    
    transactionBar.hidden = NO;
    CGRectSetY(transactionBar.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame));
}

@end
