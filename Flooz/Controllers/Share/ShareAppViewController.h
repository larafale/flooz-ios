//
//  ShareAppViewController.h
//  Flooz
//
//  Created by Arnaud on 2014-09-02.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "WYPopoverController.h"

#import "FriendPickerSearchBarDelegate.h"
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface ShareAppViewController : BaseViewController <UIAlertViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, WYPopoverControllerDelegate, FBSDKSharingDelegate>

@end
