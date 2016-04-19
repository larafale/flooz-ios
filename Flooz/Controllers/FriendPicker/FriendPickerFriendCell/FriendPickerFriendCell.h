//
//  FriendPickerFriendCell.h
//  Flooz
//
//  Created by Olivier on 2014-03-17.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendPickerFriendCell : UITableViewCell

+ (CGFloat)getHeight;

@property (weak, nonatomic) FLUser *user;

- (void)setSelectedCheckView:(BOOL)selected;

@end
