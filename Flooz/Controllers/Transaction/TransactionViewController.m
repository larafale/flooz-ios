//
//  TransactionViewController.m
//  Flooz
//
//  Created by jonathan on 2/5/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "TransactionViewController.h"
#import "SecureCodeViewController.h"

#import "TransactionHeaderView.h"
#import "TransactionActionsView.h"
#import "TransactionUsersView.h"
#import "TransactionUsersCollectView.h"
#import "TransactionAmountView.h"
#import "TransactionContentView.h"
#import "TransactionCommentsView.h"
#import "FLNewTransactionAmount.h"

#import "CreditCardViewController.h"

#import "UIView+FindFirstResponder.h"

@interface TransactionViewController (){
    FLTransaction *_transaction;
    NSIndexPath *_indexPath;
    
    BOOL focusOnCommentTextField;
    
    UIView *_mainView;
    
    BOOL animationFirstView;
    BOOL paymentFieldIsVisible;
    
    TransactionActionsView *actionsView;
    FLNewTransactionAmount *amountInput;
    TransactionContentView *contentTextView;
    TransactionCommentsView *commentsView;
    NSMutableDictionary *paymentFieldAmountData;
}

@end

@implementation TransactionViewController

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _transaction = transaction;
        _indexPath = indexPath;
        animationFirstView = YES;
        paymentFieldIsVisible = NO;
        focusOnCommentTextField = NO;
        paymentFieldAmountData = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader:0.9];
    [self registerForKeyboardNotifications];
    
    [self createViews];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startAnimationFirstView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (focusOnCommentTextField) {
        [commentsView focusOnTextField];
    }
}

#pragma mark - Animation

