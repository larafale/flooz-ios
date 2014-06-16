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
    
    
    UIButton *closeButton;
    JTImageLabel *scopeView;
    EventHeaderView *headerView;
    EventAmountView *amountView;
    FLSwitchView *switchView;
    EventActionView *actionView;
    EventAmountActionsView *amountActionView;
    EventUsersView *usersView;
    EventContentView *eventContentView;
    EventCommentsView *commentsView;
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
    for(UIView *view in [_contentView subviews]){
        [view removeFromSuperview];
    }
    
    {
        closeButton = [[UIButton alloc] initWithFrame:CGRectMake(134, 20, 52, 52)];
        
        [closeButton setImage:[UIImage imageNamed:@"transaction-close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:closeButton];
    }
    
//    {
//        scopeView = [[JTImageLabel alloc] initWithFrame:CGRectMake(0, 55, 0, 15)];
//        
//        scopeView.textAlignment = NSTextAlignmentRight;
//        scopeView.textColor = [UIColor whiteColor];
//        scopeView.font = [UIFont customContentLight:11];
//    
//        if([_event scope] == TransactionScopeFriend){
//            [scopeView setImage:[UIImage imageNamed:@"scope-friend"]];
//            scopeView.text = NSLocalizedString(@"EVENT_SCOPE_FRIEND", nil);
//        }
//        else{
//            [scopeView setImage:[UIImage imageNamed:@"scope-invite"]];
//            scopeView.text = NSLocalizedString(@"EVENT_SCOPE_PRIVATE", nil);
//        }
//        
//        [scopeView setImageOffset:CGPointMake(- 4, - 1)];
//        [scopeView setWidthToFit];
//        CGRectSetX(scopeView.frame, CGRectGetWidth(_contentView.frame) - CGRectGetWidth(scopeView.frame) - 13);
//        
//        [_contentView addSubview:scopeView];
//    }
    
    {
        JTImageLabel *view = [[JTImageLabel alloc] initWithFrame:CGRectMake(0, 55, 0, 15)];
        
        view.textAlignment = NSTextAlignmentRight;
        view.textColor = [UIColor whiteColor];
        view.font = [UIFont customContentLight:11];
        
        view.text = [FLHelper formatedDate:[_event date]];
        [view setImage:[UIImage imageNamed:@"transaction-content-clock"]];
        [view setImageOffset:CGPointMake(- 4, 0)];
        
        [view setWidthToFit];
        CGRectSetX(view.frame, CGRectGetWidth(_contentView.frame) - CGRectGetWidth(view.frame) - 13);
        
        [_contentView addSubview:view];
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
        headerView = [[EventHeaderView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        headerView.event = _event;
        [_mainView addSubview:headerView];
        height = CGRectGetMaxY(headerView.frame);
    }
    
    {
        CGFloat MARGE = 21.;
        amountView = [[EventAmountView alloc] initWithFrame:CGRectMake(MARGE, height, CGRectGetWidth(_mainView.frame) - 2 * MARGE, 0)];
        amountView.event = _event;
        [_mainView addSubview:amountView];
        height = CGRectGetMaxY(amountView.frame);
    }
    
    
    {
        actionView = [[EventActionView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        actionView.event = _event;
        actionView.delegate = self;
        [_mainView addSubview:actionView];
        
        [actionView setSelected:paymentFieldIsShown];
        
        actionView.hidden = YES;
    }
    {
        switchView = [[FLSwitchView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0) title:@"FIELD_TRANSACTION_HIDE"];
        [_mainView addSubview:switchView];
        switchView.delegate = self;

//        switchView.hidden = YES;
    }
    {
        amountInput = [[FLNewTransactionAmount alloc] initFor:amount key:@"amount" width:CGRectGetWidth(_mainView.frame) delegate:self];
        [_mainView addSubview:amountInput];
        CGRectSetY(amountInput.frame, height - 1);
        
//        amountInput.hidden = YES;
    }
    
    if([_event canParticipate] || [_event canCancelOffer] || [_event canAcceptOrDeclineOffer]){
        height = CGRectGetMaxY(actionView.frame);
        actionView.hidden = NO;
    }
    else{
        actionView.hidden = YES;
    }
    
    if(paymentFieldIsShown){
//        switchView.hidden = NO;
//        amountInput.hidden = NO;
        
        CGRectSetY(switchView.frame, height);
        height = CGRectGetMaxY(switchView.frame);
        CGRectSetY(amountInput.frame, height - 1);
        height = CGRectGetMaxY(amountInput.frame);
    }
    else{
//        switchView.hidden = YES;
//        amountInput.hidden = YES;
        
        CGRectSetY(switchView.frame, height);
        CGRectSetY(amountInput.frame, CGRectGetMaxY(switchView.frame) - 1);
        
        CGRectSetHeight(switchView.frame, 0);
        CGRectSetHeight(amountInput.frame, 0);
    }
    
    {
        amountActionView = [[EventAmountActionsView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        amountActionView.event = _event;
        amountActionView.delegate = self;
        [_mainView addSubview:amountActionView];
        
        amountActionView.hidden = YES;
    }
    
    if([_event canGiveOrTakeOffer]){
        height = CGRectGetMaxY(amountActionView.frame);
        amountActionView.hidden = NO;
    }

    {
        usersView = [[EventUsersView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        usersView.event = _event;
        usersView.delegate = self;
        [_mainView addSubview:usersView];
        height = CGRectGetMaxY(usersView.frame);
    }
    
    {
        eventContentView = [[EventContentView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        eventContentView.event= _event;
        [_mainView addSubview:eventContentView];
        height = CGRectGetMaxY(eventContentView.frame);
        
        [eventContentView addTargetForLike:self action:@selector(didLikeEvent)];
    }
    
    {
        commentsView = [[EventCommentsView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_mainView.frame), 0)];
        commentsView.event = _event;
        commentsView.delegate = self;
        [_mainView addSubview:commentsView];
        height = CGRectGetMaxY(commentsView.frame);
    }
    
    CGRectSetHeight(_mainView.frame, height + 15);
    _contentView.contentSize = CGSizeMake(0, CGRectGetMaxY(_mainView.frame) + 10);
    
    [payementField didWalletTouch];
}

- (void)reloadViewsForShowPayment
{
    CGFloat height = CGRectGetMaxY(amountView.frame);
    
    if([_event canParticipate] || [_event canCancelOffer] || [_event canAcceptOrDeclineOffer]){
        CGRectSetY(actionView.frame, height);
        height = CGRectGetMaxY(actionView.frame);
        actionView.hidden = NO;
    }
    else{
        actionView.hidden = YES;
    }
    
    if(paymentFieldIsShown){
//        switchView.hidden = NO;
//        amountInput.hidden = NO;
        
        CGRectSetY(switchView.frame, height);
        CGRectSetHeight(switchView.frame, [FLSwitchView height]);
        height = CGRectGetMaxY(switchView.frame);
        
        CGRectSetY(amountInput.frame, height - 1);
        CGRectSetHeight(amountInput.frame, [FLNewTransactionAmount height]);
        height = CGRectGetMaxY(amountInput.frame);
    }
    else{
//        switchView.hidden = YES;
//        amountInput.hidden = YES;
        
        CGRectSetHeight(switchView.frame, 0);
        CGRectSetHeight(amountInput.frame, 0);
    }
    
    if([_event canGiveOrTakeOffer]){
        CGRectSetY(amountActionView.frame, height);
        height = CGRectGetMaxY(amountActionView.frame);
        amountActionView.hidden = NO;
    }
    else{
        amountActionView.hidden = YES;
    }
    
    {
        CGRectSetY(usersView.frame, height);
        height = CGRectGetMaxY(usersView.frame);
    }
    
    {
        CGRectSetY(eventContentView.frame, height);
        height = CGRectGetMaxY(eventContentView.frame);
    }
    
    {
        CGRectSetY(commentsView.frame, height);
        height = CGRectGetMaxY(commentsView.frame);
    }
    
    CGRectSetHeight(_mainView.frame, height + 15);
    _contentView.contentSize = CGSizeMake(0, CGRectGetMaxY(_mainView.frame) + 10);
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
    
    [self reloadViewsForShowPayment];
}

- (void)hidePaymentField
{
    paymentFieldIsShown = NO;
    
    [amountInput resignFirstResponder];

    [self reloadViewsForShowPayment];
}

- (void)reloadEvent
{
    needReloadEvent = NO;
 
    [self buildView];
    
    if(_indexPath){
        [_delegateController updateEventAtIndex:_indexPath event:_event];
    }
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
        params[@"amount"] = [amount objectForKey:@"amount"];
        params[@"hide"] = [NSNumber numberWithBool:participationHidden];
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

- (void)didLikeEvent
{
    if(_indexPath){
        [_delegateController updateEventAtIndex:_indexPath event:_event];
    }
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
