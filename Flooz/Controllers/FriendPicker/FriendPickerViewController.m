//
//  FriendPickerViewController.m
//  Flooz
//
//  Created by jonathan on 2/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendPickerViewController.h"

#import "FriendPickerSelectionCell.h"
#import "FriendPickerContactCell.h"
#import "FriendPickerFriendCell.h"

#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>

@implementation FriendPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _contacts = @[];
        _contactsFromAdressBook = [NSMutableArray new];
        _contactsFromFacebook = [NSMutableArray new];
        
        _friends = [[[[Flooz sharedInstance] currentUser] friends] copy];
        _friendsRecent = [[[[Flooz sharedInstance] currentUser] friendsRecent] copy];
        
        _friendsFiltred = _friends;
        _friendsRecentFiltred = _friendsRecent;
        
        _selectedIndexPath = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Sinon contentInset de tableview mauvais
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];

    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self registerForKeyboardNotifications];
    [self requestAddressBookPermission];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[[self navigationController] navigationBar] setHidden:YES];
}

- (void)dismiss
{    
    if([self navigationController]){
        [[self navigationController] popViewControllerAnimated:YES];
    }
    else{
        // WARNING enorme bug si arrive sur la vue attend 5s, click sur un contact, il y a une latence de 10s, mais uniquement la 1ere fois et seulement si choisit un contact (pas si bouton back)
//        [self dismissViewControllerAnimated:YES completion:nil];
        [UIView animateWithDuration:.3
                         animations:^{
                             CGRectSetY(self.view.frame, SCREEN_HEIGHT);
                         }
                         completion:^(BOOL finished) {
                             [self dismissViewControllerAnimated:NO completion:NULL];
                         }];
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return NSLocalizedString(@"FRIEND_PCIKER_SELECTION_CELL", nil);
    }
    else if(section == 1){
        return NSLocalizedString(@"FRIEND_PICKER_FRIENDS_RECENT", nil);
    }
    else if(section == 2){
        return NSLocalizedString(@"FRIEND_PICKER_FRIENDS", nil);
    }
    
    return NSLocalizedString(@"FRIEND_PICKER_ADDRESS_BOOK", nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0 && (!_selectionText || [_selectionText isBlank])){
        return 0;
    }
    else if(section == 1 && [_friendsRecentFiltred count] == 0){
        return 0;
    }
    else if(section == 2 && [_friendsFiltred count] == 0){
        return 0;
    }
    else if(section == 3 && [_contacts count] == 0){
        return 0;
    }
    
    return 28;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat heigth = [self tableView:tableView heightForHeaderInSection:section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(tableView.frame), heigth)];
    
    view.backgroundColor = [UIColor customBackgroundHeader];
    
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 0, CGRectGetHeight(view.frame))];
        
        label.textColor = [UIColor customBlueLight];
        
        label.font = [UIFont customContentRegular:10];
        label.text = [self tableView:tableView titleForHeaderInSection:section];
        [label setWidthToFit];
        
        [view addSubview:label];
    }
    
    {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame), CGRectGetWidth(view.frame), 1)];
        
        separator.backgroundColor = [UIColor customSeparator];
        
        [view addSubview:separator];
    }
    
    return view;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        if(_selectionText && ![_selectionText isBlank]){
            return 1;
        }
        return 0;
    }
    else if(section == 1){
        return [_friendsRecentFiltred count];
    }
    else if(section == 2){
        return [_friendsFiltred count];
    }
    
    return [_contacts count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [FriendPickerContactCell getHeight];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
//        static NSString *cellIdentifierSelection = @"FriendPickerSelectionCell";
//        FriendPickerSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSelection];
//        
//        if(!cell){
//            cell = [[FriendPickerSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierSelection];
//        }
//        
//        [cell setSelectionText:_selectionText];
//        
//        return cell;
        
        static NSString *cellIdentifierSelection = @"FriendPickerSelectionCell";
        FriendPickerContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSelection];
        
        if(!cell){
            cell = [[FriendPickerContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierSelection];
        }
        
        NSDictionary *contact = @{ @"name" : _selectionText };
        [cell setContact:contact];
        [cell setSelectedCheckView:NO];
        
        return cell;
    }
    else if(indexPath.section == 1 || indexPath.section == 2){
        static NSString *cellIdentifierSelection = @"FriendPickerFriendCell";
        FriendPickerFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSelection];
        
        if(!cell){
            cell = [[FriendPickerFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierSelection];
        }
        
        if(indexPath.section == 1){
            [cell setUser:[_friendsRecentFiltred objectAtIndex:indexPath.row]];
        }
        else{
            [cell setUser:[_friendsFiltred objectAtIndex:indexPath.row]];
        }
        
        [cell setSelectedCheckView:[_selectedIndexPath containsObject:indexPath]];
        return cell;
    }
    
    static NSString *cellIdentifier = @"FriendPickerContactCell";
    FriendPickerContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[FriendPickerContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *contact = [_contacts objectAtIndex:indexPath.row];
    [cell setContact:contact];
    
    [cell setSelectedCheckView:[_selectedIndexPath containsObject:indexPath]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *contact;
    NSString *title;
    NSString *value;
    
    if(indexPath.section == 0){
        title = _selectionText;
        value = _selectionText;
    }
    else if(indexPath.section == 1 || indexPath.section == 2){
        FLUser *friend;
        if(indexPath.section == 1){
            friend = [_friendsRecentFiltred objectAtIndex:indexPath.row];
        }
        else{
            friend = [_friendsFiltred objectAtIndex:indexPath.row];
        }
        
        
        contact = [NSMutableDictionary new];
        
        if([friend firstname] && ![[friend firstname] isBlank]){
            [contact setValue:[friend firstname] forKeyPath:@"firstname"];
        }
        
        if([friend lastname] && ![[friend lastname] isBlank]){
            [contact setValue:[friend lastname] forKeyPath:@"lastname"];
        }
        
        if([friend username] && ![[friend username] isBlank]){
            [contact setValue:[friend username] forKeyPath:@"username"];
        }
        
        if([friend avatarURL] && ![[friend avatarURL] isBlank]){
            [contact setValue:[friend avatarURL] forKeyPath:@"image_url"];
        }
        
        title = [friend fullname];
        value = [friend username];
    }
    else{
        contact = [_contacts objectAtIndex:indexPath.row];
        title = [contact objectForKey:@"title"];
        value = [contact objectForKey:@"value"];
    }

    [_dictionary setValue:title forKey:@"toTitle"];
    [_dictionary setValue:value forKey:@"to"];
    
    if([contact objectForKey:@"facebook_id"]){
        id paramsFacebook = @{
                                  @"id": [contact objectForKey:@"facebook_id"],
                                  @"firstName": [contact objectForKey:@"firstname"],
                                  @"lastName": [contact objectForKey:@"lastname"]
                              };
        [_dictionary setValue:paramsFacebook forKey:@"fb"];
    }
    else{
        [_dictionary setValue:nil forKey:@"fb"];
    }
    
    [_dictionary setValue:nil forKey:@"toImage"];
    [_dictionary setValue:nil forKey:@"toImageUrl"];
    
    if([contact objectForKey:@"image"]){
        [_dictionary setValue:[contact objectForKey:@"image"] forKey:@"toImage"];
    }
    else if([contact objectForKey:@"image_url"]){
        [_dictionary setValue:[contact objectForKey:@"image_url"] forKey:@"toImageUrl"];
    }
    
    [_dictionary setValue:nil forKey:@"contact"];
    if([contact objectForKey:@"firstname"] || [contact objectForKey:@"lastname"]){
        [_dictionary setValue:[NSMutableDictionary new] forKey:@"contact"];
        
        if(![[contact objectForKey:@"firstname"] isBlank]){
            [[_dictionary objectForKey:@"contact"] setValue:[contact objectForKey:@"firstname"] forKey:@"firstName"];
        }
        
        if(![[contact objectForKey:@"lastname"] isBlank]){
            [[_dictionary objectForKey:@"contact"] setValue:[contact objectForKey:@"lastname"] forKey:@"lastName"];
        }
    }
    
    if(![[contact objectForKey:@"username"] isBlank]){
        [_dictionary setValue:[contact objectForKey:@"username"] forKey:@"toUsername"];
    }
    
    if(_event){
        [self inviteEvent:_dictionary];
        id cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setSelectedCheckView:YES];
        [_selectedIndexPath addObject:indexPath];
    }
    else{
        [self dismiss];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_searchBar close];
}

