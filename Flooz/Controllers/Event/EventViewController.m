//
//  EventViewController.m
//  Flooz
//
//  Created by jonathan on 2/25/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventViewController.h"

#import "EventActionView.h"
#import "EventAmountView.h"
#import "EventHeaderView.h"
#import "EventUsersView.h"
#import "EventContentView.h"
#import "EventCommentsView.h"

#import "FLPaymentField.h"
#import "FLNewTransactionAmount.h"

#import "EventParticipantsViewController.h"

#define STATUSBAR_HEIGHT 20.

@interface EventViewController (){
    FLEvent *_event;
    NSIndexPath *_indexPath;
    
    UIScrollView *_contentView;
    UIView *_mainView;
    
    BOOL paymentFieldIsShown;
    BOOL amountFieldIsShown;
    
    FLNewTransactionAmount *amountInput;
    NSMutableDictionary *amount;
    
    BOOL firstView;
}

@end

@implementation EventViewController

- (id)initWithEvent:(FLEvent *)event indexPath:(NSIndexPath *)indexPath
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _event = event;
        _indexPath = indexPath;
        paymentFieldIsShown = NO;
        amountFieldIsShown = NO;
        
        amount = [NSMutableDictionary new];
        firstView = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader:0.9];
    
    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - STATUSBAR_HEIGHT)];
    
    [self.view addSubview:_contentView];
    
    {
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(134, 20, 52, 52)];
        
        [closeButton setImage:[UIImage imageNamed:@"transaction-close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:closeButton];
    }
    
    if([_event statusText]){
        UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 0, 18)];
        status.backgroundColor = [UIColor customBackground];
        status.layer.borderColor = [UIColor customSeparator].CGColor;
        status.layer.borderWidth = 1.;
        status.layer.cornerRadius = 9.;
        status.font = [UIFont customTitleBook:10];
        status.textAlignment = NSTextAlignmentCenter;
        
        UIColor *textColor = [UIColor whiteColor];
        
        switch ([_event status]) {
            case EventStatusAccepted:
                textColor = [UIColor customGreen];
                break;
            case EventStatusPending:
                textColor = [UIColor customYellow];
                break;
            case EventStatusRefused:
                textColor = [UIColor whiteColor];
                break;
        }
        
        status.textColor = textColor;
        
        status.text = [_event statusText];
        [status setWidthToFit];
        status.frame = CGRectSetWidth(status.frame, CGRectGetWidth(status.frame) + 20);
        status.frame = CGRectSetX(status.frame, CGRectGetWidth(self.view.frame) - CGRectGetWidth(status.frame) - 13);
        
        [_contentView addSubview:status];
    }
    
    
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
        EventHeaderView *view = [[EventHeaderView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.event = _event;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    
    if(paymentFieldIsShown){
        FLPaymentField *view = [[FLPaymentField alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0) for:nil key:nil];
        view.delegate = self;
        view.backgroundColor = [UIColor customBackground:0.4];
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    else if(amountFieldIsShown){
        amountInput = [[FLNewTransactionAmount alloc] initFor:amount key:@"amount" width:CGRectGetWidth(_mainView.frame) delegate:self];
        [_mainView addSubview:amountInput];
        amountInput.frame = CGRectSetY(amountInput.frame, height - 1);
        
        height = CGRectGetMaxY(amountInput.frame);
    }
    else if([_event isRefusable] || [_event isAcceptable]){
        EventActionView *view = [[EventActionView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.event = _event;
        view.delegate = self;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        EventUsersView *view = [[EventUsersView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.event = _event;
        view.delegate = self;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        EventAmountView *view = [[EventAmountView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.event = _event;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }

    {
        EventContentView *view = [[EventContentView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.event= _event;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        EventCommentsView *view = [[EventCommentsView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.event= _event;
        view.delegate = self;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    _mainView.frame = CGRectSetHeight(_mainView.frame, height + 15);
    _contentView.contentSize = CGSizeMake(0, CGRectGetMaxY(_mainView.frame) + 10);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(firstView){
        _contentView.frame = CGRectMake(0, STATUSBAR_HEIGHT, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - STATUSBAR_HEIGHT);
        _contentView.contentSize = CGSizeMake(0, CGRectGetMaxY(_mainView.frame) + 10);
        
        _contentView.frame = CGRectSetY(_contentView.frame, CGRectGetHeight(self.view.frame));
        
        [UIView animateWithDuration:0.3 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
            _contentView.frame = CGRectSetY(_contentView.frame, - 10);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
                _contentView.frame = CGRectSetY(_contentView.frame, STATUSBAR_HEIGHT);
            } completion:NULL];
        }];
        
        firstView = NO;
    }
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - FLPaymentFieldDelegate

- (void)didCreditCardSelected
{
    [amount setObject:[FLTransaction transactionPaymentMethodToParams:TransactionPaymentMethodCreditCard] forKey:@"source"];
    
    if([[_event amount] floatValue] == 0){
        [self showAmountField];
    }
    else{
        [self acceptEvent];
    }
}

- (void)didWalletSelected
{
    [amount setObject:[FLTransaction transactionPaymentMethodToParams:TransactionPaymentMethodWallet] forKey:@"source"];
    
    if([[_event amount] floatValue] == 0){
        [self showAmountField];
    }
    else{
        [self acceptEvent];
    }
}

#pragma mark - Actions

- (void)showPaymentField
{
    paymentFieldIsShown = YES;
    amountFieldIsShown = NO;
    
    [self reloadEvent];
}

- (void)showAmountField
{
    paymentFieldIsShown = NO;
    amountFieldIsShown = YES;
    
    [self reloadEvent];
}

- (void)reloadEvent{
    // WARNING
    for(UIView *view in [self.view subviews]){
        [view removeFromSuperview];
    }
    [self loadView];
    
    [_delegateController updateEventAtIndex:_indexPath event:_event];
}

- (void)refuseEvent
{
    [[Flooz sharedInstance] showLoadView];

    [[Flooz sharedInstance] eventDecline:_event success:^(id result) {
        [[Flooz sharedInstance] showLoadView];
        
        [[Flooz sharedInstance] eventWithId:[_event eventId] success:^(id result) {
            _event = [[FLEvent alloc] initWithJSON:[result objectForKey:@"item"]];
            paymentFieldIsShown = NO;
            amountFieldIsShown = NO;
            [self reloadEvent];
        }];
    }];
}

- (void)acceptEvent
{
    [[Flooz sharedInstance] showLoadView];
    
    NSMutableDictionary *params = [@{
                             @"id": [_event eventId],
                             @"source": [amount objectForKey:@"source"]
                             } mutableCopy];
    
    if([amount objectForKey:@"amount"]){
        [params setObject:[amount objectForKey:@"amount"] forKey:@"amount"];
    }
        
    [[Flooz sharedInstance] eventParticipate:params success:^(id result) {
        [[Flooz sharedInstance] showLoadView];
        
        [[Flooz sharedInstance] eventWithId:[_event eventId] success:^(id result) {
            _event = [[FLEvent alloc] initWithJSON:[result objectForKey:@"item"]];
            paymentFieldIsShown = NO;
            amountFieldIsShown = NO;
            [self reloadEvent];
        }];
    }];
}

- (void)didAmountValidTouch
{
    [self acceptEvent];
}

- (void)didAmountCancelTouch
{
    paymentFieldIsShown = NO;
    amountFieldIsShown = NO;
    [self reloadEvent];
}

- (void)presentEventParticipantsController
{
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[[EventParticipantsViewController alloc] initWithEvent:_event]];
    [self presentViewController:controller animated:YES completion:NULL];
}

@end
