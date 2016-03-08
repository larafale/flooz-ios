//
//  CollectViewController.h
//  Flooz
//
//  Created by Olive on 3/8/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"

#import "TransactionActionsViewDelegate.h"
#import "TransactionCellDelegate.h"
#import "FLNewTransactionAmountDelegate.h"
#import "FLViewDelegate.h"

@interface CollectViewController : BaseViewController<TransactionActionsViewDelegate, FLNewTransactionAmountDelegate, UIViewControllerTransitioningDelegate, FLViewDelegate>

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath;
- (void)focusOnComment;
- (void)reloadTransaction;

@property (strong, nonatomic) UIViewController <TransactionCellDelegate> *delegateController;

@end
