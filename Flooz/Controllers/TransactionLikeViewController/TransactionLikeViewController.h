//
//  TransactionLikeViewController.h
//  Flooz
//
//  Created by Olive on 21/06/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "FriendCell.h"
#import "FriendRequestCellDelegate.h"

@interface TransactionLikeViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource, FriendRequestCellDelegate>

@property (nonatomic, retain) UITableView *tableView;

- (id)initWithTransaction:(FLTransaction *)transaction;

@end
