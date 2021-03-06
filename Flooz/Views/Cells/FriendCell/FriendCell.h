//
//  FriendCell.h
//  Flooz
//
//  Created by Olivier on 2/20/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendRequestCellDelegate.h"
#import "FLSocialHelper.h"

@interface FriendButton : UIButton {
//    FLUserView *avatarView;
}

@end

@interface FriendCell : UITableViewCell

+ (CGFloat)getHeight;
- (void)hideAddButton;
- (void)showAddButton;

@property (weak, nonatomic) FLUser *friend;
@property (weak, nonatomic) id <FriendRequestCellDelegate> delegate;
@property (strong, nonatomic) FLUserView *avatarView;

@property (strong, nonatomic) FLActionButton *removeButton;
@property (strong, nonatomic) FLBorderedActionButton *addButton;

@end
