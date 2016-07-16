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

@protocol UserPickerViewControllerDelegate

- (void)user:(FLUser *)user pickedFrom:(UIViewController *)viewController;

@end

@interface UserPickerViewController : BaseViewController<FriendAddSearchBarDelegate, FLUserPickerTableViewDelegate>

@property (nonatomic, weak) id<UserPickerViewControllerDelegate> delegate;

+ (id)newWithDelegate:(id<UserPickerViewControllerDelegate>)delegate;
- (id)initWithDelegate:(id<UserPickerViewControllerDelegate>)delegate;

@end
