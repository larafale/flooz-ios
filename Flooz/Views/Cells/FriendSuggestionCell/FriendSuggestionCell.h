//
//  FriendSuggestionCell.h
//  Flooz
//
//  Created by jonathan on 2/28/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendRequestCellDelegate.h"

@interface FriendSuggestionCell : UITableViewCell

+ (CGFloat)getHeight;
@property (weak, nonatomic) FLUser *friend;

@property (weak, nonatomic) id<FriendRequestCellDelegate> delegate;

@end
