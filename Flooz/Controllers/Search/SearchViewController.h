//
//  SearchViewController.h
//  Flooz
//
//  Created by Epitech on 10/2/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "FriendAddSearchBar.h"
#import "FriendCell.h"
#import "FriendRequestCellDelegate.h"

@interface SearchViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, FriendAddSearchBarDelegate, UIActionSheetDelegate, FriendRequestCellDelegate> {
    UIRefreshControl *refreshControl;
}


@end
