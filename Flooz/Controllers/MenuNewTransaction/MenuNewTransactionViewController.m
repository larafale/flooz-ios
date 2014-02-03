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
    
    FLMenuNewTransactionButton *eventButton;
    FLMenuNewTransactionButton *collectionButton;
    FLMenuNewTransactionButton *paymentButton;
    
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
    
    self.view.backgroundColor = [UIColor customBackgroundHeader:0.8];
    
    UIImage *buttonImage = [UIImage imageNamed:@"menu-new-transaction"];
    crossButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - buttonImage.size.width) / 2., self.view.frame.size.height - buttonImage.size.height - 20, buttonImage.size.width, buttonImage.size.height)];
    [crossButton setImage:buttonImage forState:UIControlStateNormal];
    [self.view addSubview:crossButton];
    
    [crossButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
    
    eventButton = [[FLMenuNewTransactionButton alloc] initWithPosition:90 imageNamed:@"menu-new-transaction-event" title:@"MENU_NEW_TRANSACTION_EVENT"];
    [self.view addSubview:eventButton];
    [eventButton addTarget:self action:@selector(presentNewTransactionControllerForEvent) forControlEvents:UIControlEventTouchUpInside];
    
    collectionButton = [[FLMenuNewTransactionButton alloc] initWithPosition:215 imageNamed:@"menu-new-transaction-collect" title:@"MENU_NEW_TRANSACTION_COLLECT"];
    [self.view addSubview:collectionButton];
    [collectionButton addTarget:self action:@selector(presentNewTransactionControllerForCollect) forControlEvents:UIControlEventTouchUpInside];
    
    paymentButton = [[FLMenuNewTransactionButton alloc] initWithPosition:340 imageNamed:@"menu-new-transaction-payment" title:@"MENU_NEW_TRANSACTION_PAYMENT"];
    [self.view addSubview:paymentButton];
    [paymentButton addTarget:self action:@selector(presentNewTransactionControllerForPayment) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(firstView){
        
        [UIView animateWithDuration:.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                            crossButton.transform = CGAffineTransformMakeRotation(M_PI / 4. + (M_PI / 8.));
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.4
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 crossButton.transform = CGAffineTransformMakeRotation(M_PI / 4.);
                             } completion:NULL];
        }];
        
        [eventButton startAnimationWithDelay:0.1];
        [collectionButton startAnimationWithDelay:0.2];
        [paymentButton startAnimationWithDelay:0.3];
        
        firstView = NO;
    }
}

- (void)dismiss
{
    [UIView animateWithDuration:.2
                     animations:^{
                         crossButton.transform = CGAffineTransformIdentity;
                         self.view.layer.opacity = 0.5;
                     }
                     completion:^(BOOL finished) {
                         [self dismissViewControllerAnimated:NO completion:NULL];
                     }];
}

- (void)presentNewTransactionControllerForEvent
{
    __strong UIViewController *presentingController = self.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        [presentingController presentViewController:[[NewTransactionViewController alloc] initWithTransactionType:TransactionTypePayment] animated:YES completion:NULL];
    }];
}

- (void)presentNewTransactionControllerForCollect
{
    __strong UIViewController *presentingController = self.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        [presentingController presentViewController:[[NewTransactionViewController alloc] initWithTransactionType:TransactionTypeCollection] animated:YES completion:NULL];
    }];
}

- (void)presentNewTransactionControllerForPayment
{
    __strong UIViewController *presentingController = self.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        [presentingController presentViewController:[[NewTransactionViewController alloc] initWithTransactionType:TransactionTypePayment] animated:YES completion:NULL];
    }];
}

@end
