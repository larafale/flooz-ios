//
//  FriendCell.h
//  Flooz
//
//  Created by jonathan on 2/20/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendRequestCellDelegate.h"

@interface FriendCell : UITableViewCell

+ (CGFloat)getHeight;
@property (weak, nonatomic) FLUser *friend;

@property (weak, nonatomic) id<FriendRequestCellDelegate> delegate;

@end
