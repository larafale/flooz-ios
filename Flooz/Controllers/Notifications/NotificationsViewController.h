//
//  NotificationsViewController.h
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate> {
    UITableView *_tableView;
}

@end