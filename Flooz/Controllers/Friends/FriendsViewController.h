//
//  FriendsViewController.h
//  Flooz
//
//  Created by Olivier on 2/17/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendRequestCellDelegate.h"
#import "FriendAddSearchBar.h"

#import "FriendCell.h"

@interface FriendsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, FriendRequestCellDelegate, FriendAddSearchBarDelegate, UIActionSheetDelegate> {
	UIRefreshControl *refreshControl;
}

//@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
//@property (weak, nonatomic) IBOutlet FriendAddSearchBar *searchBar;
//@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
