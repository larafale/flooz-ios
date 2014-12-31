//
//  TransactionViewController.h
//  Flooz
//
//  Created by jonathan on 2/5/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransactionActionsViewDelegate.h"
#import "TransactionCellDelegate.h"
#import "FLNewTransactionAmountDelegate.h"
#import "FLViewDelegate.h"

@interface TransactionViewController : GlobalViewController <TransactionActionsViewDelegate, FLNewTransactionAmountDelegate, UIViewControllerTransitioningDelegate, FLViewDelegate>

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath withSize:(CGSize)size;
- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath;
- (void)focusOnComment;
- (void)reloadTransaction;

@property (strong, nonatomic) UIViewController <TransactionCellDelegate> *delegateController;

@end