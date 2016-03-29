//
//  ShareLinkViewController.m
//  Flooz
//
//  Created by Olive on 3/21/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ShareCell.h"
#import "FriendAddSearchBar.h"
#import "ShareLinkViewController.h"
#import "FriendPickerFriendCell.h"
#import "FriendPickerEmptyCell.h"

@interface ShareLinkViewController () {
    UIBarButtonItem *searchItem;
    
    FriendAddSearchBar *_searchBar;
    FLTableView *_tableView;
    FLActionButton *_sendButton;
    
    NSMutableArray *_contactsFromAdressBook;
    NSMutableArray *_contactsFiltered;
    
    NSMutableArray *_friendsSearch;
    NSMutableArray *_friends;
    
    NSMutableArray *_friendsFiltred;
    
    NSMutableArray *_filteredContacts;
    
    NSString *_selectionText;
    
    NSMutableArray *_selectedIndexPath;
    
    NSTimer *timer;
    
    NSMutableArray *selectedContacts;
    
    NSString *_smsText;
    
    BOOL isSearching;
    
    NSString *buttonTitle;
    
    NSString *_collectId;
}

@end

@implementation ShareLinkViewController

- (id)initWithCollectId:(NSString *)collectId {
    self = [super init];
    if (self) {
        _collectId = collectId;
    }
    return self;
}

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super initWithTriggerData:data];
    if (self) {
        _collectId = data[@"_id"];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contactsFromAdressBook = [NSMutableArray new];
    selectedContacts = [NSMutableArray new];
    
    _friends = [[[[Flooz sharedInstance] currentUser] friends] copy];
    
    _friendsFiltred = _friends;
    
    _friendsSearch = [NSMutableArray new];
    
    _selectedIndexPath = [NSMutableArray new];
    
    [[Flooz sharedInstance] updateCurrentUserWithSuccess:^{
        _friends = [[[[Flooz sharedInstance] currentUser] friends] copy];
        _friendsFiltred = _friends;
        
        _filteredContacts = [_friends mutableCopy];
        
        [_tableView reloadData];
    }];
    
    if (!_selectionText || [_selectionText isBlank]) {
        _filteredContacts = [_friends copy];
        
        if ([_filteredContacts count] == 0)
            _filteredContacts = _contactsFromAdressBook;
    }
    
    buttonTitle = NSLocalizedString(@"GLOBAL_INVITE", nil);
    
    if (self.triggerData && self.triggerData[@"button"] && ![self.triggerData[@"button"] isBlank])
        buttonTitle = self.triggerData[@"button"];
    
    if ([[Flooz sharedInstance] currentTexts]) {
        if (!self.title || [self.title isBlank])
            self.title = [[Flooz sharedInstance] currentTexts].menu[@"sms"][@"title"];
        
        if (!buttonTitle || [buttonTitle isBlank])
            buttonTitle = [[Flooz sharedInstance] currentTexts].menu[@"sms"][@"button"];
    } else {
        [[Flooz sharedInstance] textObjectFromApi:^(FLTexts *result) {
            if (!self.title || [self.title isBlank])
                self.title = result.menu[@"sms"][@"title"];
            
            if (!buttonTitle || [buttonTitle isBlank])
                buttonTitle = result.menu[@"sms"][@"button"];
            
            if (selectedContacts.count)
                [_sendButton setTitle:[NSString stringWithFormat:@"%@ (%lu)", buttonTitle, (unsigned long)[selectedContacts count]] forState:UIControlStateNormal];
            else
                [_sendButton setTitle:buttonTitle forState:UIControlStateNormal];
        } failure:^(NSError *error) {
            
        }];
    }
    
    searchItem = [[UIBarButtonItem alloc] initWithImage:[FLHelper imageWithImage:[UIImage imageNamed:@"search"] scaledToSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(showSearch)];
    [searchItem setTintColor:[UIColor customBlue]];
    
    _searchBar = [[FriendAddSearchBar alloc] initWithFrame:CGRectMake(10, -45, PPScreenWidth() - 20, 40)];
    [_searchBar setDelegate:self];
    [_searchBar setHidden:YES];
    [_searchBar sizeToFit];
    
    _sendButton = [[FLActionButton alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(_mainBody.frame) - FLActionButtonDefaultHeight - 5, PPScreenWidth() - 20, FLActionButtonDefaultHeight) title:buttonTitle];
    [_sendButton setEnabled:NO];
    [_sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame) + 5, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_searchBar.frame) - FLActionButtonDefaultHeight - 15) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_tableView setSeparatorColor:[UIColor customBackground]];
    [_tableView setBackgroundColor:[UIColor customBackgroundHeader]];
    [_tableView setAllowsMultipleSelection:YES];
    
    [_mainBody addSubview:_searchBar];
    [_mainBody addSubview:_tableView];
    [_mainBody addSubview:_sendButton];
    
    if ([[Flooz sharedInstance] invitationTexts]) {
        _smsText = [[Flooz sharedInstance] invitationTexts].shareMultiSms;
    } else {
        [[Flooz sharedInstance] invitationText:^(FLInvitationTexts *result) {
            _smsText = result.shareMultiSms;
        } failure:^(NSError *error) {
            
        }];
    }
    
    self.navigationItem.rightBarButtonItem = searchItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_contactsFromAdressBook == nil || _contactsFromAdressBook.count == 0)
        [self requestAddressBookPermission];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)searchUser:(NSString *)searchString {
    _selectionText = searchString;
    if ([searchString isEqualToString:@""]){
        [timer invalidate];
        _filteredContacts = [_friends copy];
        
        if ([_filteredContacts count] == 0)
            _filteredContacts = _contactsFromAdressBook;
        [_tableView reloadData];
    } else {
        [self didFilterChange];
    }
}

