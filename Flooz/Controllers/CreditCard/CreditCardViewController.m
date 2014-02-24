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
    
    self.view.backgroundColor = [UIColor customBackground];
    
    FLUser *currentUser = [[Flooz sharedInstance] currentUser];
    if([currentUser creditCard]){
        creditCard = [currentUser creditCard];
        [self prepareViewForDelete];
    }
    else{
        [self prepareViewForCreate];
    }
}

- (void)resetContentView
{
    _card = [NSMutableDictionary new];
    fieldsView = [NSMutableArray new];
    for(UIView *view in [_contentView subviews]){
        [view removeFromSuperview];
    }
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
            
            [button addTarget:self action:@selector(presentCardIOViewController) forControlEvents:UIControlEventTouchUpInside];
            
            [view addSubview:button];
        }
    }
    
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_CARD_OWNER" placeholder:@"FIELD_CARD_OWNER_PLACEHOLDER" for:_card key:@"holder" position:CGPointMake(20, height + 25)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
        
        [fieldsView addObject:view];
    }
    
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_CARD_NUMBER" placeholder:@"FIELD_CARD_NUMBER_PLACEHOLDER" for:_card key:@"number" position:CGPointMake(20, height + OFFSET)];
        [_contentView  addSubview:view];
        height = CGRectGetMaxY(view.frame);
        
        [fieldsView addObject:view];
    }
    
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_CARD_EXPIRES" placeholder:@"FIELD_CARD_EXPIRES_PLACEHOLDER" for:_card key:@"expires" position:CGPointMake(20, height + OFFSET)];
        [_contentView  addSubview:view];
        height = CGRectGetMaxY(view.frame);
        
        [fieldsView addObject:view];
    }
    
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_CARD_CVV" placeholder:@"FIELD_CARD_CVV_PLACEHOLDER" for:_card key:@"cvv" position:CGPointMake(20, height + OFFSET)];
        [_contentView  addSubview:view];
        height = CGRectGetMaxY(view.frame);
        
        [fieldsView addObject:view];
    }
}

- (void)prepareViewForDelete
{
    self.navigationItem.rightBarButtonItem = nil;
    [self resetContentView];
    
    {
        CGFloat MARGE_LEFT_RIGHT = 27;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, 20, CGRectGetWidth(_contentView.frame) - (2 * MARGE_LEFT_RIGHT), 156)];
        view.backgroundColor = [UIColor customBackgroundHeader];
        
        [_contentView addSubview:view];
        
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(21, 62, 0, 30)];
            label.textColor = [UIColor whiteColor];
            
            label.text = creditCard.number;
            [label setWidthToFit];
            [view addSubview:label];
        }
        
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(21, 110, 0, 30)];
            label.textColor = [UIColor whiteColor];
            
            label.text = creditCard.owner;
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
        
        [button addTarget:self action:@selector(didRemoveCardTouch) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:button];
    }
}

#pragma mark - CARDIO

- (void)presentCardIOViewController
{
    CardIOPaymentViewController *controller = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    controller.appToken = @"368ed39eca23472ab19ad62823e63cb0";
    
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)cardInfo inPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [_card setValue:cardInfo.cardNumber forKey:@"number"];
    [_card setValue:cardInfo.cvv forKey:@"cvv"];
    
    NSString *expires = [NSString stringWithFormat:@"%.2ld-%.2ld", cardInfo.expiryMonth, cardInfo.expiryYear - 2000];
    
    [_card setValue:expires forKey:@"expires"];
    
    for(FLTextFieldTitle2 *view in fieldsView){
        [view reloadData];
    }
}

#pragma mark -

- (void)didValidTouch
{
    [[self view] endEditing:YES];
        
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createCreditCard:_card success:^(id result) {
        FLUser *currentUser = [[Flooz sharedInstance] currentUser];
        creditCard = [currentUser creditCard];
        [self dismissViewControllerAnimated:YES completion:NULL];
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

@end
