//
//  TransactionViewController.h
//  Flooz
//
//  Created by jonathan on 2/5/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransactionActionsViewDelegate.h"
#import "TransactionCellDelegate.h"
#import "FLNewTransactionAmountDelegate.h"

@interface TransactionViewController : UIViewController<TransactionActionsViewDelegate, FLNewTransactionAmountDelegate>

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath;
- (void)focusOnComment;

@property (strong, nonatomic) UIViewController<TransactionCellDelegate> *delegateController;
@property (weak, nonatomic) IBOutlet UIScrollView *contentView;

@end
