//
//  InviteFriendsViewController.h
//  Flooz
//
//  Created by Arnaud on 2014-09-02.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface InviteFriendsViewController : GlobalViewController <UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end
