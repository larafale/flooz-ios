//
//  TransactionViewController.h
//  Flooz
//
//  Created by olivier on 2/5/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransactionActionsViewDelegate.h"
#import "TransactionCellDelegate.h"
#import "FLNewTransactionAmountDelegate.h"
#import "FLViewDelegate.h"

@interface TransactionViewController : BaseViewController <TransactionActionsViewDelegate, FLNewTransactionAmountDelegate, UIViewControllerTransitioningDelegate, FLViewDelegate>

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath withSize:(CGSize)size;
- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath;
- (void)focusOnComment;
- (void)reloadTransaction;
- (void)shareTransaction;
- (void)acceptTransaction;

@property (strong, nonatomic) UIViewController <TransactionCellDelegate> *delegateController;

@end
