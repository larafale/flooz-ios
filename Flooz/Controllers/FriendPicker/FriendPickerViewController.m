//
//  FriendPickerViewController.m
//  Flooz
//
//  Created by olivier on 2/6/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FriendPickerViewController.h"

#import "FriendPickerSelectionCell.h"
#import "FriendPickerContactCell.h"
#import "FriendPickerFriendCell.h"

#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>

#import "FriendCell.h"

@implementation FriendPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		_contacts = @[];
		_contactsFromAdressBook = [NSMutableArray new];
		_contactsFromFacebook = [NSMutableArray new];

		_friends = [[[[Flooz sharedInstance] currentUser] friends] copy];
		_friendsRecent = [[[[Flooz sharedInstance] currentUser] friendsRecent] copy];

		_friendsFiltred = _friends;
		_friendsRecentFiltred = _friendsRecent;

		_friendsSearch = [NSMutableArray new];

		_selectedIndexPath = [NSMutableArray new];
        
        self.title = NSLocalizedString(@"NAV_NEW_FLOOZ_FRIENDS", nil);
        
        self.isFirstView = NO;
        
        [[Flooz sharedInstance] updateCurrentUserWithSuccess:^{
            _friends = [[[[Flooz sharedInstance] currentUser] friends] copy];
            _friendsRecent = [[[[Flooz sharedInstance] currentUser] friendsRecent] copy];
            _friendsFiltred = _friends;
            _friendsRecentFiltred = _friendsRecent;
            
            [self.tableView reloadData];
        }];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Sinon contentInset de tableview mauvais
	[self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    float currentY = STATUSBAR_HEIGHT;
    
    currentY += NAVBAR_HEIGHT + 5;
    
    _searchBar = [FriendPickerSearchBar newWithFrame:CGRectMake(0, currentY, SCREEN_WIDTH, 40)];
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    
    currentY += 50;
    
    _tableView = [FLTableView newWithFrame:CGRectMake(0, currentY, SCREEN_WIDTH, SCREEN_HEIGHT - currentY)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor customBackgroundHeader];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:_tableView];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];

	[self registerForKeyboardNotifications];
	[self requestAddressBookPermission];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[[self navigationController] navigationBar] setHidden:YES];
}

