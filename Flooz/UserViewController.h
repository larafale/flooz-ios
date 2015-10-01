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

@interface UserViewController : BaseViewController<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, TimelineDelegate, TransactionCellDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) FLTableView *tableView;

- (id)initWithUser:(FLUser*)user;

@end
