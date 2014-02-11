//
//  FriendPickerViewController.m
//  Flooz
//
//  Created by jonathan on 2/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendPickerViewController.h"

#import "FriendPickerContactCell.h"

#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>

@interface FriendPickerViewController ()

@end

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

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_contacts count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [FriendPickerContactCell getHeight];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"FriendPickerContactCell";
    FriendPickerContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[FriendPickerContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *contact = [_contacts objectAtIndex:indexPath.row];
    [cell setContact:contact];
    
    return cell;
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
    // Que tel
    // filtre sur n importe quel champs
    // tel est prioritaire a l email
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    _contactsFromAdressBook = [NSMutableArray new];
    
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
        
        if([contact objectForKey:@"phone"] && ![[contact objectForKey:@"phone"] isBlank]){
            [contact setValue:phone forKey:@"value"];
            [_contactsFromAdressBook addObject:contact];
        }
        else if([contact objectForKey:@"email"] && ![[contact objectForKey:@"email"] isBlank]){
            [contact setValue:email forKey:@"value"];
            [_contactsFromAdressBook addObject:contact];
        }
    }
    
    _contacts = _contactsFromAdressBook;
    [self didTableDataChanged];
}

@end
