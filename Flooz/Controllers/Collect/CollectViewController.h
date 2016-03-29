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
#import "CollectHeaderView.h"

@interface CollectViewController : BaseViewController<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, CollectHeaderViewDelegate, FLViewDelegate>

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath;
- (void)focusOnComment;
- (void)reloadTransaction;

@property (strong, nonatomic) UIViewController <TransactionCellDelegate> *delegateController;
@property (strong, nonatomic) UITableView *tableView;

@end
