//
//  CollectInvitationsViewController.h
//  Flooz
//
//  Created by Olive on 22/06/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "FriendCell.h"
#import "FriendRequestCellDelegate.h"

@interface CollectInvitationsViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource, FriendRequestCellDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) UITableView *tableView;

- (id)initWithTransaction:(FLTransaction *)transaction;

@end
