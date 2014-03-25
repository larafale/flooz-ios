//
//  TransactionViewController.m
//  Flooz
//
//  Created by jonathan on 2/5/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "TransactionViewController.h"

#import "TransactionActionsView.h"
#import "TransactionUsersView.h"
#import "TransactionAmountView.h"
#import "TransactionContentView.h"
#import "TransactionCommentsView.h"

#import "CreditCardViewController.h"

#import "FLPaymentField.h"

#import "UIView+FindFirstResponder.h"

#import "SecureCodeViewController.h"

#define STATUSBAR_HEIGHT 20.

@interface TransactionViewController (){
    FLTransaction *_transaction;
    NSIndexPath *_indexPath;
    
    UIView *_mainView;
    
    BOOL paymentFieldIsShown;
    BOOL firstView;
    
    UISwipeGestureRecognizer *swipeGesture;
}

@end

@implementation TransactionViewController

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _transaction = transaction;
        _indexPath = indexPath;
        paymentFieldIsShown = NO;
        firstView = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    self.view.backgroundColor = [UIColor customBackgroundHeader:0.9];
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [[_contentView panGestureRecognizer] requireGestureRecognizerToFail:swipeGesture];
    [self.view addGestureRecognizer:swipeGesture];
    
    [self buildView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(firstView){
        firstView = NO;
        _contentView.contentSize = CGSizeMake(0, CGRectGetMaxY(_mainView.frame) + 10);
        
        CGRectSetY(_contentView.frame, CGRectGetHeight(self.view.frame));
        
        [UIView animateWithDuration:0.3 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRectSetY(_contentView.frame, - 10);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
                CGRectSetY(_contentView.frame, STATUSBAR_HEIGHT);
            } completion:NULL];
        }];
    }
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)buildView
{
    {
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(134, 20, 52, 52)];
        
        [closeButton setImage:[UIImage imageNamed:@"transaction-close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:closeButton];
    }
    
    {
        JTImageLabel *view = [[JTImageLabel alloc] initWithFrame:CGRectMake(0, 55, 0, 15)];
        
        view.textAlignment = NSTextAlignmentRight;
        view.textColor = [UIColor whiteColor];
        view.font = [UIFont customContentLight:11];
        
        [view setImage:[UIImage imageNamed:@"transaction-content-clock"]];
        [view setImageOffset:CGPointMake(- 4, 0)];
        
        view.text = [FLHelper formatedDate:[_transaction date]];
        
        [view setWidthToFit];
        CGRectSetX(view.frame, CGRectGetWidth(_contentView.frame) - CGRectGetWidth(view.frame) - 13);
        
        [_contentView addSubview:view];
    }
    
//    if([_transaction isPrivate]){
//        UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 0, 18)];
//        status.backgroundColor = [UIColor customBackground];
//        status.layer.borderColor = [UIColor customSeparator].CGColor;
//        status.layer.borderWidth = 1.;
//        status.layer.cornerRadius = 9.;
//        status.font = [UIFont customTitleBook:10];
//        status.textAlignment = NSTextAlignmentCenter;
//        
//        UIColor *textColor = [UIColor whiteColor];
//        
//        switch ([_transaction status]) {
//            case TransactionStatusAccepted:
//                textColor = [UIColor customGreen];
//                break;
//            case TransactionStatusPending:
//                textColor = [UIColor customYellow];
//                break;
//            case TransactionStatusRefused:
//            case TransactionStatusCanceled:
//            case TransactionStatusExpired:
//                textColor = [UIColor customRed];
//                break;
//        }
//        
//        status.textColor = textColor;
//        
//        status.text = [NSString stringWithFormat:@"  %@", [_transaction statusText]]; // Hack pour mettre un padding
//        [status setWidthToFit];
//        CGRectSetWidth(status.frame, CGRectGetWidth(status.frame) + 20);
//        CGRectSetX(status.frame, CGRectGetWidth(_contentView.frame) - CGRectGetWidth(status.frame) - 13);
//        
//        [_contentView addSubview:status];
//        
//        
//        UIImageView *imageView;
//        switch ([_transaction status]) {
//            case TransactionStatusAccepted:
//                imageView = [UIImageView imageNamed:@"transaction-cell-status-accepted"];
//                break;
//            case TransactionStatusPending:
//                imageView = [UIImageView imageNamed:@"transaction-cell-status-pending"];
//                break;
//            case TransactionStatusRefused:
//            case TransactionStatusCanceled:
//            case TransactionStatusExpired:
//                imageView = [UIImageView imageNamed:@"transaction-cell-status-refused"];
//                break;
//        }
//        
//        CGRectSetXY(imageView.frame, status.frame.origin.x + 5, status.center.y - 2);
//        [_contentView addSubview:imageView];
//    }
    
    {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(13, 80, CGRectGetWidth(_contentView.frame) - (2 * 13), 0)];
        
        _mainView.backgroundColor = [UIColor customBackgroundHeader];
        _mainView.layer.borderWidth = 1.;
        _mainView.layer.borderColor = [UIColor customSeparator].CGColor;
        
        _mainView.layer.shadowColor = [UIColor blackColor].CGColor;
        _mainView.layer.shadowOffset = CGSizeMake(-1, -1);
        _mainView.layer.shadowOpacity = .5;
        
        [_contentView addSubview:_mainView];
    }
    
    CGFloat height = 0;
    
    {
        TransactionUsersView *view = [[TransactionUsersView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.transaction = _transaction;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    if([_transaction isPrivate]){
        TransactionAmountView *view = [[TransactionAmountView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.transaction = _transaction;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    if([_transaction isPrivate] && [_transaction status] == TransactionStatusPending){
        if(paymentFieldIsShown){
            FLPaymentField *view = [[FLPaymentField alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0) for:nil key:nil];
            view.delegate = self;
            view.backgroundColor = [UIColor customBackground:0.4];
            [_mainView addSubview:view];
            height = CGRectGetMaxY(view.frame);
        }
        else{
            TransactionActionsView *view = [[TransactionActionsView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
            view.transaction = _transaction;
            view.delegate = self;
            [_mainView addSubview:view];
            height = CGRectGetMaxY(view.frame);
        }
    }
    
    {
        TransactionContentView *view = [[TransactionContentView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.transaction = _transaction;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        TransactionCommentsView *view = [[TransactionCommentsView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.transaction = _transaction;
        view.delegate = self;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    CGRectSetHeight(_mainView.frame, height + 15);
    _contentView.contentSize = CGSizeMake(0, CGRectGetMaxY(_mainView.frame) + 10);
}

#pragma mark - FLPaymentFieldDelegate

- (void)didCreditCardSelected
{
    id completeBlock = ^{
        [[Flooz sharedInstance] showLoadView];
        
        NSDictionary *params = @{
                                 @"id": [_transaction transactionId],
                                 @"state": [FLTransaction transactionStatusToParams:TransactionStatusAccepted],
                                 @"source": [FLTransaction transactionPaymentMethodToParams:TransactionPaymentMethodCreditCard]
                                 };
        
        [[Flooz sharedInstance] updateTransaction:params success:^(id result) {
            _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
            paymentFieldIsShown = NO;
            [self reloadTransaction];
        } failure:NULL];
    };
    
    SecureCodeViewController *controller = [SecureCodeViewController new];
    controller.completeBlock = completeBlock;
    
    [self presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
}

- (void)didWalletSelected
{
    id completeBlock = ^{
        [[Flooz sharedInstance] showLoadView];
        
        NSDictionary *params = @{
                                 @"id": [_transaction transactionId],
                                 @"state": [FLTransaction transactionStatusToParams:TransactionStatusAccepted],
                                 @"source": [FLTransaction transactionPaymentMethodToParams:TransactionPaymentMethodWallet]
                                 };
        
        [[Flooz sharedInstance] updateTransaction:params success:^(id result) {
            _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
            paymentFieldIsShown = NO;
            [self reloadTransaction];
        } failure:NULL];
    };
    
    SecureCodeViewController *controller = [SecureCodeViewController new];
    controller.completeBlock = completeBlock;
    
    [self presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
}

- (void)presentCreditCardController
{
    CreditCardViewController *controller = [CreditCardViewController new];
    
    [self presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
}

#pragma mark - Actions

- (void)showPaymentField
{
    paymentFieldIsShown = YES;
    [self reloadTransaction];
}

- (void)reloadTransaction
{
    for(UIView *view in [_contentView subviews]){
        [view removeFromSuperview];
    }
    [self buildView];
    
    [_delegateController updateTransactionAtIndex:_indexPath transaction:_transaction];
}

- (void)cancelTransaction
{
    [[Flooz sharedInstance] showLoadView];
    
    NSDictionary *params = @{
                             @"id": [_transaction transactionId],
                             @"state": [FLTransaction transactionStatusToParams:TransactionStatusCanceled]
                             };
    
    [[Flooz sharedInstance] updateTransaction:params success:^(id result) {
        _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
        [self reloadTransaction];
    } failure:NULL];
}

- (void)acceptTransaction
{
    [[Flooz sharedInstance] showLoadView];
    
    NSDictionary *params = @{
                             @"id": [_transaction transactionId],
                             @"state": [FLTransaction transactionStatusToParams:TransactionStatusAccepted]
                             };
    
    [[Flooz sharedInstance] updateTransaction:params success:^(id result) {
        _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
        [self reloadTransaction];
    } failure:NULL];
}

- (void)refuseTransaction
{
    [[Flooz sharedInstance] showLoadView];
    
    NSDictionary *params = @{
                             @"id": [_transaction transactionId],
                             @"state": [FLTransaction transactionStatusToParams:TransactionStatusRefused]
                             };
    
    [[Flooz sharedInstance] updateTransaction:params success:^(id result) {
        _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
        [self reloadTransaction];
    } failure:NULL];
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
    
    UIView *firstResponder = [self.view findFirstResponder];
    if([[[firstResponder superview] superview] isKindOfClass:[TransactionCommentsView class]]){
        _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        CGFloat y = _contentView.contentSize.height - (CGRectGetHeight(_contentView.frame) - keyboardHeight);
        [_contentView setContentOffset:CGPointMake(0, MAX(y, 0)) animated:YES];
    }
}

- (void)keyboardWillDisappear
{
    _contentView.contentInset = UIEdgeInsetsZero;
}

@end
