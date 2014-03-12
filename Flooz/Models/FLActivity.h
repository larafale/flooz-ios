//
//  FLActivity.h
//  Flooz
//
//  Created by jonathan on 2/14/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLActivity : NSObject

typedef NS_ENUM(NSInteger, ActivityType) {
    ActivityTypeCommentTransaction,
    ActivityTypeCommentEvent,
    ActivityTypeLikeTransaction,
    ActivityTypeLikeEvent,
    ActivityTypeFriendRequest,
    ActivityTypeFriendRequestAccepted,
    ActivityTypeFriendJoined // Ami facebook qui s inscrit sur Flooz
};

@property FLUser *user;
@property ActivityType type;
@property NSString *content;

@property NSString *eventId;
@property NSString *transactionId;

- (id)initWithJSON:(NSDictionary *)json;

@end
