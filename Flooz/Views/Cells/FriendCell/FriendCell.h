//
//  FriendCell.h
//  Flooz
//
//  Created by jonathan on 2/20/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell

+ (CGFloat)height;
@property (weak, nonatomic) FLUser *friend;

@end
