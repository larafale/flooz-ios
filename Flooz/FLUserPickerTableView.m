//
//  FLUserPickerTableView.m
//  Flooz
//
//  Created by Olivier on 2/19/15.
//  Copyright (c) 2015 Olivier Mouren. All rights reserved.
//

#import "FLUserPickerTableView.h"
#import "FriendPickerFriendCell.h"
#import "FriendPickerEmptyCell.h"
#import "LoadingCell.h"

@interface FLUserPickerTableView () {
    Boolean firstInit;
    BOOL isLoadingSearch;
}

@end

@implementation FLUserPickerTableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        firstInit = YES;
        isLoadingSearch = NO;

        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor customBackgroundHeader];
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        self.separatorColor = [UIColor customMiddleBlue];
        self.separatorInset = UIEdgeInsetsMake(10, 10, 0, 0);
        self.tableFooterView = [UIView new];
        self.scrollsToTop = YES;
        
        _contactsFromAdressBook = [NSMutableArray new];
        
        _friends = [[[[Flooz sharedInstance] currentUser] friends] copy];
        _friendsRecent = [[[[Flooz sharedInstance] currentUser] friendsRecent] copy];
        
        _friendsFiltred = _friends;
        _friendsRecentFiltred = _friendsRecent;
        
        _friendsSearch = [NSMutableArray new];
        
        _selectedIndexPath = [NSMutableArray new];
        
        [[Flooz sharedInstance] updateCurrentUserWithSuccess:^{
            _friends = [[[[Flooz sharedInstance] currentUser] friends] copy];
            _friendsRecent = [[[[Flooz sharedInstance] currentUser] friendsRecent] copy];
            _friendsFiltred = _friends;
            _friendsRecentFiltred = _friendsRecent;
            
            _filteredContacts = [_friendsRecent mutableCopy];
            
            [self reloadData];
        }];
    }
    return self;
}

- (void)initializeView {
    if (firstInit) {
        [self requestAddressBookPermission];
        
        if (!_selectionText || [_selectionText isBlank]) {
            _filteredContacts = [_friendsRecent copy];
            
            if ([_filteredContacts count] == 0)
                _filteredContacts = _contactsFromAdressBook;
        }
        
        firstInit = NO;
    }
}

- (void)searchUser:(NSString *)searchString {
    _selectionText = searchString;
    if ([searchString isEqualToString:@""]){
        [timer invalidate];
        _filteredContacts = [_friendsRecent copy];
        
        if ([_filteredContacts count] == 0)
            _filteredContacts = _contactsFromAdressBook;

        isLoadingSearch = NO;

        [self reloadData];
    } else {
        [self didFilterChange];
    }
}

- (void)didFilterChange {
    if ([_selectionText rangeOfString:@"@"].location == 0) {
        _selectionText = [_selectionText substringFromIndex:1];
    }
    
    if (!_selectionText || [_selectionText isBlank]) {
        isLoadingSearch = NO;
        [self reloadData];
        return;
    }
    
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(performSearch) userInfo:nil repeats:NO];
}