- (void)dismiss {
	if ([self navigationController]) {
		[[self navigationController] popViewControllerAnimated:YES];
	}
	else {
		// WARNING enorme bug si arrive sur la vue attend 5s, click sur un contact, il y a une latence de 10s, mais uniquement la 1ere fois et seulement si choisit un contact (pas si bouton back)
		//        [self dismissViewControllerAnimated:YES completion:nil];
		[UIView animateWithDuration:.3
		                 animations: ^{
		    CGRectSetY(self.view.frame, SCREEN_HEIGHT);
		}

		                 completion: ^(BOOL finished) {
		    [self dismissViewControllerAnimated:NO completion:NULL];
		}];
	}
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 2) {
		return NSLocalizedString(@"FRIEND_PCIKER_SELECTION_CELL", nil);
	}
	else if (section == 0) {
		return NSLocalizedString(@"FRIEND_PICKER_FRIENDS_RECENT", nil);
	}
	else if (section == 1) {
		return NSLocalizedString(@"FRIEND_PICKER_FRIENDS", nil);
	}

	return NSLocalizedString(@"FRIEND_PICKER_ADDRESS_BOOK", nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 2 && (!_selectionText || [_selectionText isBlank] || ![_friendsSearch count])) {
		return 0;
	}
	else if (section == 0 && [_friendsRecentFiltred count] == 0) {
		return 0;
	}
	else if (section == 1 && [_friendsFiltred count] == 0) {
		return 0;
	}
	else if (section == 3 && [_contacts count] == 0) {
		return 0;
	}

	return 26;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	CGFloat heigth = [self tableView:tableView heightForHeaderInSection:section];

	UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(tableView.frame), heigth)];

	view.backgroundColor = [UIColor customBackground];

	{
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 0, CGRectGetHeight(view.frame))];

		label.textColor = [UIColor customBlueLight];

		label.font = [UIFont customContentRegular:14];
		label.text = [self tableView:tableView titleForHeaderInSection:section];
		[label setWidthToFit];

		[view addSubview:label];
	}

	return view;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 2) {
		if (_selectionText || ![_selectionText isBlank]) {
			return [_friendsSearch count];
		}
		return 0;
	}
	else if (section == 0) {
		return [_friendsRecentFiltred count];
	}
	else if (section == 1) {
		return [_friendsFiltred count];
	}

	return [_contacts count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [FriendPickerContactCell getHeight];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2) {
		static NSString *cellIdentifier = @"FriendAddCell";
		FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

		if (!cell) {
			cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}

		FLUser *user = [_friendsSearch objectAtIndex:indexPath.row];
		[cell setFriend:user];
		[cell hideAddButton];
		return cell;
	}
	else if (indexPath.section == 0 || indexPath.section == 1) {
		static NSString *cellIdentifierSelection = @"FriendPickerFriendCell";
		FriendPickerFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSelection];

		if (!cell) {
			cell = [[FriendPickerFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierSelection];
		}

		if (indexPath.section == 0) {
			[cell setUser:[_friendsRecentFiltred objectAtIndex:indexPath.row]];
		}
		else {
			[cell setUser:[_friendsFiltred objectAtIndex:indexPath.row]];
		}

		[cell setSelectedCheckView:[_selectedIndexPath containsObject:indexPath]];
		return cell;
	}

	static NSString *cellIdentifier = @"FriendPickerContactCell";
	FriendPickerContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if (!cell) {
		cell = [[FriendPickerContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}

	NSDictionary *contact = [_contacts objectAtIndex:indexPath.row];
	[cell setContact:contact];

	[cell setSelectedCheckView:[_selectedIndexPath containsObject:indexPath]];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *contact;
	NSString *title;
	NSString *value;
    NSString *from;

	if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2) {
		FLUser *friend;

		if (indexPath.section == 2) {
			friend = _friendsSearch[indexPath.row];
            [friend setSelectedCanal:SearchCanal];
		}
		else if (indexPath.section == 0) {
			friend = [_friendsRecentFiltred objectAtIndex:indexPath.row];
            [friend setSelectedCanal:RecentCanal];
        }
		else {
			friend = [_friendsFiltred objectAtIndex:indexPath.row];
            [friend setSelectedCanal:FriendsCanal];
		}


		contact = [NSMutableDictionary new];

		if ([friend firstname] && ![[friend firstname] isBlank]) {
			[contact setValue:[friend firstname] forKeyPath:@"firstname"];
		}

		if ([friend lastname] && ![[friend lastname] isBlank]) {
			[contact setValue:[friend lastname] forKeyPath:@"lastname"];
		}

		if ([friend username] && ![[friend username] isBlank]) {
			[contact setValue:[friend username] forKeyPath:@"username"];
		}

		if ([friend avatarURL] && ![[friend avatarURL] isBlank]) {
			[contact setValue:[friend avatarURL] forKeyPath:@"image_url"];
		}

		title = [friend fullname];
		value = [friend username];
        from = [friend selectedFrom];
	}
	else {
		contact = [_contacts objectAtIndex:indexPath.row];
		title = [contact objectForKey:@"title"];
		value = [contact objectForKey:@"value"];
        FLUser *tmp = [FLUser new];
        [tmp setSelectedCanal:ContactCanal];
        from = tmp.selectedFrom;
	}

	[_dictionary setValue:title forKey:@"toTitle"];
	[_dictionary setValue:value forKey:@"to"];
    [_dictionary setValue:@{@"selectedFrom":from} forKey:@"metrics"];

	if ([contact objectForKey:@"facebook_id"]) {
		id paramsFacebook = @{
			@"id": [contact objectForKey:@"facebook_id"],
			@"firstName": [contact objectForKey:@"firstname"],
			@"lastName": [contact objectForKey:@"lastname"]
		};
		[_dictionary setValue:paramsFacebook forKey:@"fb"];
	}
	else {
		[_dictionary setValue:nil forKey:@"fb"];
	}

	[_dictionary setValue:nil forKey:@"toImage"];
	[_dictionary setValue:nil forKey:@"toImageUrl"];

	if ([contact objectForKey:@"image"]) {
		[_dictionary setValue:[contact objectForKey:@"image"] forKey:@"toImage"];
	}
	else if ([contact objectForKey:@"image_url"]) {
		[_dictionary setValue:[contact objectForKey:@"image_url"] forKey:@"toImageUrl"];
	}

	[_dictionary setValue:nil forKey:@"contact"];
	if ([contact objectForKey:@"firstname"] || [contact objectForKey:@"lastname"]) {
		[_dictionary setValue:[NSMutableDictionary new] forKey:@"contact"];

		if (![[contact objectForKey:@"firstname"] isBlank]) {
			[[_dictionary objectForKey:@"contact"] setValue:[contact objectForKey:@"firstname"] forKey:@"firstName"];
		}

		if (![[contact objectForKey:@"lastname"] isBlank]) {
			[[_dictionary objectForKey:@"contact"] setValue:[contact objectForKey:@"lastname"] forKey:@"lastName"];
		}
	}

	if (![[contact objectForKey:@"username"] isBlank]) {
		[_dictionary setValue:[contact objectForKey:@"username"] forKey:@"toUsername"];
	}

    [self dismissViewController];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[_searchBar close];
}

