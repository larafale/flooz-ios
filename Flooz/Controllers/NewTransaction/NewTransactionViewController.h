//
//  NewTransactionViewController.h
//  Flooz
//
//  Created by jonathan on 1/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLSelectAmountDelegate.h"
#import "FLNewTransactionAmount.h"
#import "FLPaymentFieldDelegate.h"
#import "NewTransactionSelectTypeDelegate.h"

@interface NewTransactionViewController : UIViewController<FLSelectAmountDelegate, FLPaymentFieldDelegate, NewTransactionSelectTypeDelegate>

- (id)initWithTransactionType:(TransactionType)transactionType;

@property (weak, nonatomic) IBOutlet UIScrollView *contentView;

@end
