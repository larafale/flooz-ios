//
//  FriendRequestViewController.h
//  Flooz
//
//  Created by Epitech on 10/5/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "BaseViewController.h"

@interface FriendRequestViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
    UIRefreshControl *refreshControl;
}

@end
