//
//  UserViewController.h
//  Flooz
//
//  Created by Flooz on 9/16/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionCellDelegate.h"
#import "TimelineDelegate.h"

@interface UserViewController : BaseViewController<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, TimelineDelegate, TransactionCellDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CAAnimationDelegate>

@property (nonatomic) FLTableView *tableView;
@property (nonatomic, retain) FLUser *currentUser;

- (id)initWithUser:(FLUser*)user;
- (void)shakeView;

@end
