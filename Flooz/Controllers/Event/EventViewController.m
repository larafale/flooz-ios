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
#import "EventAmountActionsView.h"
#import "EventHeaderView.h"
#import "EventUsersView.h"
#import "EventContentView.h"
#import "EventCommentsView.h"

#import "FLPaymentField.h"
#import "FLNewTransactionAmount.h"

#import "EventParticipantsViewController.h"
#import "FriendPickerViewController.h"

#import "CreditCardViewController.h"
#import "SecureCodeViewController.h"

#import "UIView+FindFirstResponder.h"

#define STATUSBAR_HEIGHT 20.

@interface EventViewController (){
    FLEvent *_event;
    NSIndexPath *_indexPath;
    
    UIView *_mainView;
    
    FLPaymentField *payementField;
    
    BOOL paymentFieldIsShown;
    
    FLNewTransactionAmount *amountInput;
    NSMutableDictionary *amount;
    
    NSMutableDictionary *_eventOfferUser;
    
    BOOL firstView;
    BOOL needReloadEvent;
    
    BOOL participationHidden;
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
        needReloadEvent = NO;
        
        amount = [NSMutableDictionary new];
        firstView = YES;
        participationHidden = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader:0.9];
    
    [self buildView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(firstView){
        _contentView.contentSize = CGSizeMake(0, CGRectGetMaxY(_mainView.frame) + 10);
        
        CGRectSetY(_contentView.frame, CGRectGetHeight(self.view.frame));
        
        [UIView animateWithDuration:0.3 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRectSetY(_contentView.frame, - 10);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
                CGRectSetY(_contentView.frame, STATUSBAR_HEIGHT);
            } completion:NULL];
        }];
        
        firstView = NO;
    }
    
    if(_eventOfferUser && [_eventOfferUser objectForKey:@"to"] && ![[_eventOfferUser objectForKey:@"to"] isBlank]){
        [self didOfferEvent];
    }
    
    if(needReloadEvent){
        [self reloadEvent];
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
    
        if([_event scope] == TransactionScopeFriend){
            [view setImage:[UIImage imageNamed:@"scope-friend"]];
            view.text = NSLocalizedString(@"EVENT_SCOPE_FRIEND", nil);
        }
        else{
            [view setImage:[UIImage imageNamed:@"scope-invite"]];
            view.text = NSLocalizedString(@"EVENT_SCOPE_PRIVATE", nil);
        }
        
        [view setImageOffset:CGPointMake(- 4, - 1)];
        [view setWidthToFit];
        CGRectSetX(view.frame, CGRectGetWidth(_contentView.frame) - CGRectGetWidth(view.frame) - 13);
        
        [_contentView addSubview:view];
    }
    
