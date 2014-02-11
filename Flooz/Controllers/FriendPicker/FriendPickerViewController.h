//
//  FriendPickerViewController.h
//  Flooz
//
//  Created by jonathan on 2/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendPickerSearchBar.h"

@interface FriendPickerViewController : UIViewController<FriendPickerSearchBarDelegate, UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *_contactsFromAdressBook;
    NSArray *_contacts;
}

@property (weak, nonatomic) IBOutlet FriendPickerSearchBar* searchBar;
@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
