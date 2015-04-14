//
//  FLUserPickerTableView.h
//  Flooz
//
//  Created by Epitech on 2/19/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLUserPickerTableViewDelegate

- (void)userSelected:(FLUser*)user;

@end

@interface FLUserPickerTableView : UITableView<UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *_contactsFromAdressBook;
    NSMutableArray *_contactsFiltered;
    
    NSArray *_friendsSearch;
    NSArray *_friends;
    NSArray *_friendsRecent;
    
    NSArray *_friendsFiltred;
    NSArray *_friendsRecentFiltred;

    NSMutableArray *_filteredContacts;

    NSString *_selectionText;
    
    NSMutableArray *_selectedIndexPath;
    
    NSTimer *timer;
}

@property (weak) id <FLUserPickerTableViewDelegate> pickerDelegate;

- (void)searchUser:(NSString *)searchString;
- (void)initializeView;

@end
