//
//  FriendRequestCell.h
//  Flooz
//
//  Created by jonathan on 2/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendRequestCellDelegate.h"

@interface FriendRequestCell : UITableViewCell{
    UIView *actionView;
    
    CGPoint totalTranslation;
    CGPoint lastTranslation;
}

+ (CGFloat)getHeight;

@property (weak, nonatomic) id<FriendRequestCellDelegate> delegate;
@property (weak, nonatomic) FLFriendRequest *friendRequest;

@end
