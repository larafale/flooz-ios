//
//  FriendPickerFriendCell.h
//  Flooz
//
//  Created by jonathan on 2014-03-17.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendPickerFriendCell : UITableViewCell

+ (CGFloat)getHeight;

@property (weak, nonatomic) FLUser *user;

@end