- (void)performSearch {
    if (!_selectionText.isBlank) {
        NSMutableArray *contactsFiltered = [NSMutableArray new];
        
        for (FLUser *contact in _contactsFromAdressBook) {
            if (contact.fullname && [[contact.fullname lowercaseString] rangeOfString:[_selectionText lowercaseString]].location == 0) {
                [contactsFiltered addObject:contact];
            }
            else if (contact.firstname && [[contact.firstname lowercaseString] rangeOfString:[_selectionText lowercaseString]].location == 0) {
                [contactsFiltered addObject:contact];
            }
            else if (contact.lastname && [[contact.lastname lowercaseString] rangeOfString:[_selectionText lowercaseString]].location == 0) {
                [contactsFiltered addObject:contact];
            }
            else if ([FLHelper phoneMatch:contact.phone withPhone:_selectionText]) {
                [contactsFiltered addObject:contact];
            }
        }
        
        _contactsFiltered = contactsFiltered;
        
        NSMutableArray *phoneArray = [NSMutableArray new];
        
        if (_contactsFiltered.count < 50) {
            for (FLUser *tmp in _contactsFiltered) {
                [phoneArray addObject:tmp.phone];
            }
        }
        
        isLoadingSearch = YES;
        [self reloadData];

        [[Flooz sharedInstance] friendSearch:_selectionText forNewFlooz:YES withPhones:phoneArray success: ^(id result, NSString *searchString) {
            if (searchString && ![searchString isEqualToString:_selectionText])
                return;
            
            _friendsSearch = result;
            
            _filteredContacts = [NSMutableArray new];
            NSMutableArray *commonUsers = [NSMutableArray new];
            NSMutableArray *commonContacts = [NSMutableArray new];
            
            for (FLUser *user in _friendsSearch) {
                for (FLUser *user2 in _contactsFiltered) {
                    BOOL common = NO;
                    if ([user2.phone isEqualToString:user.phone]) {
                        [commonContacts addObject:user2];
                        common = YES;
                    }
                    
                    if (common && ![commonUsers containsObject:user]) {
                        [commonUsers addObject:user];
                    }
                }
            }
            
            for (FLUser *rUser in commonUsers) {
                [_friendsSearch removeObject:rUser];
            }
            
            for (FLUser *rUser in commonContacts) {
                [_contactsFiltered removeObject:rUser];
            }
            
            if (commonUsers.count > 0)
                [_filteredContacts addObjectsFromArray:commonUsers];
            
            if (_contactsFiltered.count > 0)
                [_filteredContacts addObjectsFromArray:_contactsFiltered];
            
            if (_friendsSearch.count > 0)
                [_filteredContacts addObjectsFromArray:_friendsSearch];
            
            isLoadingSearch = NO;

            [self reloadData];
        }];
    } else {
        _filteredContacts = [_friendsRecent copy];
        
        if ([_filteredContacts count] == 0)
            _filteredContacts = _contactsFromAdressBook;
        
        isLoadingSearch = NO;

        [self reloadData];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!_selectionText || [_selectionText isBlank]) {
        if (section == 0) {
            return NSLocalizedString(@"FRIEND_PICKER_FRIENDS_RECENT", nil);
        } else if (section == 1) {
            return NSLocalizedString(@"FRIEND_PICKER_FRIENDS", nil);
        } else {
            return NSLocalizedString(@"FRIEND_PICKER_ADDRESS_BOOK", nil);
        }
    } else {
        return NSLocalizedString(@"FRIEND_PICKER_RESULT", nil);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!_selectionText || [_selectionText isBlank]) {
        if (section == 0) {
            if ([_friendsRecent count] || (!_friends.count && !_contactsFromAdressBook.count))
                return 35;
            return 0;
        } else if (section == 1) {
            if (_friends.count)
                return 35;
            return 0;
        } else {
            if ([_contactsFromAdressBook count])
                return 35;
            return 0;
        }
    } else {
        return 35;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), [self tableView:tableView heightForHeaderInSection:section])];
    headerView.backgroundColor = [UIColor customBackground];
    
    UILabel *headerTitle = [[UILabel alloc] initWithText:[self tableView:tableView titleForHeaderInSection:section] textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15]];
    
    [headerView addSubview:headerTitle];
    
    CGRectSetX(headerTitle.frame, 14);
    CGRectSetY(headerTitle.frame, CGRectGetHeight(headerView.frame) / 2 - CGRectGetHeight(headerTitle.frame) / 2);
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_selectionText || [_selectionText isBlank]) {
        if (![_contactsFromAdressBook count] || ![_friends count] || ![_friends count])
            return [FriendPickerFriendCell getHeight];
        return [FriendPickerEmptyCell getHeight];
    } else {
        if (isLoadingSearch)
            return [LoadingCell getHeight];

        if (![_filteredContacts count])
            return [FriendPickerFriendCell getHeight];
        
        return [FriendPickerEmptyCell getHeight];
    };
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_selectionText || [_selectionText isBlank]) {
        if (section == 0) {
            if (![_friendsRecent count] && ![_friends count] && ![_contactsFromAdressBook count])
                return 1;
            return [_friendsRecent count];
        } else if (section == 1) {
            return [_friends count];
        } else {
            return [_contactsFromAdressBook count];
        }
    } else {
        if (isLoadingSearch)
            return 1;
        
        if ([_filteredContacts count])
            return [_filteredContacts count];
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!_selectionText || [_selectionText isBlank])
        return 3;
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLUser *currentUser;
    
    if (!_selectionText || [_selectionText isBlank]) {
        if (indexPath.section == 0 && [_friendsRecent count]) {
            currentUser = _friendsRecent[indexPath.row];
        } else if (indexPath.section == 0 && ![_contactsFromAdressBook count] && ![_friends count]) {
            return [self createEmptyCell:tableView];
        } else if (indexPath.section == 1) {
            currentUser = _friends[indexPath.row];
        } else {
            currentUser = _contactsFromAdressBook[indexPath.row];
        }
    } else {
        if (isLoadingSearch)
            return [LoadingCell new];
        
        if (![_filteredContacts count])
            return [self createEmptyCell:tableView];
        
        if (_filteredContacts.count >= indexPath.row + 1)
            currentUser = _filteredContacts[indexPath.row];
    }
    
    static NSString *cellIdentifierSelection = @"FriendPickerFriendCell";
    FriendPickerFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSelection];
    
    if (!cell) {
        cell = [[FriendPickerFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierSelection];
    }
    
    if (currentUser) {
        [cell setUser:currentUser];
        [cell setSelectedCheckView:NO];
    }
    
    return cell;
}

