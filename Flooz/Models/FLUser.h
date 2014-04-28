//
//  FLUser.h
//  Flooz
//
//  Created by jonathan on 1/20/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLCreditCard.h"

@interface FLUser : NSObject

@property NSString *userId;
@property NSNumber *amount;
@property NSString *firstname;
@property NSString *lastname;
@property NSString *fullname;
@property NSString *username;
@property NSString *email;
@property NSString *phone;
@property NSString *avatarURL;
@property NSString *profileCompletion;
@property NSNumber *friendsCount;
@property NSNumber *eventsCount;
@property NSNumber *transactionsCount;
@property BOOL haveStatsPending;

@property NSString *deviceToken;

@property NSMutableDictionary *address;
@property NSMutableDictionary *sepa;
@property NSMutableDictionary *notifications;
@property NSMutableDictionary *notificationsText;
@property NSDictionary *checkDocuments;
@property FLCreditCard *creditCard;

@property NSString *friendRelationId;
@property NSArray *friends;
@property NSArray *friendsRecent;
@property NSArray *friendsRequest;

@property BOOL needDocuments;

@property BOOL isFriendWaiting;

- (id)initWithJSON:(NSDictionary *)json;
- (void)updateStatsPending:(NSDictionary *)json;

- (NSString *)avatarURL:(CGSize)size;

@end
