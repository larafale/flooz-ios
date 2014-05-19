//
//  TransactionActionsView.m
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "TransactionActionsView.h"

@implementation TransactionActionsView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 55);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews
{
    [self createRefuseView];
    [self createAcceptView];
    [self createCancelView];
    [self createWaitingView];
    [self createBottomBar];
}

- (void)createRefuseView
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame))];

    view.titleLabel.textAlignment = NSTextAlignmentCenter;
    view.titleLabel.font = [UIFont customTitleExtraLight:14];
    [view setImageEdgeInsets:UIEdgeInsetsMake(2, -10, 0, 0)];
    
    [view setImage:[UIImage imageNamed:@"transaction-cell-cross"] forState:UIControlStateNormal];
    [view setTitle:NSLocalizedString(@"TRANSACTION_ACTION_REFUSE", nil) forState:UIControlStateNormal];
    [view setTitleColor:[UIColor customRed] forState:UIControlStateNormal];
    
    [view addTarget:self action:@selector(didRefuseTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:view];
}

- (void)createAcceptView
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., 0, CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame))];
    
    view.titleLabel.textAlignment = NSTextAlignmentCenter;
    view.titleLabel.font = [UIFont customTitleExtraLight:14];
    [view setImageEdgeInsets:UIEdgeInsetsMake(2, -10, 0, 0)];
    
    [view setImage:[UIImage imageNamed:@"transaction-cell-check"] forState:UIControlStateNormal];
    [view setTitle:NSLocalizedString(@"TRANSACTION_ACTION_ACCEPT", nil) forState:UIControlStateNormal];
    [view setTitleColor:[UIColor customGreen] forState:UIControlStateNormal];
    
    [view addTarget:self action:@selector(didAcceptTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:view];
}

- (void)createCancelView
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMakeWithSize(self.frame.size)];
    
    view.titleLabel.textAlignment = NSTextAlignmentCenter;
    view.titleLabel.font = [UIFont customTitleExtraLight:14];
    [view setImageEdgeInsets:UIEdgeInsetsMake(2, -10, 0, 0)];
    
    [view setImage:[UIImage imageNamed:@"transaction-cell-cross"] forState:UIControlStateNormal];
    [view setTitle:NSLocalizedString(@"TRANSACTION_ACTION_CANCEL", nil) forState:UIControlStateNormal];
    [view setTitleColor:[UIColor customRed] forState:UIControlStateNormal];
    
    [view addTarget:self action:@selector(didCancelTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:view];
}

- (void)createWaitingView
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMakeWithSize(self.frame.size)];
    
    view.titleLabel.textAlignment = NSTextAlignmentCenter;
    view.titleLabel.font = [UIFont customTitleExtraLight:14];
    [view setImageEdgeInsets:UIEdgeInsetsMake(2, -10, 0, 0)];
    
    [view setTitle:NSLocalizedString(@"TRANSACTION_ACTION_WAITING", nil) forState:UIControlStateNormal];
    [view setTitleColor:[UIColor customYellow] forState:UIControlStateNormal];
    
    [self addSubview:view];
}

- (void)createBottomBar
{
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
    bottomBar.backgroundColor = [UIColor customSeparator:0.5];
    
    [self addSubview:bottomBar];
}

#pragma mark -

- (void)setTransaction:(FLTransaction *)transaction{
    self->_transaction = transaction;
    [self prepareViews];
}

#pragma mark -

- (void)prepareViews
{
    UIView *refuseView = [[self subviews] objectAtIndex:0];
    UIView *acceptView = [[self subviews] objectAtIndex:1];
    UIView *cancelView = [[self subviews] objectAtIndex:2];
    UIView *waitingView = [[self subviews] objectAtIndex:3];
    
    refuseView.hidden = acceptView.hidden = cancelView.hidden = waitingView.hidden = YES;
    
    if([_transaction isCancelable]){
        cancelView.hidden = NO;
    }
    else if([_transaction isAcceptable]){
        refuseView.hidden = acceptView.hidden = NO;
    }
    else{
        waitingView.hidden = NO;
    }
}

- (void)didAcceptTouch
{
//    if([_transaction type] == TransactionTypePayment &&
//        [[[_transaction to] userId] isEqualToString:[[[Flooz sharedInstance] currentUser] userId]]
//       ){
//        [_delegate acceptTransaction];
//    }
//    else{
//        [_delegate showPaymentField];
//    }
    
    [_delegate acceptTransaction];
}

- (void)didRefuseTouch
{
    [_delegate refuseTransaction];
}

- (void)didCancelTouch
{
    [_delegate cancelTransaction];
}

@end
