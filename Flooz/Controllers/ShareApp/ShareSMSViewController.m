//
//  ShareSMSViewController.m
//  Flooz
//
//  Created by Epitech on 10/8/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "ShareCell.h"
#import "ShareSMSViewController.h"
#import "FriendAddSearchBar.h"

@interface ShareSMSViewController () {
    UIBarButtonItem *searchItem;
    
    FriendAddSearchBar *_searchBar;
    FLTableView *_tableView;
    FLActionButton *_sendButton;
    
    NSMutableArray *keysOrdered;
    
    NSMutableDictionary *splitSearch;
    NSMutableDictionary *splitContacts;
    
    NSMutableArray *contactsFromSearch;
    NSMutableArray *contactsFromAdressBook;
    
    NSMutableArray *selectedContacts;
    
    NSString *_smsText;
    
    BOOL isSearching;
    
    NSString *searchString;
    
    NSString *buttonTitle;
}

@end

@implementation ShareSMSViewController

- (id)init {
    self = [super init];
    if (self) {
        NSString *dicKeys = @"ABCDEFGHIJKLMNOPGRSTUVWXYZ#";
        
        keysOrdered = [NSMutableArray new];
        selectedContacts = [NSMutableArray new];
        
        for (int i = 0; i < dicKeys.length; i++) {
            [keysOrdered addObject:[dicKeys substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    buttonTitle = NSLocalizedString(@"GLOBAL_INVITE", nil);
    
    if ([[Flooz sharedInstance] currentTexts]) {
        self.title = [[Flooz sharedInstance] currentTexts].menu[@"sms"][@"title"];
        buttonTitle = [[Flooz sharedInstance] currentTexts].menu[@"sms"][@"button"];
    } else {
        [[Flooz sharedInstance] textObjectFromApi:^(FLTexts *result) {
            self.title = result.menu[@"sms"][@"title"];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!contactsFromAdressBook)
        [self requestAddressBookPermission];
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
    if ([MFMessageComposeViewController canSendText]) {
        NSMutableArray *phonesList = [NSMutableArray new];
        
        for (FLUser *user in selectedContacts) {
            [phonesList addObject:user.phone];
        }
        
        MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
        message.messageComposeDelegate = self;
        
        [message setRecipients:phonesList];
        [message setBody:_smsText];
        
        [[Flooz sharedInstance] showLoadView];
        message.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:message animated:YES completion:^{
            [[Flooz sharedInstance] hideLoadView];
        }];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion: ^{
        if (result == MessageComposeResultSent) {
            [[Flooz sharedInstance] sendInvitationMetric:@"sms" withTotal:selectedContacts.count];
            [selectedContacts removeAllObjects];
            [self reloadTableView];
        }
        else if (result == MessageComposeResultCancelled) {
            [self reloadTableView];
        }
        else if (result == MessageComposeResultFailed) {
            [self reloadTableView];
        }
    }];
}

- (void)reloadTableView {
    [_tableView reloadData];
    
    for (FLUser *user in selectedContacts) {
        NSString *firstLetter = [[user.fullname substringToIndex:1] uppercaseString];
        
        NSMutableArray *alphaArray;
        
        NSInteger section = [keysOrdered indexOfObject:firstLetter];
        NSInteger row;
        
        if (section != NSNotFound) {
            if (isSearching)
                alphaArray = splitSearch[firstLetter];
            else
                alphaArray = splitContacts[firstLetter];
        } else {
            section = [keysOrdered indexOfObject:@"#"];
            if (isSearching)
                alphaArray = splitSearch[@"#"];
            else
                alphaArray = splitContacts[@"#"];
        }
        
        if (alphaArray) {
            row = [alphaArray indexOfObject:user];
            
            if (row != NSNotFound) {
                [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
}

#pragma mark - TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return keysOrdered[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return keysOrdered.count;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearching)
        return [splitSearch[keysOrdered[section]] count];
    
    return [splitContacts[keysOrdered[section]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView numberOfRowsInSection:section])
        return 35;
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ShareCell getHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView numberOfRowsInSection:section]) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), [self tableView:tableView heightForHeaderInSection:section])];
        [headerView setBackgroundColor:[UIColor customBackground]];
        
        UILabel *headerTitle = [[UILabel alloc] initWithText:keysOrdered[section] textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15]];
        
        [headerView addSubview:headerTitle];
        
        CGRectSetX(headerTitle.frame, 14);
        CGRectSetY(headerTitle.frame, CGRectGetHeight(headerView.frame) / 2 - CGRectGetHeight(headerTitle.frame) / 2 + 1);
        
        return headerView;
    }
    return [UIView new];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ShareCell";
    ShareCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[ShareCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FLUser *contact;
    
    if (isSearching) {
        contact = [splitSearch[keysOrdered[indexPath.section]] objectAtIndex:indexPath.row];
    } else {
        contact = [splitContacts[keysOrdered[indexPath.section]] objectAtIndex:indexPath.row];
    }
    
    [cell setUser:contact];
    
    if ([selectedContacts containsObject:contact])
        [cell setSelected:YES];
    else
        [cell setSelected:NO];
    
    return cell;
}

- (void)dismiss {
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FLUser *contact;
    
    if (isSearching) {
        contact = [splitSearch[keysOrdered[indexPath.section]] objectAtIndex:indexPath.row];
    } else {
        contact = [splitContacts[keysOrdered[indexPath.section]] objectAtIndex:indexPath.row];
    }
    
    if (![selectedContacts containsObject:contact])
        [selectedContacts addObject:contact];
    
    if ([selectedContacts count] && ![_sendButton isEnabled]) {
        [_sendButton setEnabled:YES];
    }
    
    [_sendButton setTitle:[NSString stringWithFormat:@"%@ (%lu)", buttonTitle, (unsigned long)[selectedContacts count]] forState:UIControlStateNormal];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    FLUser *contact;
    
    if (isSearching) {
        contact = [splitSearch[keysOrdered[indexPath.section]] objectAtIndex:indexPath.row];
    } else {
        contact = [splitContacts[keysOrdered[indexPath.section]] objectAtIndex:indexPath.row];
    }
    
    if ([selectedContacts containsObject:contact])
        [selectedContacts removeObject:contact];
    
    [_sendButton setTitle:[NSString stringWithFormat:@"%@ (%lu)", buttonTitle, (unsigned long)[selectedContacts count]] forState:UIControlStateNormal];
    
    if (![selectedContacts count] && [_sendButton isEnabled]) {
        [_sendButton setEnabled:NO];
        [_sendButton setTitle:buttonTitle forState:UIControlStateNormal];
    }
}

- (void)scrollViewDidScroll:(id)scrollView {
    [_searchBar close];
}

- (void)loadVisibleUsers {
    NSMutableArray *visiblePhone = [NSMutableArray new];
    
    NSArray *visibleCells = _tableView.visibleCells;
    
    for (ShareCell *cell in visibleCells) {
        if (!cell.user.isIdentified)
            [visiblePhone addObject:cell.user.phone];
    }
    
    [[Flooz sharedInstance] checkContactList:visiblePhone success:^(NSArray *result) {
        for (NSDictionary *dic in result) {
            for (FLUser *user in contactsFromAdressBook) {
                if ([user.phone isEqualToString:dic[@"phone"]]) {
                    user.isIdentified = YES;
                    user.isFloozer = [dic[@"isUser"] boolValue];
                }
            }
        }
        [self reloadTableView];
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadVisibleUsers];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate)
        [self loadVisibleUsers];
}

- (void)didFilterChange:(NSString *)text {
    searchString = text;
    
    if ([searchString isBlank]) {
        isSearching = NO;
        [self reloadTableView];
        [self loadVisibleUsers];
        return;
    }
    
    isSearching = YES;
    
    NSMutableArray *contactsFiltered = [NSMutableArray new];
    
    for (FLUser *contact in contactsFromAdressBook) {
        if (contact.fullname && [[contact.fullname lowercaseString] rangeOfString:[searchString lowercaseString]].location == 0) {
            [contactsFiltered addObject:contact];
        }
        else if (contact.firstname && [[contact.firstname lowercaseString] rangeOfString:[searchString lowercaseString]].location == 0) {
            [contactsFiltered addObject:contact];
        }
        else if (contact.lastname && [[contact.lastname lowercaseString] rangeOfString:[searchString lowercaseString]].location == 0) {
            [contactsFiltered addObject:contact];
        }
        else if ([FLHelper phoneMatch:contact.phone withPhone:searchString]) {
            [contactsFiltered addObject:contact];
        }
    }
    
    contactsFromSearch = contactsFiltered;
    splitSearch = [self splitArrayByFirstLetter:contactsFromSearch];
    [self reloadTableView];
    [self loadVisibleUsers];
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
    
    contactsFromAdressBook = [NSMutableArray new];
    
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
            
            [contactsFromAdressBook addObject:contact];
        }
    }
    
    contactsFromAdressBook = [self processContacts:contactsFromAdressBook];
    splitContacts = [self splitArrayByFirstLetter:contactsFromAdressBook];
    
    [self reloadTableView];
    [self loadVisibleUsers];
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

- (NSMutableDictionary *) splitArrayByFirstLetter:(NSArray *)array {
    
    NSMutableDictionary *sortedContacts = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < keysOrdered.count; i++) {
        [sortedContacts setObject:[NSMutableArray new] forKey:keysOrdered[i]];
    }
    
    for (FLUser *user in array) {
        NSString *firstLetter = [[user.fullname substringToIndex:1] uppercaseString];
        
        if ([keysOrdered indexOfObject:firstLetter] != NSNotFound)
            [[sortedContacts objectForKey:firstLetter] addObject:user];
        else
            [[sortedContacts objectForKey:@"#"] addObject:user];
    }
    
    return sortedContacts;
}

@end
