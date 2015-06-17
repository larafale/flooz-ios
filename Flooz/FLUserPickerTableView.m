//
//  FLUserPickerTableView.m
//  Flooz
//
//  Created by Olivier on 2/19/15.
//  Copyright (c) 2015 olivier Tribouharet. All rights reserved.
//

#import "FLUserPickerTableView.h"
#import "FriendPickerFriendCell.h"
#import "FriendPickerEmptyCell.h"

@interface FLUserPickerTableView () {
    Boolean firstInit;
}

@end

@implementation FLUserPickerTableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        firstInit = YES;
        
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor customBackground];
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        self.separatorColor = [UIColor customMiddleBlue];
        self.separatorInset = UIEdgeInsetsMake(10, 10, 0, 0);
        
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
    } else {
        [self didFilterChange];
    }
    [self reloadData];
}

- (void)didFilterChange {
    if ([_selectionText rangeOfString:@"@"].location == 0) {
        _selectionText = [_selectionText substringFromIndex:1];
    }
    
    if (!_selectionText || [_selectionText isBlank]) {
        _filteredContacts = [_friendsRecent copy];
        
        if ([_filteredContacts count] == 0)
            _filteredContacts = _contactsFromAdressBook;
        
        [self reloadData];
        return;
    }
    
    NSMutableArray *friendsFiltred = [NSMutableArray new];
    
    for (FLUser *user in _friends) {
        if ([user firstname] && [[[user firstname] lowercaseString] rangeOfString:[_selectionText lowercaseString]].location == 0) {
            [friendsFiltred addObject:user];
        }
        else if ([user lastname] && [[[user lastname] lowercaseString] rangeOfString:[_selectionText lowercaseString]].location == 0) {
            [friendsFiltred addObject:user];
        }
        else if ([user fullname] && [[[user fullname] lowercaseString] rangeOfString:[_selectionText lowercaseString]].location == 0) {
            [friendsFiltred addObject:user];
        }
        else if ([user username] && [[[user username] lowercaseString] rangeOfString:[_selectionText lowercaseString]].location == 0) {
            [friendsFiltred addObject:user];
        }
    }
    
    _friendsFiltred = friendsFiltred;
    
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(performSearch) userInfo:nil repeats:NO];
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
            else if (contact.phone && [[contact.phone lowercaseString] rangeOfString:[_selectionText lowercaseString]].location != NSNotFound) {
                [contactsFiltered addObject:contact];
            }
            else if (contact.phone) {
                NSString *clearPhone = contact.phone;
                if ([clearPhone hasPrefix:@"+33"]) {
                    clearPhone = [clearPhone stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@"0"];
                }
                if ([[clearPhone lowercaseString] rangeOfString:[_selectionText lowercaseString]].location != NSNotFound) {
                    [contactsFiltered addObject:contact];
                }
                else if ([[contact.phone lowercaseString] rangeOfString:[_selectionText lowercaseString]].location != NSNotFound) {
                    [contactsFiltered addObject:contact];
                }
            }
        }
        
        _contactsFiltered = contactsFiltered;
        
        [[Flooz sharedInstance] friendSearch:_selectionText forNewFlooz:YES success: ^(id result) {
            _friendsSearch = result;
            
            _filteredContacts = [NSMutableArray new];
            
            [_friendsSearch enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(FLUser *u, NSUInteger index, BOOL *stop) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"phone == %@", u.phone];
                NSArray *filtered = [_contactsFiltered filteredArrayUsingPredicate:predicate];
                
                for (FLUser *rUser in filtered) {
                    [_contactsFiltered removeObject:rUser];
                }
            }];
            
            if (_contactsFiltered.count > 0)
                [_filteredContacts addObjectsFromArray:_contactsFiltered];
            
            if (_friendsSearch.count > 0)
                [_filteredContacts addObjectsFromArray:_friendsSearch];
            
            [self reloadData];
        }];
    } else {
        _filteredContacts = [_friendsRecent copy];
        
        if ([_filteredContacts count] == 0)
            _filteredContacts = _contactsFromAdressBook;
        
        [self reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_filteredContacts count])
        return [FriendPickerFriendCell getHeight];
    return [FriendPickerEmptyCell getHeight];
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_filteredContacts count])
        return [_filteredContacts count];
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_filteredContacts count]) {
        static NSString *cellIdentifierSelection = @"FriendPickerFriendCell";
        FriendPickerFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSelection];
        
        if (!cell) {
            cell = [[FriendPickerFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierSelection];
        }
        
        [cell setUser:[_filteredContacts objectAtIndex:indexPath.row]];
        [cell setSelectedCheckView:[_selectedIndexPath containsObject:indexPath]];
        
        return cell;
    } else {
        static NSString *cellIdentifierSelection = @"FriendPickerEmptyCell";
        FriendPickerEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSelection];
        
        if (!cell) {
            cell = [[FriendPickerEmptyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierSelection];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_filteredContacts count]) {
        [timer invalidate];
        if (self.pickerDelegate)
            [self.pickerDelegate userSelected:_filteredContacts[indexPath.row]];
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
            contact.phone = phone;
            contact.avatarData = image;
            
            [_contactsFromAdressBook addObject:contact];
        }
    }
    
    _contactsFromAdressBook = [self processContacts:_contactsFromAdressBook];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kSendContact]) {
        [[Flooz sharedInstance] createContactList:^(NSMutableArray *arrayContactAdressBook, NSMutableArray *arrayContactFlooz) {
            [[Flooz sharedInstance] saveSettingsObject:@YES withKey:kSendContact];
        } atSignup:YES];
    }
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