#pragma mark -

- (void)didFilterChange:(NSString *)text
{
    _selectionText = text;
    
    // Supprime le @ si text commence par @
    if([text rangeOfString:@"@"].location == 0){
        text = [text substringFromIndex:1];
    }
    
    if(!text || [text isBlank]){
        _contacts = _currentContacts;
        _friendsFiltred = _friends;
        _friendsRecentFiltred = _friendsRecent;
        [self didTableDataChanged];
        return;
    }
    
    NSMutableArray *contactsFiltred = [NSMutableArray new];
    NSMutableArray *friendsFiltred = [NSMutableArray new];
    NSMutableArray *friendsRecentFiltred = [NSMutableArray new];
    
    for(NSDictionary *contact in _currentContacts){
        if([contact objectForKey:@"name"] && [[[contact objectForKey:@"name"] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound){
            [contactsFiltred addObject:contact];
        }
        else if([contact objectForKey:@"email"] && [[[contact objectForKey:@"email"] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound){
            [contactsFiltred addObject:contact];
        }
        else if([contact objectForKey:@"phone"] && [[[contact objectForKey:@"phone"] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound){
            [contactsFiltred addObject:contact];
        }
        // Pour rechercher sur telephone sans les points
        else if([contact objectForKey:@"value"] && [[[contact objectForKey:@"value"] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound){
            [contactsFiltred addObject:contact];
        }
    }
    
    for(FLUser *user in _friends){
        if([user firstname] && [[[user firstname] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound){
            [friendsFiltred addObject:user];
        }
        else if([user lastname] && [[[user lastname] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound){
            [friendsFiltred addObject:user];
        }
        else if([user fullname] && [[[user fullname] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound){
            [friendsFiltred addObject:user];
        }
        else if([user username] && [[[user username] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound){
            [friendsFiltred addObject:user];
        }
    }
    
//    for(FLUser *user in _friendsRecent){
//        if([user firstname] && [[[user firstname] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound){
//            [friendsRecentFiltred addObject:user];
//        }
//        else if([user lastname] && [[[user lastname] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound){
//            [friendsRecentFiltred addObject:user];
//        }
//        else if([user fullname] && [[[user fullname] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound){
//            [friendsRecentFiltred addObject:user];
//        }
//        else if([user username] && [[[user username] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound){
//            [friendsRecentFiltred addObject:user];
//        }
//    }
    
    _contacts = contactsFiltred;
    _friendsFiltred = friendsFiltred;
    _friendsRecentFiltred = friendsRecentFiltred;
    
    [self didTableDataChanged];
}

- (void)didTableDataChanged
{
    [_tableView setContentOffset:CGPointZero animated:YES];
    [_tableView reloadData];
}

#pragma mark - Contacts

- (void)requestFacebookFriends
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] facebokSearchFriends:^(id result) {
        _contactsFromFacebook = [NSMutableArray new];
        
        for(NSDictionary *friend in result){
            NSMutableDictionary *contact = [NSMutableDictionary new];
            
            [contact setValue:[friend objectForKey:@"first_name"] forKey:@"firstname"];
            [contact setValue:[friend objectForKey:@"last_name"] forKey:@"lastname"];
            
            [contact setValue:[friend objectForKey:@"name"] forKey:@"name"];
            [contact setValue:[friend objectForKey:@"id"] forKey:@"facebook_id"];
            [contact setValue:[[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"] forKey:@"image_url"];
            
            [_contactsFromFacebook addObject:contact];
        }
        
        _contactsFromFacebook = [self processContacts:_contactsFromFacebook];
        [self loadFacebookContacts];
    }];
}

- (void)requestAddressBookPermission
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                [self didAddressBookPermissionGranted];
            } else {
                DISPLAY_ERROR(FLContactAccessDenyError);
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self didAddressBookPermissionGranted];
    }
    else {
        DISPLAY_ERROR(FLContactAccessDenyError);
    }
}

- (void)didAddressBookPermissionGranted
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    _contactsFromAdressBook = [NSMutableArray new];
    
    // Doit avoir nom et (telephone ou email)
    for(int i = 0; i < nPeople; ++i){
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);

        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonLastNameProperty));
        NSData *image = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
        
        NSString *name = nil;
        if(!firstName){
            name = lastName;
        }
        else if(!lastName){
            name = firstName;
        }
        else{
            name = [firstName stringByAppendingFormat:@" %@", lastName];
        }

        // Desactivé pour le moment
//        ABMultiValueRef emailList = ABRecordCopyValue(ref, kABPersonEmailProperty);
//        for (CFIndex i = 0; i < ABMultiValueGetCount(emailList); ++i) {
//            NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailList, i);
//
//            NSMutableDictionary *contact = [NSMutableDictionary new];
//            
//            [contact setValue:firstName forKey:@"firstname"];
//            [contact setValue:lastName forKey:@"lastname"];
//            [contact setValue:name forKey:@"name"];
//            [contact setValue:email forKey:@"email"];
//            [contact setValue:image forKey:@"image"];
//            
//            [_contactsFromAdressBook addObject:contact];
//        }
        
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

- (NSMutableArray *)processContacts:(NSArray *)contacts
{
    // Les contacts ont les champs name, phone, email, facebook_id, image OU image_url
    
    NSMutableArray *newContacts = [NSMutableArray new];
    
    for(NSDictionary *contact in contacts){
        // Format contact
        if([contact objectForKey:@"name"]){
            [contact setValue:[[contact objectForKey:@"name"] uppercaseString] forKey:@"title"];
        }
        
        if([contact objectForKey:@"phone"]){
            [contact setValue:[FLHelper formatedPhone:[contact objectForKey:@"phone"]] forKey:@"phone"];
        }
        
        if([contact objectForKey:@"phone"] && ![[contact objectForKey:@"phone"] isBlank]){
            [contact setValue:[contact objectForKey:@"phone"] forKey:@"value"];
        }
        else if([contact objectForKey:@"email"] && ![[contact objectForKey:@"email"] isBlank]){
            [contact setValue:[contact objectForKey:@"email"] forKey:@"value"];
        }
        else if([contact objectForKey:@"facebook_id"] && ![[contact objectForKey:@"facebook_id"] isBlank]){
            [contact setValue:[contact objectForKey:@"facebook_id"] forKey:@"value"];
        }
        
        //Format téléphone
        if([contact objectForKey:@"phone"]){
            [contact setValue:[FLHelper formatedPhoneForDisplay:[contact objectForKey:@"phone"]] forKey:@"phone"];
        }
                
        // Filtre les contacts invalide
        if([contact objectForKey:@"title"] && [contact objectForKey:@"value"]){
            [newContacts addObject:contact];
        }
    }
    
    newContacts = [[newContacts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return [[a objectForKey:@"title"] compare:[b objectForKey:@"title"]];
    }] mutableCopy];
    
    return newContacts;
}

- (void)didSourceFacebook:(BOOL)isFacebook
{
    if(isFacebook && [_contactsFromFacebook count] == 0){
        [self requestFacebookFriends];
        return;
    }

    if(isFacebook){
        [self loadFacebookContacts];
    }
    else{
        [self loadAddressBookContacts];
    }
}

- (void)loadFacebookContacts
{
    _currentContacts = _contacts = _contactsFromFacebook;
    [self didTableDataChanged];
}

- (void)loadAddressBookContacts
{
    _currentContacts = _contacts = _contactsFromAdressBook;
    [self didTableDataChanged];
}

#pragma mark - Event

- (void)inviteEvent:(NSDictionary *)friend
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] eventInvite:_event friend:friend success:^(id result) {
        [_event setJSON:[result objectForKey:@"item"]];
    }];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications
{
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillDisappear
{
    _tableView.contentInset = UIEdgeInsetsZero;
}

@end
