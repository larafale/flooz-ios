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
    FLNewTransactionAmountInput *amountInput;
    FLTextView *content;
    
    FLSelectFriendButton *friend;
    BOOL infoDisplayed;
    BOOL firstView;
    BOOL firstViewAmount;
}

@end

@implementation NewTransactionViewController

- (id)initWithTransactionType:(TransactionType)transactionType
{
    return [self initWithTransactionType:transactionType user:nil];
}

- (id)initWithTransactionType:(TransactionType)transactionType user:(FLUser *)user
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"NEW_TRANSACTION", nil);
        transaction = [NSMutableDictionary new];
        
        transaction[@"random"] = [FLHelper generateRandomString];

        isEvent = NO;
//        isEvent = (transactionType == TransactionTypeEvent);
        [transaction setValue:[FLTransaction transactionTypeToParams:transactionType] forKey:@"method"];
        
        infoDisplayed = NO;
        firstView = YES;
        firstViewAmount = YES;
        
        if(user){
            transaction[@"to"] = [user username];
            transaction[@"toTitle"] = [user fullname];
            
            if([user avatarURL]){
                transaction[@"toImageUrl"] = [user avatarURL];
            }
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self.view.backgroundColor = [UIColor customBackground];
    
    transactionBarKeyboard = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self actionSend:@selector(validSendMoney) actionCollect:@selector(validCollectMoney)];
    
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
        
        
        
        
        if(!isEvent){
            CGRect frameFriend = CGRectMake(0, 0, PPScreenWidth() - 130, 50);
            friend = [[FLSelectFriendButton alloc] initWithFrame:frameFriend dictionary:transaction];
            friend.delegate = self;
            
            [_contentView addSubview:friend];
            
            offset = CGRectGetMaxY(friend.frame);
        }
        
        CGRect frameAmount = CGRectMake(CGRectGetMaxX(friend.frame), CGRectGetMinY(friend.frame), PPScreenWidth() - CGRectGetMaxX(friend.frame), CGRectGetHeight(friend.frame));
        if(isEvent){
            amountInput = [[FLNewTransactionAmountInput alloc] initWithPlaceholder:@"0" for:transaction key:@"goal" currencySymbol:NSLocalizedString(@"GLOBAL_EURO", nil) andFrame:frameAmount delegate:nil];
            [amountInput hideSeparatorTop];
        }
        else{
            amountInput = [[FLNewTransactionAmountInput alloc] initWithPlaceholder:@"0" for:transaction key:@"amount" currencySymbol:NSLocalizedString(@"GLOBAL_EURO", nil) andFrame:frameAmount delegate:nil];
            //amountInput = [[FLNewTransactionAmountInput alloc] initFor:transaction key:@"amount"];
            [amountInput hideSeparatorTop];
        }
        {
            [amountInput setInputAccessoryView:transactionBarKeyboard];
            [_contentView addSubview:amountInput];
            //CGRectSetX(amountInput.frame, PPScreenWidth() - 110);
            //CGRectSetWidth(amountInput.frame, PPScreenWidth() - CGRectGetMinX(amountInput.frame));
            CGRectSetY(amountInput.frame, CGRectGetMinY(friend.frame));
            offset = CGRectGetMaxY(amountInput.frame);
        }
        
        NSString *contentPlaceholder = @"FIELD_TRANSACTION_CONTENT_PLACEHOLDER";
        if(isEvent){
            contentPlaceholder = @"FIELD_TRANSACTION_EVENT_PLACEHOLDER";
        }
        
        content = [[FLTextView alloc] initWithPlaceholder:contentPlaceholder for:transaction key:@"why" position:CGPointMake(0, offset - 1)];
        [content setInputAccessoryView:transactionBarKeyboard];
        [_contentView addSubview:content];
        
        transactionBar = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self actionSend:@selector(validSendMoney) actionCollect:@selector(validCollectMoney)];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame));
    
    [friend reloadData];
    [self reloadTransactionBarData];

    [self registerNotification:@selector(reloadTransactionBarData) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(reloadTransactionBarData) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame));
    if([appDelegate showPreviewImage:@"preview-4"]){
        
    }
    else if([transaction objectForKey:@"toTitle"]){
        
        [UIView animateWithDuration:.15
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             _navBar.validView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:.15
                                                   delay:0
                                                 options:UIViewAnimationOptionAllowUserInteraction
                                              animations:^{
                                                  _navBar.validView.transform = CGAffineTransformIdentity;
                                              }
                                              completion:^(BOOL finished) {
                                                  [UIView animateWithDuration:.15
                                                                        delay:0
                                                                      options:UIViewAnimationOptionAllowUserInteraction
                                                                   animations:^{
                                                                       _navBar.validView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       [UIView animateWithDuration:.15
                                                                                             delay:0
                                                                                           options:UIViewAnimationOptionAllowUserInteraction
                                                                                        animations:^{
                                                                                            _navBar.validView.transform = CGAffineTransformIdentity;
                                                                                        }
                                                                                        completion:^(BOOL finished) {
                                                                                            if(!infoDisplayed){
//                                                                                                [content becomeFirstResponder];
                                                                                                infoDisplayed = YES;
                                                                                            }
                                                                                            
                                                                                        }];
                                                                   }];
                                              }];
                         }];
        
        if(firstViewAmount){
            [amountInput becomeFirstResponder];
            firstViewAmount = NO;
        }
    }
    else if(!isEvent){
        if(firstView){
            [friend didButtonTouch];
            firstView = NO;
        }
        else if(firstViewAmount){
            [amountInput becomeFirstResponder];
            firstViewAmount = NO;
        }
    }
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

