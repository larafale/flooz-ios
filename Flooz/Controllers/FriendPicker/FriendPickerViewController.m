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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    
    [self requestAddressBookPermission];
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
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        if(_selectionText && ![_selectionText isBlank]){
            return 1;
        }
        return 0;
    }
    return [_contacts count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [FriendPickerContactCell getHeight];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        static NSString *cellIdentifierSelection = @"FriendPickerSelectionCell";
        FriendPickerSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSelection];
        
        if(!cell){
            cell = [[FriendPickerSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierSelection];
        }
        
        [cell setSelectionText:_selectionText];
        
        return cell;
    }
    
    static NSString *cellIdentifier = @"FriendPickerContactCell";
    FriendPickerContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[FriendPickerContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *contact = [_contacts objectAtIndex:indexPath.row];
    [cell setContact:contact];
    
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
    
    [self dismiss];
}

#pragma mark -

- (void)didFilterChange:(NSString *)text
{
    _selectionText = text;
    
    if(!text || [text isBlank]){
        _contacts = _currentContacts;
        [self didTableDataChanged];
        return;
    }
    
    NSMutableArray *contactsFiltred = [NSMutableArray new];
    
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
    }
    
    _contacts = contactsFiltred;
    [self didTableDataChanged];
}

- (void)didTableDataChanged
{
    [_tableView reloadData];
    [_tableView setContentOffset:CGPointZero animated:YES];
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
        
        NSString *email = nil;
        ABMutableMultiValueRef emailList  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if(ABMultiValueGetCount(emailList) > 0) {
            email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailList, 0);
        }
        
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

        ABMultiValueRef phoneNumbers = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); ++i) {
            NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, i);

            NSMutableDictionary *contact = [NSMutableDictionary new];
            
            [contact setValue:name forKey:@"name"];
            [contact setValue:email forKey:@"email"];
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

@end