- (void)didFilterChange {
    if ([_selectionText rangeOfString:@"@"].location == 0) {
        _selectionText = [_selectionText substringFromIndex:1];
    }
    
    if (!_selectionText || [_selectionText isBlank]) {
        [_tableView reloadData];
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
        
        [[Flooz sharedInstance] friendSearch:_selectionText forNewFlooz:NO withPhones:phoneArray success: ^(id result, NSString *searchString) {
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
            
            [_tableView reloadData];
        }];
    } else {
        _filteredContacts = [_friends copy];
        
        if ([_filteredContacts count] == 0)
            _filteredContacts = _contactsFromAdressBook;
        
        [_tableView reloadData];
    }
}

- (void)showSearch {
    if ([_searchBar isHidden]) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [_searchBar setHidden:NO];
            CGRectSetY(_searchBar.frame, 5);
            CGRectSetY(_tableView.frame, CGRectGetMaxY(_searchBar.frame) + 5);
            CGRectSetHeight(_tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_searchBar.frame) - FLActionButtonDefaultHeight - 15);
        } completion:^(BOOL finished) {
            [_searchBar becomeFirstResponder];
        }];
    } else {
        [_searchBar close];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRectSetY(_searchBar.frame, -45);
            CGRectSetY(_tableView.frame, CGRectGetMaxY(_searchBar.frame) + 5);
            CGRectSetHeight(_tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_searchBar.frame) - FLActionButtonDefaultHeight - 15);
        } completion:^(BOOL finished) {
            [_searchBar setHidden:YES];
        }];
    }
}

- (void)sendButtonClick {
    if (selectedContacts.count) {
        NSMutableArray *array = [NSMutableArray new];
        
        for (FLUser *user in selectedContacts) {
            if (user.userKind == FloozUser) {
                [array addObject:user.userId];
            } else {
                [array addObject:user.phone];
            }
        }
        
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] collectInvite:_collectId invitations:array success:nil failure:nil];
    }
}

