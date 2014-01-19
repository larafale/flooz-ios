//
//  MenuNewTransactionViewController.m
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "MenuNewTransactionViewController.h"

#import "NewTransactionViewController.h"

@interface MenuNewTransactionViewController (){
    UIButton *crossButton;
    
    RoundButton *eventButton;
    RoundButton *collectionButton;
    RoundButton *paymentButton;
    
    BOOL firstView;
}

@end

@implementation MenuNewTransactionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        firstView = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    
    UIImage *buttonImage = [UIImage imageNamed:@"button"];
    crossButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - buttonImage.size.width) / 2., self.view.frame.size.height - buttonImage.size.height - 20, buttonImage.size.width, buttonImage.size.height)];
    [crossButton setImage:buttonImage forState:UIControlStateNormal];
    [self.view addSubview:crossButton];
    
    [crossButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
    
    eventButton = [[RoundButton alloc] initWithPosition:50 imageName:@"menu-new-transaction-event" text:@"MENU_NEW_TRANSACTION_EVENT"];
    [self.view addSubview:eventButton];
    [eventButton addTarget:self action:@selector(presentNewTransactionControllerForEvent) forControlEvents:UIControlEventTouchDown];
    
    collectionButton = [[RoundButton alloc] initWithPosition:175 imageName:@"menu-new-transaction-collect" text:@"MENU_NEW_TRANSACTION_COLLECT"];
    [self.view addSubview:collectionButton];
    [collectionButton addTarget:self action:@selector(presentNewTransactionControllerForCollect) forControlEvents:UIControlEventTouchDown];
    
    paymentButton = [[RoundButton alloc] initWithPosition:300 imageName:@"menu-new-transaction-payment" text:@"MENU_NEW_TRANSACTION_PAYMENT"];
    [self.view addSubview:paymentButton];
    [paymentButton addTarget:self action:@selector(presentNewTransactionControllerForPayment) forControlEvents:UIControlEventTouchDown];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(firstView){
        [UIView animateWithDuration:1.0
                         animations:^{
                             crossButton.transform = CGAffineTransformMakeRotation(2.8);
                         }
                         completion:NULL];
        
        [eventButton startAnimationWithDelay:0.15];
        [collectionButton startAnimationWithDelay:0.3];
        [paymentButton startAnimationWithDelay:0.45];
        
        firstView = NO;
    }
}

- (void)dismiss
{
    [UIView animateWithDuration:1.0
                     animations:^{
                         crossButton.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         [self dismissViewControllerAnimated:NO completion:NULL];
                     }];
}

- (void)presentNewTransactionControllerForEvent
{
    __strong UIViewController *presentingController = self.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        [presentingController presentViewController:[NewTransactionViewController new] animated:YES completion:NULL];
    }];
}

- (void)presentNewTransactionControllerForCollect
{
    __strong UIViewController *presentingController = self.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        [presentingController presentViewController:[NewTransactionViewController new] animated:YES completion:NULL];
    }];
}

- (void)presentNewTransactionControllerForPayment
{
    __strong UIViewController *presentingController = self.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        [presentingController presentViewController:[NewTransactionViewController new] animated:YES completion:NULL];
    }];
}

@end
