//
//  AddressBookController.h
//  Flooz
//
//  Created by Olive on 1/22/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "AddressBookFormController.h"

@protocol AddressBookPickerDelegate

- (void)didAddressPicked:(FLAddress *)address;

@end

@interface AddressBookController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

- (void)setPickerMode:(id<AddressBookPickerDelegate>)delegate;

@end