#pragma mark - TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!_selectionText || [_selectionText isBlank]) {
        if (section == 0) {
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
            if ([_friends count] || (!_friends.count && !_contactsFromAdressBook.count))
                return 35;
            return CGFLOAT_MIN;
        } else {
            if ([_contactsFromAdressBook count])
                return 35;
            return CGFLOAT_MIN;
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
        if ([_contactsFromAdressBook count] || [_friends count])
            return [ShareCell getHeight];
        return [FriendPickerEmptyCell getHeight];
    } else {
        if ([_filteredContacts count])
            return [ShareCell getHeight];
        return [FriendPickerEmptyCell getHeight];
    };
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_selectionText || [_selectionText isBlank]) {
        if (section == 0) {
            if (![_friends count] && ![_contactsFromAdressBook count])
                return 1;
            return [_friends count];
        } else {
            return [_contactsFromAdressBook count];
        }
    } else {
        if ([_filteredContacts count])
            return [_filteredContacts count];
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!_selectionText || [_selectionText isBlank])
        return 2;
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLUser *currentUser;
    
    if (!_selectionText || [_selectionText isBlank]) {
        if (indexPath.section == 0 && ![_contactsFromAdressBook count] && ![_friends count]) {
            return [self createEmptyCell:tableView];
        } else if (indexPath.section == 0 && [_friends count]) {
            currentUser = _friends[indexPath.row];
        } else {
            currentUser = _contactsFromAdressBook[indexPath.row];
        }
    } else {
        if (![_filteredContacts count])
            return [self createEmptyCell:tableView];
        
        if (_filteredContacts.count >= indexPath.row + 1)
            currentUser = _filteredContacts[indexPath.row];
    }
    
    static NSString *cellIdentifier = @"ShareCell";
    ShareCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[ShareCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (currentUser) {
        currentUser.isIdentified = YES;
        currentUser.isFloozer = NO;
        [cell setUser:currentUser];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", currentUser.userId];
        NSArray *filtered = [selectedContacts filteredArrayUsingPredicate:predicate];
        
        if ([selectedContacts containsObject:currentUser] || filtered.count)
            [cell setOn];
        else
            [cell setOff];
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
    FLUser *currentUser;
    
    if (!_selectionText || [_selectionText isBlank]) {
        if (indexPath.section == 0 && ![_contactsFromAdressBook count] && ![_friends count]) {
            return;
        } else if (indexPath.section == 0 && [_friends count]) {
            currentUser = _friends[indexPath.row];
        } else {
            currentUser = _contactsFromAdressBook[indexPath.row];
        }
    } else {
        if (![_filteredContacts count])
            return ;
        
        if (_filteredContacts.count >= indexPath.row + 1)
            currentUser = _filteredContacts[indexPath.row];
    }
    
    if (currentUser) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", currentUser.userId];
        NSArray *filtered = [selectedContacts filteredArrayUsingPredicate:predicate];
        
        if (![selectedContacts containsObject:currentUser] && !filtered.count)
            [selectedContacts addObject:currentUser];
        else {
            [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
            return;
        }
        
        if ([selectedContacts count] && ![_sendButton isEnabled]) {
            [_sendButton setEnabled:YES];
        }
        
        [_sendButton setTitle:[NSString stringWithFormat:@"%@ (%lu)", buttonTitle, (unsigned long)[selectedContacts count]] forState:UIControlStateNormal];
    }
    
    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    FLUser *currentUser;
    
    if (!_selectionText || [_selectionText isBlank]) {
        if (indexPath.section == 0 && ![_contactsFromAdressBook count] && ![_friends count]) {
            return;
        } else if (indexPath.section == 0 && [_friends count]) {
            currentUser = _friends[indexPath.row];
        } else {
            currentUser = _contactsFromAdressBook[indexPath.row];
        }
    } else {
        if (![_filteredContacts count])
            return;
        
        if (_filteredContacts.count >= indexPath.row + 1)
            currentUser = _filteredContacts[indexPath.row];
    }
    
    if (currentUser) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", currentUser.userId];
        NSArray *filtered = [selectedContacts filteredArrayUsingPredicate:predicate];
        
        if ([selectedContacts containsObject:currentUser])
            [selectedContacts removeObject:currentUser];
        else if (filtered.count) {
            [selectedContacts removeObject:filtered[0]];
        }
        
        [_sendButton setTitle:[NSString stringWithFormat:@"%@ (%lu)", buttonTitle, (unsigned long)[selectedContacts count]] forState:UIControlStateNormal];
        
        if (![selectedContacts count] && [_sendButton isEnabled]) {
            [_sendButton setEnabled:NO];
            [_sendButton setTitle:buttonTitle forState:UIControlStateNormal];
        }
    }
    
    [tableView reloadData];
}

- (void)scrollViewDidScroll:(id)scrollView {
    [_searchBar close];
}

- (void)didFilterChange:(NSString *)text {
    [self searchUser:text];
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
        for (CFIndex j = 0; j < ABMultiValueGetCount(phoneNumbers); ++j) {
            NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, j);
            
            FLUser *contact = [FLUser new];
            
            contact.userId = [NSString stringWithFormat:@"%d00%ld", i, j];
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
    
    [_tableView reloadData];
    //    [self loadVisibleUsers];
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
