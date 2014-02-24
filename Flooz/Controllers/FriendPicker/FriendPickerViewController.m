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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    
    [self requestAddressBookPermission];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:NULL];
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
    NSString *title = nil;
    NSString *value = nil;
    
    if(indexPath.section == 0){
        title = _selectionText;
        value = _selectionText;
    }
    else{
        title = [[_contacts objectAtIndex:indexPath.row] objectForKey:@"title"];
        value = [[_contacts objectAtIndex:indexPath.row] objectForKey:@"value"];
    }
    
    [_dictionary setValue:title forKey:@"toTitle"];
    [_dictionary setValue:value forKey:@"to"];
    
    [self dismiss];
}

#pragma mark -

- (void)didfilterChange:(NSString *)text
{
    _selectionText = text;
    
    if(!text || [text isBlank]){
        _contacts = _contactsFromAdressBook;
        [self didTableDataChanged];
        return;
    }
    
    NSMutableArray *contactsFiltred = [NSMutableArray new];
    
    for(NSDictionary *contact in _contactsFromAdressBook){
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
        
        NSString *phone = nil;
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); ++i) {
            phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            break;
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
        name = [name uppercaseString];
        

        NSMutableDictionary *contact = [NSMutableDictionary new];
        
        [contact setValue:name forKey:@"name"];
        [contact setValue:email forKey:@"email"];
        [contact setValue:phone forKey:@"phone"];
        [contact setValue:image forKey:@"image"];
        
        // Valeur a afficher pour l utilisateur
        if([contact objectForKey:@"name"] && ![[contact objectForKey:@"name"] isBlank]){
            [contact setValue:name forKey:@"title"];
        }
        else if([contact objectForKey:@"phone"] && ![[contact objectForKey:@"phone"] isBlank]){
            [contact setValue:phone forKey:@"title"];
        }
        else if([contact objectForKey:@"email"] && ![[contact objectForKey:@"email"] isBlank]){
            [contact setValue:email forKey:@"title"];
        }
        
        // Valeur a envoyer sur l API
        if([contact objectForKey:@"phone"] && ![[contact objectForKey:@"phone"] isBlank]){
            [contact setValue:phone forKey:@"value"];
            [_contactsFromAdressBook addObject:contact];
        }
        else if([contact objectForKey:@"email"] && ![[contact objectForKey:@"email"] isBlank]){
            [contact setValue:email forKey:@"value"];
            [_contactsFromAdressBook addObject:contact];
        }
    }
    
    // rewrite phone format 0612345678 https://github.com/iziz/libPhoneNumber-iOS
    // _contactsFromAdressBook sort by name
    
    _contactsFromAdressBook = [[_contactsFromAdressBook sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return [[a objectForKey:@"title"] compare:[b objectForKey:@"title"]];
    }] mutableCopy];
    
    _contacts = _contactsFromAdressBook;
    [self didTableDataChanged];
}

@end