//    if([_event statusText]){
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
//        switch ([_event status]) {
//            case EventStatusAccepted:
//                textColor = [UIColor customGreen];
//                break;
//            case EventStatusPending:
//                textColor = [UIColor customYellow];
//                break;
//            case EventStatusRefused:
//                textColor = [UIColor customRed];
//                break;
//        }
//        
//        status.textColor = textColor;
//        
//        status.text = [NSString stringWithFormat:@"  %@", [_event statusText]]; // Hack pour mettre un padding
//        [status setWidthToFit];
//        CGRectSetWidth(status.frame, CGRectGetWidth(status.frame) + 30);
//        CGRectSetX(status.frame, CGRectGetWidth(_contentView.frame) - CGRectGetWidth(status.frame) - 13);
//        
//        [_contentView addSubview:status];
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
        EventHeaderView *view = [[EventHeaderView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.event = _event;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        CGFloat MARGE = 21.;
        EventAmountView *view = [[EventAmountView alloc] initWithFrame:CGRectMake(MARGE, height, CGRectGetWidth(_mainView.frame) - 2 * MARGE, 0)];
        view.event = _event;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    if(paymentFieldIsShown){
//        {
//            payementField = [[FLPaymentField alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0) for:nil key:nil];
//            payementField.delegate = self;
//            [_mainView addSubview:payementField];
//            height = CGRectGetMaxY(payementField.frame);
//        }
        {
            FLSwitchView *view = [[FLSwitchView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0) title:@"FIELD_TRANSACTION_HIDE"];
            [_mainView addSubview:view];
            view.delegate = self;
            height = CGRectGetMaxY(view.frame);
        }
        {
            amountInput = [[FLNewTransactionAmount alloc] initFor:amount key:@"amount" width:CGRectGetWidth(_mainView.frame) delegate:self];
            [_mainView addSubview:amountInput];
            CGRectSetY(amountInput.frame, height - 1);
            
            height = CGRectGetMaxY(amountInput.frame);
        }
    }
    else if([_event canParticipate] || [_event canCancelOffer] || [_event canAcceptOrDeclineOffer]){
        EventActionView *view = [[EventActionView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        view.event = _event;
        view.delegate = self;
        [_mainView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    if([_event canGiveOrTakeOffer]){
        EventAmountActionsView *view = [[EventAmountActionsView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
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
    
    CGRectSetHeight(_mainView.frame, height + 15);
    _contentView.contentSize = CGSizeMake(0, CGRectGetMaxY(_mainView.frame) + 10);
    
    [payementField didWalletTouch];
}

#pragma mark - FLPaymentFieldDelegate

- (void)didCreditCardSelected
{
    [amount setObject:[FLTransaction transactionPaymentMethodToParams:TransactionPaymentMethodCreditCard] forKey:@"source"];
}

- (void)didWalletSelected
{
    [amount setObject:[FLTransaction transactionPaymentMethodToParams:TransactionPaymentMethodWallet] forKey:@"source"];
}

- (void)presentCreditCardController
{
//    [amount setObject:[FLTransaction transactionPaymentMethodToParams:TransactionPaymentMethodCreditCard] forKey:@"source"]; // payementField disable
    
    CreditCardViewController *controller = [CreditCardViewController new];
    
    [self presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
}

#pragma mark - Actions

- (void)showPaymentField
{
    paymentFieldIsShown = YES;
    
    [self reloadEvent];
}

- (void)reloadEvent
{
    needReloadEvent = NO;
    for(UIView *view in [_contentView subviews]){
        [view removeFromSuperview];
    }
    [self buildView];
    
    [_delegateController updateEventAtIndex:_indexPath event:_event];
}

- (void)didUpdateEventWithAction:(EventAction)action
{
    CompleteBlock completeBlock = ^{
        [[Flooz sharedInstance] showLoadView];
        
        [[Flooz sharedInstance] eventAction:_event action:action success:^(id result) {
            [[Flooz sharedInstance] showLoadView];
            
            [[Flooz sharedInstance] eventWithId:[_event eventId] success:^(id result) {
                _event = [[FLEvent alloc] initWithJSON:[result objectForKey:@"item"]];
                paymentFieldIsShown = NO;
                [self reloadEvent];
            }];
        }];
    };
    
    if(action == EventActionTakeOffer){
        SecureCodeViewController *controller = [SecureCodeViewController new];
        controller.completeBlock = completeBlock;
        
        [self presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
    }
    else{
        completeBlock();
    }
}

- (void)acceptEvent
{
    NSMutableDictionary *params = [@{
                                     @"id": [_event eventId],
                                     //                             @"source": [amount objectForKey:@"source"] // payementField disable
                                     } mutableCopy];
    if([amount objectForKey:@"amount"]){
        [params setObject:[amount objectForKey:@"amount"] forKey:@"amount"];
    }
    
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] eventParticipateValidate:params success:^(id result) {
        
        id completeBlock = ^{
            [[Flooz sharedInstance] showLoadView];
            
            [[Flooz sharedInstance] eventParticipate:params success:^(id result) {
                [[Flooz sharedInstance] showLoadView];
                
                [[Flooz sharedInstance] eventWithId:[_event eventId] success:^(id result) {
                    _event = [[FLEvent alloc] initWithJSON:[result objectForKey:@"item"]];
                    paymentFieldIsShown = NO;
                    [self reloadEvent];
                }];
            }];
        };
        
        SecureCodeViewController *controller = [SecureCodeViewController new];
        controller.completeBlock = completeBlock;
        
        [self presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
        
    } noCreditCard:^{
        [self presentCreditCardController];
    }];
}

- (void)didAmountValidTouch
{
    [self acceptEvent];
}

- (void)didAmountCancelTouch
{
    paymentFieldIsShown = NO;
    [self reloadEvent];
}

- (void)presentEventParticipantsController
{
    needReloadEvent = YES;
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[[EventParticipantsViewController alloc] initWithEvent:_event]];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)presentFriendPickerViewControllerForOffer
{
    _eventOfferUser = [NSMutableDictionary new];
    FriendPickerViewController *controller = [FriendPickerViewController new];
    [controller setDictionary:_eventOfferUser];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)didOfferEvent
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] eventOffer:_event friend:_eventOfferUser success:^(id result) {
        
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] eventWithId:[_event eventId] success:^(id result) {
            _event = [[FLEvent alloc] initWithJSON:[result objectForKey:@"item"]];
            paymentFieldIsShown = NO;
            [self reloadEvent];
        }];
    }];
}

- (void)didSwitchViewSelected
{
    participationHidden = YES;
}

- (void)didSwitchViewUnselected
{
    participationHidden = NO;
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
    if([[[firstResponder superview] superview] isKindOfClass:[EventCommentsView class]]){
        _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        CGFloat y = _contentView.contentSize.height - (CGRectGetHeight(_contentView.frame) - keyboardHeight);
        [_contentView setContentOffset:CGPointMake(0, MAX(y, 0)) animated:YES];
    }
    else if([[firstResponder superview] isKindOfClass:[FLNewTransactionAmount class]]){
        _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        [_contentView setContentOffset:CGPointMake(0, firstResponder.superview.frame.origin.y) animated:YES];
    }
}

- (void)keyboardWillDisappear
{
    _contentView.contentInset = UIEdgeInsetsZero;
}

@end
