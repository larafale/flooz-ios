//
//  MenuNewTransactionViewController.m
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "MenuNewTransactionViewController.h"

#import "NewTransactionViewController.h"

@interface MenuNewTransactionViewController () {
	UIButton *crossButton;

	FLMenuNewTransactionButton *collectionButton;
	FLMenuNewTransactionButton *paymentButton;

	BOOL firstView;
}

@end

@implementation MenuNewTransactionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		firstView = YES;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor customBackgroundHeader:0.8];

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
	[self.view addGestureRecognizer:gesture];

	UIImage *buttonImage = [UIImage imageNamed:@"menu-new-transaction"];
	crossButton = [[UIButton alloc] initWithFrame:CGRectMake((PPScreenWidth() - buttonImage.size.width) / 2., PPScreenHeight() - buttonImage.size.height - 20, buttonImage.size.width, buttonImage.size.height)];
	[crossButton setImage:buttonImage forState:UIControlStateNormal];
	[self.view addSubview:crossButton];

	[crossButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

    collectionButton = [[FLMenuNewTransactionButton alloc] initWithPosition:(IS_IPHONE4 ? 140 + 24 : 210) imageNamed:@"menu-new-transaction-collect" title:@"MENU_NEW_TRANSACTION_COLLECT"];
	[self.view addSubview:collectionButton];
	[collectionButton addTarget:self action:@selector(presentNewTransactionControllerForCollect) forControlEvents:UIControlEventTouchUpInside];

	paymentButton = [[FLMenuNewTransactionButton alloc] initWithPosition:(CGRectGetMaxY(collectionButton.frame) + 24) imageNamed:@"menu-new-transaction-payment" title:@"MENU_NEW_TRANSACTION_PAYMENT"];
	[self.view addSubview:paymentButton];
	[paymentButton addTarget:self action:@selector(presentNewTransactionControllerForPayment) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	crossButton.frame = CGRectMake((self.view.frame.size.width - crossButton.imageView.image.size.width) / 2., self.view.frame.size.height - crossButton.imageView.image.size.height - 20, crossButton.imageView.image.size.width, crossButton.imageView.image.size.height);
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (firstView) {
		self.view.layer.opacity = 0;

		[UIView animateWithDuration:.3
		                      delay:0
		                    options:UIViewAnimationOptionCurveEaseOut
		                 animations: ^{
		    self.view.layer.opacity = 1;
		    crossButton.transform = CGAffineTransformMakeRotation(M_PI / 4. + (M_PI / 8.));
		} completion: ^(BOOL finished) {
		    [UIView animateWithDuration:.4
		                          delay:0
		                        options:UIViewAnimationOptionCurveEaseOut
		                     animations: ^{
		        crossButton.transform = CGAffineTransformMakeRotation(M_PI / 4.);
			} completion:NULL];
		}];

		[collectionButton startAnimationWithDelay:0.2];
		[paymentButton startAnimationWithDelay:0.3];

		firstView = NO;
	}
}

- (void)dismiss {
	[collectionButton startReverseAnimationWithDelay:0.1];
	[paymentButton startReverseAnimationWithDelay:0.2];

	[UIView animateWithDuration:.4
	                 animations: ^{
	    crossButton.transform = CGAffineTransformIdentity;
	    self.view.layer.opacity = 0;
	}

	                 completion: ^(BOOL finished) {
	    [self dismissViewControllerAnimated:NO completion:NULL];
	}];
}

- (void)presentNewTransactionControllerForCollect {
	__strong UIViewController *presentingController = self.presentingViewController;
	[self dismissViewControllerAnimated:NO completion: ^{
	    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[[NewTransactionViewController alloc] initWithTransactionType:TransactionTypeCharge]];
	    [presentingController presentViewController:controller animated:YES completion:NULL];
	}];
}

- (void)presentNewTransactionControllerForPayment {
	__strong UIViewController *presentingController = self.presentingViewController;
	[self dismissViewControllerAnimated:NO completion: ^{
	    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[[NewTransactionViewController alloc] initWithTransactionType:TransactionTypePayment]];
	    [presentingController presentViewController:controller animated:YES completion:NULL];
	}];
}

@end