- (void)dismissViewController {
    if (self.isFirstView && self.dictionary.count) {
        NewTransactionViewController *transacView = [[NewTransactionViewController alloc] initWithTransactionType:TransactionTypePayment];
        transacView.transaction = self.dictionary;
        
        [self presentViewController:[[FLNavigationController alloc] initWithRootViewController:transacView] animated:YES completion:NULL];
    }
    else
        [super dismissViewController];
}

#pragma mark -

- (void)didFilterChange:(NSString *)text {
	_selectionText = text;

	// Supprime le @ si text commence par @
	if ([text rangeOfString:@"@"].location == 0) {
		text = [text substringFromIndex:1];
	}

	if (!text || [text isBlank]) {
		_friendsSearch = @[];
		_contacts = _currentContacts;
		_friendsFiltred = _friends;
		_friendsRecentFiltred = _friendsRecent;
		[self didTableDataChanged];
		return;
	}

	NSMutableArray *contactsFiltred = [NSMutableArray new];
	NSMutableArray *friendsFiltred = [NSMutableArray new];
	NSMutableArray *friendsRecentFiltred = [NSMutableArray new];

	for (NSDictionary *contact in _currentContacts) {
		if ([contact objectForKey:@"name"] && [[[contact objectForKey:@"name"] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
			[contactsFiltred addObject:contact];
		}
		else if ([contact objectForKey:@"email"] && [[[contact objectForKey:@"email"] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
			[contactsFiltred addObject:contact];
		}
		else if ([contact objectForKey:@"phone"] && [[[contact objectForKey:@"phone"] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
			[contactsFiltred addObject:contact];
		}
		// Pour rechercher sur telephone sans les points
		else if ([contact objectForKey:@"value"]) {
			NSString *clearPhone = [contact objectForKey:@"value"];
			if ([clearPhone hasPrefix:@"+33"]) {
				clearPhone = [clearPhone stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@"0"];
			}
			if ([[clearPhone lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
				[contactsFiltred addObject:contact];
			}
			else if ([[[contact objectForKey:@"value"] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
				[contactsFiltred addObject:contact];
			}
		}
	}

	for (FLUser *user in _friends) {
		if ([user firstname] && [[[user firstname] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
			[friendsFiltred addObject:user];
		}
		else if ([user lastname] && [[[user lastname] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
			[friendsFiltred addObject:user];
		}
		else if ([user fullname] && [[[user fullname] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
			[friendsFiltred addObject:user];
		}
		else if ([user username] && [[[user username] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
			[friendsFiltred addObject:user];
		}
	}

	_contacts = contactsFiltred;
	_friendsFiltred = friendsFiltred;
	_friendsRecentFiltred = friendsRecentFiltred;

    [[Flooz sharedInstance] friendSearch:text forNewFlooz:YES withPhones:@[] success: ^(id result) {
	    _friendsSearch = result;
	    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
	    [_tableView setContentOffset:CGPointZero animated:YES];
	}];

	[self didTableDataChanged];
}

- (void)didTableDataChanged {
	[_tableView reloadData];
	[_tableView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Contacts

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

	// Doit avoir nom et (telephone ou email)
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

			NSMutableDictionary *contact = [NSMutableDictionary new];

			[contact setValue:firstName forKey:@"firstname"];
			[contact setValue:lastName forKey:@"lastname"];
			[contact setValue:name forKey:@"name"];
			[contact setValue:phone forKey:@"phone"];
			[contact setValue:image forKey:@"image"];

			[_contactsFromAdressBook addObject:contact];
		}
	}

	_contactsFromAdressBook = [self processContacts:_contactsFromAdressBook];
	[self loadAddressBookContacts];
}

- (NSMutableArray *)processContacts:(NSArray *)contacts {
	// Les contacts ont les champs name, phone, email, facebook_id, image OU image_url

	NSMutableArray *newContacts = [NSMutableArray new];

	for (NSDictionary *contact in contacts) {
		// Format contact
		if ([contact objectForKey:@"name"]) {
			[contact setValue:[[contact objectForKey:@"name"] uppercaseString] forKey:@"title"];
		}

		if ([contact objectForKey:@"phone"]) {
			[contact setValue:[FLHelper formatedPhone:[contact objectForKey:@"phone"]] forKey:@"phone"];
		}

		if ([contact objectForKey:@"phone"] && ![[contact objectForKey:@"phone"] isBlank]) {
			[contact setValue:[contact objectForKey:@"phone"] forKey:@"value"];
		}
		else if ([contact objectForKey:@"email"] && ![[contact objectForKey:@"email"] isBlank]) {
			[contact setValue:[contact objectForKey:@"email"] forKey:@"value"];
		}
		else if ([contact objectForKey:@"facebook_id"] && ![[contact objectForKey:@"facebook_id"] isBlank]) {
			[contact setValue:[contact objectForKey:@"facebook_id"] forKey:@"value"];
		}

		//Format téléphone
		if ([contact objectForKey:@"phone"]) {
			//[contact setValue:[FLHelper formatedPhoneForDisplay:[contact objectForKey:@"phone"]] forKey:@"phone"];
		}

		// Filtre les contacts invalide
		if ([contact objectForKey:@"title"] && [contact objectForKey:@"value"]) {
			[newContacts addObject:contact];
		}
	}

	newContacts = [[newContacts sortedArrayUsingComparator: ^NSComparisonResult (id a, id b) {
	    return [[a objectForKey:@"title"] compare:[b objectForKey:@"title"]];
	}] mutableCopy];

	return newContacts;
}

- (void)loadFacebookContacts {
	_currentContacts = _contacts = _contactsFromFacebook;
	[self didTableDataChanged];
}

- (void)loadAddressBookContacts {
	_currentContacts = _contacts = _contactsFromAdressBook;
	[self didTableDataChanged];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
	[self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
	[self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;

	_tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillDisappear {
	_tableView.contentInset = UIEdgeInsetsZero;
}

@end
