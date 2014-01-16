//
//  MenuNewTransactionViewController.m
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "MenuNewTransactionViewController.h"

@interface MenuNewTransactionViewController (){
    UIButton *crossButton;
    
    RoundButton *eventButton;
    RoundButton *collectionButton;
    RoundButton *paymentButton;
}

@end

@implementation MenuNewTransactionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *buttonImage = [UIImage imageNamed:@"button"];
    crossButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - buttonImage.size.width) / 2., self.view.frame.size.height - buttonImage.size.height - 20, buttonImage.size.width, buttonImage.size.height)];
    [crossButton setImage:buttonImage forState:UIControlStateNormal];
    [self.view addSubview:crossButton];
    
    [crossButton addTarget:self action:@selector(dismissMenuTransactionController) forControlEvents:UIControlEventTouchDown];
    
    eventButton = [[RoundButton alloc] initWithPosition:50 imageName:@"button" text:@"Evenement"];
    [self.view addSubview:eventButton];
    
    collectionButton = [[RoundButton alloc] initWithPosition:175 imageName:@"button" text:@"Encaissement"];
    [self.view addSubview:collectionButton];
    
    paymentButton = [[RoundButton alloc] initWithPosition:300 imageName:@"button" text:@"Paiement"];
    [self.view addSubview:paymentButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         crossButton.transform = CGAffineTransformMakeRotation(2.8);
                     }
                     completion:^(BOOL finished) {
                         [eventButton startAnimationWithDelay:0];
                         [collectionButton startAnimationWithDelay:0.15];
                         [paymentButton startAnimationWithDelay:0.3];
                     }];
}

- (void)dismissMenuTransactionController
{
    [UIView animateWithDuration:1.0
                     animations:^{
                         crossButton.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         [self dismissViewControllerAnimated:NO completion:nil];
                     }];
}

@end
