//
//  ShareAppViewController.h
//  Flooz
//
//  Created by Arnaud on 2014-09-02.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import "FriendPickerSearchBarDelegate.h"

@interface ShareAppViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, FriendPickerSearchBarDelegate>

@end
