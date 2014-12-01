//
//  FriendPickerViewController.h
//  Flooz
//
//  Created by jonathan on 2/6/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendPickerSearchBar.h"

@interface FriendPickerViewController : BaseViewController <FriendPickerSearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
	NSMutableArray *_contactsFromAdressBook;
	NSMutableArray *_contactsFromFacebook;

	NSArray *_friendsSearch;

	NSArray *_friends;
	NSArray *_friendsRecent;

	NSArray *_friendsFiltred;
	NSArray *_friendsRecentFiltred;

	NSArray *_currentContacts;
	NSArray *_contacts;

	NSString *_selectionText;

	NSMutableArray *_selectedIndexPath;
}

@property (retain, nonatomic) FriendPickerSearchBar *searchBar;
@property (retain, nonatomic) FLTableView *tableView;

@property (strong, nonatomic) NSMutableDictionary *dictionary;

@property (nonatomic) Boolean isFirstView;
@property (nonatomic) UINavigationController *previousController;

@end
