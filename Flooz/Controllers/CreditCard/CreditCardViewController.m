//
//  CreditCardViewController.m
//  Flooz
//
//  Created by jonathan on 2/20/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "CreditCardViewController.h"
#import "FLTextFieldTitle2.h"

#define OFFSET 30

@interface CreditCardViewController (){
    FLCreditCard *creditCard;
    NSMutableDictionary *_card;
    NSMutableArray *fieldsView;
}

@end

@implementation CreditCardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_CREDIT_CARD", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self registerForKeyboardNotifications];
    
    self.view.backgroundColor = [UIColor customBackground];
    
    FLUser *currentUser = [[Flooz sharedInstance] currentUser];
    if([currentUser creditCard]){
        creditCard = [currentUser creditCard];
        [self prepareViewForDelete];
    }
    else{
        [self prepareViewForCreate];
    }
    
    [self refreshTitle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshTitle
{
    FLUser *currentUser = [[Flooz sharedInstance] currentUser];
    if([currentUser creditCard]){
        self.title = NSLocalizedString(@"NAV_CREDIT_CARD", nil);
    }
    else{
        self.title = NSLocalizedString(@"NAV_CREDIT_CARD_ADD", nil);
    }
}

- (void)resetContentView
{
    _card = [NSMutableDictionary new];
    fieldsView = [NSMutableArray new];
    for(UIView *view in [_contentView subviews]){
        [view removeFromSuperview];
    }
    
    _card[@"holder"] = [[[Flooz sharedInstance] currentUser] fullname];
}

- (void)prepareViewForCreate
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(didValidTouch)];
    [self resetContentView];
    CGFloat height = 0;
    
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(_contentView.frame), 135)];
        view.backgroundColor = [UIColor customBackgroundHeader];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
        
        {
            CGFloat MARGE_LEFT_RIGHT = 28;
            CGFloat MARGE_TOP_BOTTOM = 40;
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, MARGE_TOP_BOTTOM, CGRectGetWidth(view.frame) - (2 * MARGE_LEFT_RIGHT), CGRectGetHeight(view.frame) - (2 * MARGE_TOP_BOTTOM))];
            
            button.backgroundColor = [UIColor customBackgroundStatus];
            [button setTitle:NSLocalizedString(@"CREDIT_CARD_SCAN", Nil) forState:UIControlStateNormal];
            
            button.titleLabel.font = [UIFont customTitleExtraLight:14];
            
            [button addTarget:self action:@selector(presentScanPayViewController) forControlEvents:UIControlEventTouchUpInside];
            
            [view addSubview:button];
        }
    }
    
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_CARD_OWNER" placeholder:@"FIELD_CARD_OWNER_PLACEHOLDER" for:_card key:@"holder" position:CGPointMake(20, height + 25)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
        
        [fieldsView addObject:view];
        
        [view addForNextClickTarget:self action:@selector(didOwnerEndEditing)];
    }
    
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_CARD_NUMBER" placeholder:@"FIELD_CARD_NUMBER_PLACEHOLDER" for:_card key:@"number" position:CGPointMake(20, height + OFFSET)];
        [view setKeyboardType:UIKeyboardTypeDecimalPad];
        [_contentView  addSubview:view];
        height = CGRectGetMaxY(view.frame);
        
        [fieldsView addObject:view];
        
        [view setStyle:FLTextFieldTitle2StyleCardNumber];
        [view addForNextClickTarget:self action:@selector(didNumberEndEditing)];
    }
    
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_CARD_EXPIRES" placeholder:@"FIELD_CARD_EXPIRES_PLACEHOLDER" for:_card key:@"expires" position:CGPointMake(20, height + OFFSET)];
        [view setKeyboardType:UIKeyboardTypeDecimalPad];
        [_contentView  addSubview:view];
        height = CGRectGetMaxY(view.frame);
        
        [fieldsView addObject:view];
        
        [view setStyle:FLTextFieldTitle2StyleCardExpire];
        [view addForNextClickTarget:self action:@selector(didExpiresEndEditing)];
    }
    
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_CARD_CVV" placeholder:@"FIELD_CARD_CVV_PLACEHOLDER" for:_card key:@"cvv" position:CGPointMake(20, height + OFFSET)];
        [view setKeyboardType:UIKeyboardTypeDecimalPad];
        [_contentView  addSubview:view];
        height = CGRectGetMaxY(view.frame);
        
        [view setStyle:FLTextFieldTitle2StyleCVV];
        [fieldsView addObject:view];
        
        [view addForNextClickTarget:self action:@selector(didCVVEndEditing)];
    }
    
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), height);
}

- (void)prepareViewForDelete
{
    self.navigationItem.rightBarButtonItem = nil;
    [self resetContentView];
    
    {
        CGFloat MARGE_LEFT_RIGHT = 27;
        
        UIImageView *view = [UIImageView imageNamed:@"card-background"];
        CGRectSetXY(view.frame, MARGE_LEFT_RIGHT, 20);
  
        [_contentView addSubview:view];
        
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 62, SCREEN_WIDTH - 30, 30)];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont customTitleExtraLight:24];
            
            NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc]initWithString:creditCard.number];
            [attributedString addAttribute:NSKernAttributeName value:@(2.5) range:NSMakeRange(0, attributedString.length)];

            label.attributedText = attributedString;
