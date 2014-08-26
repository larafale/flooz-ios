//
//  NewEventViewController.m
//  Flooz
//
//  Created by Jonathan on 31/07/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "NewEventViewController.h"

#import "FLFriendsField.h"
#import "FLSelectAmount.h"
#import "FLNewTransactionBar.h"
#import "FLNewTransactionAmount.h"

@interface NewEventViewController (){
    NSMutableDictionary *transaction;
    
    FLNewTransactionBar *keyboardBar;
    FLNewTransactionBar *keyboardBarFooter;
    
    FLFriendsField *friendsField;
    FLSelectAmount *selectAmount;
    FLNewTransactionAmount *amountInput;
    FLTextView *content;
}

@end

@implementation NewEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        transaction = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor customBackground];
    
    [self configureNavBar];
    [self registerForKeyboardNotifications];
    
    [self createKeyboardBar];
    [self createInputsViews];
    
    [self refreshKeyboardBarFooterPosition];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [friendsField reloadData];
    [self refreshKeyboardBarFooterPosition];
}

#pragma mark - NavBar

- (void)configureNavBar
{
    [_navBar cancelAddTarget:self action:@selector(dismiss)];
    [_navBar validAddTarget:self action:@selector(valid)];
}

#pragma mark - Actions

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)valid
{
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createCollect:transaction success:^(id result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTimeline" object:nil];
        [self dismiss];
    } failure:NULL];
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

#pragma mark - KeyboardBar

- (void)createKeyboardBar
{
    keyboardBar = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self];
    
    keyboardBarFooter = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self];
    [_contentView addSubview:keyboardBarFooter];
    
    [self registerNotification:@selector(reloadKeyboardBarData) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(reloadKeyboardBarData) name:UIKeyboardWillHideNotification object:nil];
    
    
    // WARNING hack car FLNewTransactionBar mal codé
    [self reloadKeyboardBarData];
}

- (void)refreshKeyboardBarFooterPosition
{
    CGRectSetY(keyboardBarFooter.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(keyboardBarFooter.frame));
}

- (void)reloadKeyboardBarData
{
    [keyboardBar reloadData];
    [keyboardBarFooter reloadData];
}

#pragma mark - Inputs Views

- (void)createInputsViews
{
    CGFloat height = 0;
    
    {
        friendsField = [[FLFriendsField alloc] initWithTitle:@"FIELD_TRANSACTION_TO" placeholder:@"FIELD_TRANSACTION_TO_PLACEHOLDER" for:transaction key:@"to" position:CGPointMake(0, height)];
        
        [friendsField setInputAccessoryView:keyboardBar];
        friendsField.delegate = self;
        
        [_contentView addSubview:friendsField];
        height = CGRectGetMaxY(friendsField.frame);
    }
    
    {
        FLTextFieldTitle *title = [[FLTextFieldTitle alloc] initWithTitle:@"FIELD_TRANSACTION_TITLE" placeholder:@"FIELD_TRANSACTION_TITLE_PLACEHOLDER" for:transaction key:@"title" position:CGPointMake(0, height)];
        
        [title setInputAccessoryView:keyboardBar];
        
        [_contentView addSubview:title];
        height = CGRectGetMaxY(title.frame);
    }
    
    {
        selectAmount = [[FLSelectAmount alloc] initWithFrame:CGRectMakePosition(0, height)];
        
        selectAmount.delegate = self;
        
        [_contentView addSubview:selectAmount];
        height = CGRectGetMaxY(selectAmount.frame);
    }
    
    {
        amountInput = [[FLNewTransactionAmount alloc] initFor:transaction key:@"amount"];
        
        [amountInput hideSeparatorTop];
        [amountInput setInputAccessoryView:keyboardBar];
        
        CGRectSetY(amountInput.frame, height);
        
        [_contentView addSubview:amountInput];
        height = CGRectGetMaxY(amountInput.frame);
    }
    
    {
        content = [[FLTextView alloc] initWithPlaceholder:@"FIELD_TRANSACTION_EVENT_PLACEHOLDER" for:transaction key:@"why" position:CGPointMake(0, height - 1)];
        
        [content setInputAccessoryView:keyboardBar];
        
        [_contentView addSubview:content];
        height = CGRectGetMaxY(content.frame);
    }
    
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), height);
    
    [selectAmount setSwitch:NO];
}

#pragma mark - FLSelectAmountDelegate

- (void)didAmountFixSelected
{
    [[self view] endEditing:YES];
    
    [transaction setValue:@100.0 forKey:@"amount"];
    
    [UIView animateWithDuration:.5 animations:^{
        CGRectSetHeight(amountInput.frame, [FLNewTransactionAmount height]);
        CGRectSetY(content.frame, content.frame.origin.y + [FLNewTransactionAmount height]);
        _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), CGRectGetMaxY(content.frame));
    }];
}

- (void)didAmountFreeSelected
{
    // Sinon la valeur du clavier est sauvegardé
    [[self view] endEditing:YES];
    
    [transaction setValue:nil forKey:@"amount"];
    
    [UIView animateWithDuration:.5 animations:^{
        CGRectSetHeight(amountInput.frame, 1);
        CGRectSetY(content.frame, content.frame.origin.y - [FLNewTransactionAmount height]);
        _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), CGRectGetMaxY(content.frame));
    }];
}

@end
