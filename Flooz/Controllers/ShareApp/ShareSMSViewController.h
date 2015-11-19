//
//  ShareSMSViewController.h
//  Flooz
//
//  Created by Epitech on 10/8/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "FriendAddSearchBarDelegate.h"
#import <MessageUI/MFMessageComposeViewController.h>

@interface ShareSMSViewController : BaseViewController<FriendAddSearchBarDelegate, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate>

@end
