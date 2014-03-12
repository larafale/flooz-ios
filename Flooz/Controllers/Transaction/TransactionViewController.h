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
#import "FLPaymentFieldDelegate.h"

@interface TransactionViewController : UIViewController<TransactionActionsViewDelegate, FLPaymentFieldDelegate>

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath;

@property (strong, nonatomic) UIViewController<TransactionCellDelegate> *delegateController;
@property (weak, nonatomic) IBOutlet UIScrollView *contentView;

@end
