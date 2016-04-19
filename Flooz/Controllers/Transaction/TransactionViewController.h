//
//  TransactionViewController.h
//  Flooz
//
//  Created by Olivier on 2/5/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransactionActionsViewDelegate.h"
#import "TransactionCellDelegate.h"
#import "FLNewTransactionAmountDelegate.h"
#import "FLViewDelegate.h"
#import "TransactionHeaderView.h"

@interface TransactionViewController : BaseViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, TransactionHeaderViewDelegate, FLViewDelegate>

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath;
- (void)focusOnComment;
- (void)reloadTransaction;
- (NSString *)currentId;
- (void)refreshTransaction;

@property (strong, nonatomic) UIViewController <TransactionCellDelegate> *delegateController;
@property (strong, nonatomic) UITableView *tableView;

@end