- (void)startAnimationFirstView
{
    if(!animationFirstView){
        return;
    }
    
    animationFirstView = NO;
    
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

#pragma mark - Views

- (void)createViews
{
    {
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(134, 20, 52, 52)];
        [FLHelper addMotionEffect:closeButton];
        
        [closeButton setImage:[UIImage imageNamed:@"transaction-close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:closeButton];
    }
    
    {
        JTImageLabel *view = [[JTImageLabel alloc] initWithFrame:CGRectMake(0, 55, 0, 15)];
        
        view.textAlignment = NSTextAlignmentRight;
        view.textColor = [UIColor whiteColor];
        view.font = [UIFont customContentLight:11];
        
        view.text = [FLHelper formatedDate:[_transaction date]];
        
        float yOffset = -1;
        NSString *imageNamed = @"transaction-content-clock";
        if(_transaction.social.scope == SocialScopeFriend){
            imageNamed = @"scope-friend";
        }
        else if(_transaction.social.scope == SocialScopePrivate){
            imageNamed = @"scope-private";
        }
        else if(_transaction.social.scope == SocialScopePublic){
            imageNamed = @"scope-public";
        }
        else {
            imageNamed = @"transaction-content-clock";
            yOffset = 0;
        }
        [view setImage:[UIImage imageNamed:imageNamed]];
        [view setImageOffset:CGPointMake(- 4, yOffset)];
        
        [view setWidthToFit];
        CGRectSetX(view.frame, CGRectGetWidth(_contentView.frame) - CGRectGetWidth(view.frame) - 13);
        
        [_contentView addSubview:view];
    }
    
    {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(13, 80, CGRectGetWidth(_contentView.frame) - (2 * 13), 0)];
        
        [FLHelper addMotionEffect:_mainView];
        
        _mainView.backgroundColor = [UIColor customBackgroundHeader];
        _mainView.layer.borderWidth = 1.;
        _mainView.layer.borderColor = [UIColor customSeparator].CGColor;
        
        _mainView.layer.shadowColor = [UIColor blackColor].CGColor;
        _mainView.layer.shadowOffset = CGSizeMake(-1, -1);
        _mainView.layer.shadowOpacity = .5;
        
        [_contentView addSubview:_mainView];
    }
    
    CGFloat height = 0;
    
    if(_transaction.isCollect){
        TransactionHeaderView *view = [[TransactionHeaderView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.transaction = _transaction;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    if(_transaction.isCollect){
        TransactionUsersCollectView *view = [[TransactionUsersCollectView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.transaction = _transaction;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    else{
        TransactionUsersView *view = [[TransactionUsersView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.transaction = _transaction;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    if([_transaction amount] && !_transaction.isCollect){
        TransactionAmountView *view = [[TransactionAmountView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.transaction = _transaction;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    if([_transaction haveAction] || (_transaction.isCollect && _transaction.collectCanParticipate)){
        actionsView = [[TransactionActionsView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        actionsView.transaction = _transaction;
        actionsView.delegate = self;
        [_mainView addSubview:actionsView];
        height = CGRectGetMaxY(actionsView.frame);
    }
    
    if(_transaction.isCollect && _transaction.collectCanParticipate){
        amountInput = [[FLNewTransactionAmount alloc] initFor:paymentFieldAmountData key:@"amount" width:CGRectGetWidth(_mainView.frame) delegate:self];
        [_mainView addSubview:amountInput];
        CGRectSetY(amountInput.frame, height - 1);
        CGRectSetHeight(amountInput.frame, 0);
    }
    
    {
        contentTextView = [[TransactionContentView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        contentTextView.transaction = _transaction;
        [_mainView addSubview:contentTextView];
        height = CGRectGetMaxY(contentTextView.frame);
        
        [contentTextView addTargetForLike:self action:@selector(didUpdateTransactionData)];
    }
    
    {
        commentsView = [[TransactionCommentsView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        commentsView.transaction = _transaction;
        commentsView.delegate = self;
        [_mainView addSubview:commentsView];
        height = CGRectGetMaxY(commentsView.frame);
    }
    
    CGRectSetHeight(_mainView.frame, height + 15);
    _contentView.contentSize = CGSizeMake(0, CGRectGetMaxY(_mainView.frame) + 10);
}

#pragma mark - Actions

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)reloadTransaction
{
    for(UIView *view in [_contentView subviews]){
        [view removeFromSuperview];
    }
    [self createViews];
        
    [self didUpdateTransactionData];
}

- (void)didUpdateTransactionData
{
    if(_indexPath){
        [_delegateController updateTransactionAtIndex:_indexPath transaction:_transaction];
    }
}

- (void)didWantToCommentTransactionData
{
    if(_indexPath){
        [_delegateController commentTransactionAtIndex:_indexPath transaction:_transaction];
    }
}

#pragma mark - Payment Field Actions

- (void)showPaymentField
{
    paymentFieldIsVisible = YES;
    
    [self reloadViewsForShowPayment];
}

- (void)hidePaymentField
{
    paymentFieldIsVisible = NO;
    
    [amountInput resignFirstResponder];
    
    [self reloadViewsForShowPayment];
}


- (void)reloadViewsForShowPayment
{
    CGFloat height = amountInput.frame.origin.y;
  
    if(paymentFieldIsVisible){
        CGRectSetHeight(amountInput.frame, [FLNewTransactionAmount height]);
        height = CGRectGetMaxY(amountInput.frame);
    }
    else{
        CGRectSetHeight(amountInput.frame, 0);
    }
    
    {
        CGRectSetY(contentTextView.frame, height);
        height = CGRectGetMaxY(contentTextView.frame);
    }
    
    {
        CGRectSetY(commentsView.frame, height);
        height = CGRectGetMaxY(commentsView.frame);
    }
    
    CGRectSetHeight(_mainView.frame, height + 15);
    _contentView.contentSize = CGSizeMake(0, CGRectGetMaxY(_mainView.frame) + 10);
}

#pragma mark - Amount Input Delegate

- (void)didAmountValidTouch
{
    [self participateTransaction];
}

- (void)didAmountCancelTouch
{
    [actionsView cancelParticipate];
}

#pragma mark - Transaction Actions

- (void)acceptTransaction
{
    NSDictionary *params = @{
                             @"id": [_transaction transactionId],
                             @"state": [FLTransaction transactionStatusToParams:TransactionStatusAccepted]
                             };
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updateTransactionValidate:params success:^(id result) {
        
        if([result objectForKey:@"confirmationText"]){
            FLPopup *popup = [[FLPopup alloc] initWithMessage:[result objectForKey:@"confirmationText"] accept:^{
                [self didTransactionValidated];
            } refuse:NULL];
            [popup show];
        }
        else{
            [self didTransactionValidated];
        }
        
    } noCreditCard:^{
        [self presentCreditCardController];
    }];
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

- (void)participateTransaction
{
    if(!paymentFieldAmountData[@"amount"]){
        return;
    }
    
    CompleteBlock completeBlock = ^{
        [[Flooz sharedInstance] showLoadView];
        
        [[Flooz sharedInstance] participateCollect:_transaction.transactionId amount:paymentFieldAmountData[@"amount"] success:^(id result) {
            
            paymentFieldIsVisible = NO;
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] transactionWithId:[_transaction transactionId] success:^(id result) {
                _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
                [self reloadTransaction];
            }];
        } failure:NULL];
    };
    
    SecureCodeViewController *controller = [SecureCodeViewController new];
    controller.completeBlock = completeBlock;
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)didTransactionValidated
{
    CompleteBlock completeBlock = ^{
        NSDictionary *params = @{
                                 @"id": [_transaction transactionId],
                                 @"state": [FLTransaction transactionStatusToParams:TransactionStatusAccepted]
                                 };
        
        [[Flooz sharedInstance] showLoadView];
        
        [[Flooz sharedInstance] updateTransaction:params success:^(id result) {
            _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
            [self reloadTransaction];
        } failure:NULL];
    };
    
    SecureCodeViewController *secureVC = [SecureCodeViewController new];
    secureVC.completeBlock = completeBlock;
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:secureVC];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)presentCollectParticipantsController
{
//    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[[EventParticipantsViewController alloc] initWithEvent:_event]];
//    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications
{
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
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

- (void)focusOnComment {
    focusOnCommentTextField = YES;
}

- (void)keyboardWillDisappear
{
    _contentView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - Other

- (void)presentCreditCardController
{
    CreditCardViewController *controller = [CreditCardViewController new];
    
    [self presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
}

@end