- (UITableViewCell *)createEmptyCell:(UITableView *)tableView  {
    static NSString *cellIdentifierSelection = @"FriendPickerEmptyCell";
    FriendPickerEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSelection];
    
    if (!cell) {
        cell = [[FriendPickerEmptyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierSelection];
        [cell setUserInteractionEnabled:NO];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [timer invalidate];
    
    if (self.pickerDelegate) {
        FLUser *currentUser = nil;
        
        if (!_selectionText || [_selectionText isBlank]) {
            if (indexPath.section == 0 && [_friendsRecent count]) {
                currentUser = _friendsRecent[indexPath.row];
            } else if (indexPath.section == 0 && ![_contactsFromAdressBook count] && ![_friends count]) {
                return;
            } else if (indexPath.section == 1) {
                currentUser = _friends[indexPath.row];
            } else {
                currentUser = _contactsFromAdressBook[indexPath.row];
            }
        } else {
            if (isLoadingSearch)
                return;
            
            if (![_filteredContacts count])
                return;
            
            if (_filteredContacts.count >= indexPath.row + 1)
                currentUser = _filteredContacts[indexPath.row];
        }
        
        if (currentUser)
            [self.pickerDelegate userSelected:currentUser];
    }
}

- (void)requestAddressBookPermission {
    [[Flooz sharedInstance] grantedAccessToContacts: ^(BOOL granted) {
        if (granted) {
            [self didAddressBookPermissionGranted];
        }
        else {
            
        }
    }];
}

- (void)didAddressBookPermissionGranted {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    _contactsFromAdressBook = [NSMutableArray new];
    
    for (int i = 0; i < nPeople; ++i) {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
        
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonLastNameProperty));
        NSData *image = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
        
        NSString *name = nil;
        if (!firstName) {
            name = lastName;
        }
        else if (!lastName) {
            name = firstName;
        }
        else {
            name = [firstName stringByAppendingFormat:@" %@", lastName];
        }
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); ++i) {
            NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            
            FLUser *contact = [FLUser new];
            
            contact.firstname = firstName;
            contact.lastname = lastName;
            contact.fullname = name;
            contact.avatarData = image;
            
            if ([FLHelper isValidPhoneNumber:phone]) {
                contact.phone = [FLHelper formatedPhone:phone];
                
                if (contact.phone) {
                    [_contactsFromAdressBook addObject:contact];
                }
            }
        }
    }
    
    _contactsFromAdressBook = [self processContacts:_contactsFromAdressBook];
    
//    if (![[NSUserDefaults standardUserDefaults] objectForKey:kSendContact] || ![[NSUserDefaults standardUserDefaults] boolForKey:kSendContact]) {
        [[Flooz sharedInstance] createContactList:^(NSMutableArray *arrayContactAdressBook, NSMutableArray *arrayContactFlooz) {
//            [[Flooz sharedInstance] saveSettingsObject:@YES withKey:kSendContact];
        } atSignup:YES];
//    }
}

- (NSMutableArray *)processContacts:(NSArray *)contacts {
    
    NSMutableArray *newContacts = [NSMutableArray new];
    
    for (FLUser *contact in contacts) {
        
        if (contact.phone) {
            contact.phone = [FLHelper formatedPhone:contact.phone];
        }
        
        if (contact.fullname && contact.phone) {
            [newContacts addObject:contact];
        }
    }
    
    newContacts = [[newContacts sortedArrayUsingComparator: ^NSComparisonResult (id a, id b) {
        FLUser *userA = a;
        FLUser *userB = b;
        
        return [userA.fullname compare:userB.fullname];
    }] mutableCopy];
    
    return newContacts;
}

@end
