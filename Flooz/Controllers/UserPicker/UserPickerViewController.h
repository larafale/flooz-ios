//
//  UserPickerViewController.h
//  Flooz
//
//  Created by Olive on 07/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "FriendAddSearchBarDelegate.h"
#import "FLUserPickerTableView.h"

@interface UserPickerViewController : BaseViewController<FriendAddSearchBarDelegate, FLUserPickerTableViewDelegate>

@end
