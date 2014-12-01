//
//  FriendAddViewController.h
//  Flooz
//
//  Created by jonathan on 3/6/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendAddSearchBar.h"
#import "FriendCell.h"

@interface FriendAddViewController : GlobalViewController <UITableViewDataSource, UITableViewDelegate, FriendAddSearchBarDelegate> {
	NSArray *friends;
}

@property (weak, nonatomic) IBOutlet FriendAddSearchBar *searchBar;
@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
