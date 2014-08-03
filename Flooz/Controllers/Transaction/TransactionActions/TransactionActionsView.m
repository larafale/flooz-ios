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
    [self createWaitingView];
    [self createParticipateView];
    [self createBottomBar];
}

- (void)createRefuseView
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame))];

    view.titleLabel.textAlignment = NSTextAlignmentCenter;
    view.titleLabel.font = [UIFont customTitleExtraLight:14];
    [view setImageEdgeInsets:UIEdgeInsetsMake(2, -10, 0, 0)];
    
//    [view setImage:[UIImage imageNamed:@"transaction-cell-cross"] forState:UIControlStateNormal];
    [view setTitle:NSLocalizedString(@"TRANSACTION_ACTION_REFUSE", nil) forState:UIControlStateNormal];
    [view setTitleColor:[UIColor customRed] forState:UIControlStateNormal];
    
    [view setBackgroundColor:[UIColor customRed]];
    [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [view addTarget:self action:@selector(didRefuseTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:view];
}

- (void)createAcceptView
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., 0, CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame))];
    
    view.titleLabel.textAlignment = NSTextAlignmentCenter;
    view.titleLabel.font = [UIFont customTitleExtraLight:14];
    [view setImageEdgeInsets:UIEdgeInsetsMake(2, -10, 0, 0)];
    
//    [view setImage:[UIImage imageNamed:@"transaction-cell-check"] forState:UIControlStateNormal];
    [view setTitle:NSLocalizedString(@"TRANSACTION_ACTION_ACCEPT", nil) forState:UIControlStateNormal];
    [view setTitleColor:[UIColor customGreen] forState:UIControlStateNormal];
    
    [view setBackgroundColor:[UIColor customGreen]];
    [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [view addTarget:self action:@selector(didAcceptTouch) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)createParticipateView
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMakeWithSize(self.frame.size)];
    
    view.backgroundColor = [UIColor customBlue];
    
    view.titleLabel.textAlignment = NSTextAlignmentCenter;
    view.titleLabel.font = [UIFont customTitleExtraLight:14];
    [view setImageEdgeInsets:UIEdgeInsetsMake(2, -10, 0, 0)];
    
    [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [view addTarget:self action:@selector(didParticipateTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    [view setTitle:NSLocalizedString(@"EVENT_ACTION_PARTICIPATE", nil) forState:UIControlStateNormal];
    
    {
        arrow = [UIImageView imageNamed:@"arrow-white-right"];
        CGRectSetXY(arrow.frame, CGRectGetWidth(self.frame) - 20, (CGRectGetHeight(view.frame) - arrow.image.size.height) / 2.);
        [view addSubview:arrow];
    }
    
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
    UIView *waitingView = [[self subviews] objectAtIndex:2];
    UIView *participateView = [[self subviews] objectAtIndex:3];
    
    refuseView.hidden = acceptView.hidden = waitingView.hidden = participateView.hidden = YES;
        
    if([_transaction isAcceptable]){
        refuseView.hidden = acceptView.hidden = NO;
    }
    else if(_transaction.isCollect && _transaction.collectCanParticipate){
        participateView.hidden = NO;
    }
    else{
        waitingView.hidden = NO;
    }
}

- (void)didAcceptTouch
{
    [_delegate acceptTransaction];
}

- (void)didRefuseTouch
{
    [_delegate refuseTransaction];
}

- (void)didParticipateTouch:(UIButton *)button
{
    if(button.selected){
        [self cancelParticipate];
    }
    else{
        button.selected = YES;
        [UIView animateWithDuration:.5 animations:^{
            [_delegate showPaymentField];
            arrow.transform = CGAffineTransformMakeRotation(M_PI_2);
        }];
    }
}

- (void)cancelParticipate
{
    UIButton *participateView = [[self subviews] objectAtIndex:3];
    participateView.selected = NO;
    [UIView animateWithDuration:.5 animations:^{
        [_delegate hidePaymentField];
        arrow.transform = CGAffineTransformMakeRotation(0);
    }];
}

- (void)setParticipateSelected:(BOOL)selected
{
    UIButton *participateView = [[self subviews] objectAtIndex:3];
    participateView.selected = selected;
    
    if(selected){
        arrow.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    else{
        arrow.transform = CGAffineTransformMakeRotation(0);
    }
}

@end