//            [label setWidthToFit];
            [view addSubview:label];
        }
        
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 110, 0, 30)];
            label.textColor = [UIColor customPlaceholder];
            
            label.font = [UIFont customContentRegular:12];
            label.text = [creditCard.owner uppercaseString];
            [label setWidthToFit];
            [view addSubview:label];
        }
    }
    
    {
        CGFloat MARGE_LEFT_RIGHT = 25;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, 247,CGRectGetWidth(_contentView.frame) - (2 * MARGE_LEFT_RIGHT), 40)];
        
        button.backgroundColor = [UIColor customBackgroundStatus];
        [button setTitle:NSLocalizedString(@"CREDIT_CARD_REMOVE", Nil) forState:UIControlStateNormal];
        
        [button setImage:[UIImage imageNamed:@"trash"] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
        
        button.titleLabel.font = [UIFont customTitleExtraLight:14];
        
        [button addTarget:self action:@selector(didRemoveCardTouch) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:button];
    }
}

#pragma mark - CARDIO

//- (void)presentCardIOViewController
//{
//    CardIOPaymentViewController *controller = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
//    controller.appToken = @"368ed39eca23472ab19ad62823e63cb0";
//    
//    [self presentViewController:controller animated:YES completion:NULL];
//}
//
//- (void)userDidCancelPaymentViewController:(id *)paymentViewController
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)userDidProvideCreditCardInfo:(id *)cardInfo inPaymentViewController:(id *)paymentViewController
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//    
//    [_card setValue:cardInfo.cardNumber forKey:@"number"];
//    [_card setValue:cardInfo.cvv forKey:@"cvv"];
//    
//    NSString *expires = [NSString stringWithFormat:@"%.2ld-%.2lu", cardInfo.expiryMonth, cardInfo.expiryYear - 2000];
//    
//    [_card setValue:expires forKey:@"expires"];
//    
//    for(FLTextFieldTitle2 *view in fieldsView){
//        [view reloadData];
//    }
//    
//    [[fieldsView objectAtIndex:0] becomeFirstResponder];
//}

#pragma mark - ScanPay

- (void)presentScanPayViewController
{
    ScanPayViewController * scanPayViewController = [[ScanPayViewController alloc] initWithToken:@"be38035037ed6ca3cba7089b" useConfirmationView:YES useManualEntry:YES];
    
    [scanPayViewController startScannerWithViewController:self success:^(SPCreditCard * card){
        
        [_card setValue:card.number forKey:@"number"];
        [_card setValue:card.cvc forKey:@"cvv"];
        
        NSString *expires = [NSString stringWithFormat:@"%@-%@", card.month, card.year];
        
        [_card setValue:expires forKey:@"expires"];
        
        for(FLTextFieldTitle2 *view in fieldsView){
            [view reloadData];
        }
        
        [[fieldsView objectAtIndex:0] becomeFirstResponder];
        
    } cancel:^{
       [[fieldsView objectAtIndex:0] becomeFirstResponder]; 
    }];
}

#pragma mark -

- (void)didValidTouch
{
    [[self view] endEditing:YES];
        
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createCreditCard:_card success:^(id result) {
        FLUser *currentUser = [[Flooz sharedInstance] currentUser];
        creditCard = [currentUser creditCard];
        [self dismiss];
    }];
}

- (void)didRemoveCardTouch
{
    NSString *creditCardId = [[[[Flooz sharedInstance] currentUser] creditCard] cardId];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] removeCreditCard:creditCardId success:^(id result) {
        creditCard = nil;
        [[[Flooz sharedInstance] currentUser] setCreditCard:nil];
        [self prepareViewForCreate];
    }];
}

- (void)dismiss
{
    if([self navigationController]){
        if([[[self navigationController] viewControllers] count] == 1){
            [[self navigationController] dismissViewControllerAnimated:YES completion:NULL];
        }
        else{
            [[self navigationController] popViewControllerAnimated:YES];
        }
    }
    else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
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
}

- (void)keyboardWillDisappear
{
    _contentView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - Field callback

- (void)didOwnerEndEditing
{
    [fieldsView[1] becomeFirstResponder];
}

- (void)didNumberEndEditing
{
    [fieldsView[2] becomeFirstResponder];
}

- (void)didExpiresEndEditing
{
    [fieldsView[3] becomeFirstResponder];
}

- (void)didCVVEndEditing
{
    UIView *validView = [[[self.navigationItem.rightBarButtonItem customView] subviews] firstObject];
    CGFloat duration = .2;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         validView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:duration
                                               delay:0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              validView.transform = CGAffineTransformIdentity;
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:duration
                                                                    delay:0
                                                                  options:UIViewAnimationOptionAllowUserInteraction
                                                               animations:^{
                                                                   validView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:duration
                                                                                         delay:0
                                                                                       options:UIViewAnimationOptionAllowUserInteraction
                                                                                    animations:^{
                                                                                        validView.transform = CGAffineTransformIdentity;
                                                                                    }
                                                                                    completion:nil];
                                                               }];
                                          }];
                     }];
}

@end
