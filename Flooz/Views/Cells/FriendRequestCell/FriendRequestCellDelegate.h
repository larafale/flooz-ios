//
//  FriendRequestCellDelegate.h
//  Flooz
//
//  Created by olivier on 2/25/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FriendRequestCellDelegate <NSObject>

- (void)didReloadData;
- (void)acceptFriendSuggestion:(FLUser *)user cell:(UITableViewCell*)cell;
- (void)removeFriend:(FLUser *)user;

@end
