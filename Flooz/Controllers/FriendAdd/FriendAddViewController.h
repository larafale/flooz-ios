//
//  FriendAddViewController.h
//  Flooz
//
//  Created by jonathan on 3/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendAddSearchBar.h"
#import "FriendAddCell.h"

@interface FriendAddViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, FriendAddSearchBarDelegate>{
    NSArray *friends;
}

@property (weak, nonatomic) IBOutlet FriendAddSearchBar *searchBar;
@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
