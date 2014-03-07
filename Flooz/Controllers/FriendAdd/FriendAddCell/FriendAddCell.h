//
//  FriendAddCell.h
//  Flooz
//
//  Created by jonathan on 3/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendAddCell : UITableViewCell

+ (CGFloat)getHeight;

@property (weak, nonatomic) FLUser *user;

@end
