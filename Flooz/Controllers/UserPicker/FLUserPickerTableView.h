//
//  FLUserPickerTableView.h
//  Flooz
//
//  Created by Olivier on 2/19/15.
//  Copyright (c) 2015 Olivier Mouren. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLUserPickerTableViewDelegate

- (void)userSelected:(FLUser*)user;

@end

@interface FLUserPickerTableView : UITableView<UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *_contactsFromAdressBook;
    NSMutableArray *_contactsFiltered;
    
    NSMutableArray *_friendsSearch;
    NSMutableArray *_friends;
    NSMutableArray *_friendsRecent;
    
    NSMutableArray *_friendsFiltred;
    NSMutableArray *_friendsRecentFiltred;

    NSMutableArray *_filteredContacts;

    NSString *_selectionText;
    
    NSMutableArray *_selectedIndexPath;
    
    NSTimer *timer;
}

@property (weak) id <FLUserPickerTableViewDelegate> pickerDelegate;

- (void)searchUser:(NSString *)searchString;
- (void)initializeView;

@end
