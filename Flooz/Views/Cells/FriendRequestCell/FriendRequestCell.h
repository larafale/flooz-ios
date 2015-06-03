//
//  FriendRequestCell.h
//  Flooz
//
//  Created by olivier on 2/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendRequestCellDelegate.h"

@interface FriendRequestCell : UITableViewCell {
	UIView *actionView;

	CGPoint totalTranslation;
	CGPoint lastTranslation;

	UIButton *_addButton;
}

+ (CGFloat)getHeight;

- (void)hideAddButton;
- (void)showAddButton;

@property (weak, nonatomic) id <FriendRequestCellDelegate> delegate;
@property (weak, nonatomic) FLFriendRequest *friendRequest;
@property (strong, nonatomic) FLUserView *avatarView;

@end
