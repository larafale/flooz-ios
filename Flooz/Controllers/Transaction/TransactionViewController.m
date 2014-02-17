//
//  TransactionViewController.m
//  Flooz
//
//  Created by jonathan on 2/5/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "TransactionViewController.h"

#import "TransactionHeaderView.h"
#import "TransactionActionsView.h"
#import "TransactionUsersView.h"
#import "TransactionAmountView.h"
#import "TransactionContentView.h"
#import "TransactionCommentsView.h"

@interface TransactionViewController (){
    FLTransaction *_transaction;
    NSIndexPath *_indexPath;
    
    UIScrollView *_contentView;
    UIView *_mainView;
    
    BOOL keyboardIsShown;
}

@end

@implementation TransactionViewController

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _transaction = transaction;
        _indexPath = indexPath;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader:0.9];
    
    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMakeWithSize(self.view.frame.size)];
    [self.view addSubview:_contentView];
    
    {
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(134, 40, 52, 52)];
        
        [closeButton setImage:[UIImage imageNamed:@"transaction-close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:closeButton];
    }
    
    if([_transaction isPrivate]){
        UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, 0, 18)];
        status.backgroundColor = [UIColor customBackground];
        status.layer.borderColor = [UIColor customSeparator].CGColor;
        status.layer.borderWidth = 1.;
        status.layer.cornerRadius = 9.;
        status.font = [UIFont customTitleBook:10];
        status.textAlignment = NSTextAlignmentCenter;
        
        UIColor *textColor = [UIColor whiteColor];
        
        switch ([_transaction status]) {
            case TransactionStatusAccepted:
                textColor = [UIColor customGreen];
                break;
            case TransactionStatusPending:
                textColor = [UIColor customYellow];
                break;
            case TransactionStatusRefused:
            case TransactionStatusCanceled:
            case TransactionStatusExpired:
                textColor = [UIColor whiteColor];
                break;
        }
        
        status.textColor = textColor;
        
        status.text = [_transaction statusText];
        [status setWidthToFit];
        status.frame = CGRectSetWidth(status.frame, CGRectGetWidth(status.frame) + 20);
        status.frame = CGRectSetX(status.frame, CGRectGetWidth(self.view.frame) - CGRectGetWidth(status.frame) - 13);
        
        [_contentView addSubview:status];
    }
    
    {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(13, 100, CGRectGetWidth(_contentView.frame) - (2 * 13), 200)];
        
        _mainView.backgroundColor = [UIColor customBackgroundHeader];
        _mainView.layer.borderWidth = 1.;
        _mainView.layer.borderColor = [UIColor customSeparator].CGColor;
        
        _mainView.layer.shadowColor = [UIColor blackColor].CGColor;
        _mainView.layer.shadowOffset = CGSizeMake(-1, -1);
        _mainView.layer.shadowOpacity = .5;
        
        [_contentView addSubview:_mainView];
    }
    
     CGFloat height = 0;
    
    if([_transaction type] == TransactionTypeEvent){
        TransactionHeaderView *view = [[TransactionHeaderView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.transaction = _transaction;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    if([_transaction isPrivate] && [_transaction status] == TransactionStatusPending){
        TransactionActionsView *view = [[TransactionActionsView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.transaction = _transaction;
        view.delegate = self;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
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
    
    {
        TransactionContentView *view = [[TransactionContentView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.transaction = _transaction;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        TransactionCommentsView *view = [[TransactionCommentsView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.transaction = _transaction;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    _mainView.frame = CGRectSetHeight(_mainView.frame, height + 15);
    _contentView.contentSize = CGSizeMake(0, CGRectGetMaxY(_mainView.frame) + 10);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _contentView.frame = CGRectMakeWithSize(self.view.frame.size);
    _contentView.contentSize = CGSizeMake(0, CGRectGetMaxY(_mainView.frame) + 10);
    
    _contentView.frame = CGRectSetY(_contentView.frame, CGRectGetHeight(self.view.frame));
    
    [UIView animateWithDuration:0.3 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        _contentView.frame = CGRectSetY(_contentView.frame, - 10);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
            _contentView.frame = CGRectSetY(_contentView.frame, 0);
        } completion:NULL];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:self.view.window];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:self.view.window];
    
    keyboardIsShown = NO;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)keyboardWillShow:(NSNotification *)n
{
    if(keyboardIsShown){
        return;
    }
    keyboardIsShown = YES;
    
//    NSDictionary* userInfo = [n userInfo];
//    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    _contentView.contentSize = CGSizeMake(0, _contentView.contentSize.height + keyboardSize.height);
}

- (void)keyboardWillHide:(NSNotification *)n
{
//    NSDictionary* userInfo = [n userInfo];
//    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    _mainView.frame = CGRectSetHeight(_mainView.frame, CGRectGetHeight(_mainView.frame) - keyboardSize.height);
//    _contentView.contentSize = CGSizeMake(0, _contentView.contentSize.height - keyboardSize.height);
//    
    keyboardIsShown = NO;
}

- (void)reloadTransaction
{
    // WARNING
    for(UIView *view in [self.view subviews]){
        [view removeFromSuperview];
    }
    [self loadView];
    
    [_delegateController updateTransactionAtIndex:_indexPath transaction:_transaction];
}

#pragma mark - Actions

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
    //    [[Flooz sharedInstance] showLoadView];
    //
    //    NSDictionary *params = @{
    //                             @"id": [_transaction transactionId],
    //                             @"state": [FLTransaction transactionStatusToParams:TransactionStatusAccepted]
    //                             };
    //
    //    [[Flooz sharedInstance] updateTransaction:params success:^(id result) {
    //
    //    } failure:NULL];
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

@end
