//
//  FriendsViewController.h
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendRequestCellDelegate.h"

@interface FriendsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, FriendRequestCellDelegate>

@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
