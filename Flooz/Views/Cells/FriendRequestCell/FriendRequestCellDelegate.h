//
//  FriendRequestCellDelegate.h
//  Flooz
//
//  Created by jonathan on 2/25/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FriendRequestCellDelegate <NSObject>

- (void)didReloadData;
- (void)acceptFriendSuggestion:(NSString *)friendSuggestionId;
- (void)removeFriend:(NSString *)friendId;
- (void)showMenuForFriendRequest:(FLFriendRequest *)friendR;

@end