- (void)validSendMoney {
    [transaction setValue:[FLTransaction transactionTypeToParams:TransactionTypePayment] forKey:@"method"];
    [self valid];
}

- (void)validCollectMoney {
    [transaction setValue:[FLTransaction transactionTypeToParams:TransactionTypeCharge] forKey:@"method"];
    [self valid];
}

- (void)valid
{
    [[self view] endEditing:YES];
    
    if(isEvent){
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] createEvent:transaction success:^(id result) {
            FLEvent *event = [[FLEvent alloc] initWithJSON:result[@"item"]];
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"reloadEvents" object:nil]];
            
            [self dismissViewControllerAnimated:YES completion:^{
                FLContainerViewController *rootController = (FLContainerViewController *)appDelegate.window.rootViewController;
                [rootController.navbarView loadControllerWithIndex:2];
                
                EventViewController *controller = [[EventViewController alloc] initWithEvent:event indexPath:nil];
                
                rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
                
                [rootController presentViewController:controller animated:NO completion:^{
                    rootController.modalPresentationStyle = UIModalPresentationFullScreen;
                }];                
            }];
        } failure:NULL];
    }
    else{
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] createTransactionValidate:transaction success:^(id result) {
            
            if([result objectForKey:@"confirmationText"]){
                FLPopup *popup = [[FLPopup alloc] initWithMessage:[result objectForKey:@"confirmationText"] accept:^{
                    [self didTransactionValidated];
                } refuse:NULL];
                [popup show];
                
//                UIAlertView *alertView = [[UIAlertView alloc]
//                                          initWithTitle:nil
//                                          message:[result objectForKey:@"confirmationText"]
//                                          delegate:self
//                                          cancelButtonTitle:NSLocalizedString(@"GLOBAL_NO", nil)
//                                          otherButtonTitles:NSLocalizedString(@"GLOBAL_YES", nil), nil];
//                
//                [alertView show];
            }
            else{
                [self didTransactionValidated];
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
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
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

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [self didTransactionValidated];
    }
}

- (void)didTransactionValidated
{
    CompleteBlock completeBlock = ^{
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] createTransaction:transaction success:^(id result) {
            FLContainerViewController *presentingViewController = (FLContainerViewController *)[self presentingViewController];
            TimelineViewController *timelineController = [[presentingViewController viewControllers] objectAtIndex:1];
            [self dismissViewControllerAnimated:YES completion:^{
                if([[transaction objectForKey:@"method"] isEqualToString:[FLTransaction transactionTypeToParams:TransactionTypePayment]]){
                    [[timelineController filterView] selectFilter:2];
                    FLContainerViewController *rootController = (FLContainerViewController *)appDelegate.window.rootViewController;
                    [rootController.navbarView loadControllerWithIndex:1];
                }
            }];
        } failure:NULL];
    };
    
    SecureCodeViewController *controller = [SecureCodeViewController new];
    controller.completeBlock = completeBlock;
    [self presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
    //[self presentViewController:controller animated:YES completion:NULL];
}

@end
