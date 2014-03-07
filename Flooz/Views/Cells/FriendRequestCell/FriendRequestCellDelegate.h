//
//  FriendRequestCellDelegate.h
//  Flooz
//
//  Created by jonathan on 2/25/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FriendRequestCellDelegate <NSObject>

- (void)didReloadData;
- (void)acceptFriendSuggestion:(NSString *)friendSuggestionId;
- (void)removeFriend:(NSString *)friendId;

@end
