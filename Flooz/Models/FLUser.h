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

@property (strong, nonatomic)  NSString *userId;
@property (strong, nonatomic)  NSNumber *amount;
@property (strong, nonatomic)  NSString *firstname;
@property (strong, nonatomic)  NSString *lastname;
@property (strong, nonatomic)  NSString *fullname;
@property (strong, nonatomic)  NSString *username;
@property (strong, nonatomic)  NSString *email;
@property (strong, nonatomic)  NSString *phone;
@property (strong, nonatomic)  NSString *avatarURL;
@property (strong, nonatomic)  NSString *profileCompletion;
@property (strong, nonatomic)  NSNumber *friendsCount;
@property (strong, nonatomic)  NSNumber *eventsCount;
@property (strong, nonatomic)  NSNumber *transactionsCount;
@property (nonatomic)  BOOL haveStatsPending;

@property (strong, nonatomic)  NSString *deviceToken;

@property (strong, nonatomic)  NSMutableDictionary *address;
@property (strong, nonatomic)  NSMutableDictionary *sepa;
@property (strong, nonatomic)  NSMutableDictionary *notifications;
@property (strong, nonatomic)  NSMutableDictionary *notificationsText;
@property (strong, nonatomic)  NSDictionary *checkDocuments;
@property (strong, nonatomic)  FLCreditCard *creditCard;

@property (strong, nonatomic)  NSArray *friends;
@property (strong, nonatomic)  NSArray *friendsRecent;
@property (strong, nonatomic)  NSArray *friendsRequest;

@property (nonatomic)  BOOL needDocuments;

@property (nonatomic)  BOOL isFriendWaiting;

@property (strong, nonatomic)  NSString *record;
@property (strong, nonatomic)  NSString *device;
@property (strong, nonatomic)  NSDictionary *settings;
@property (strong, nonatomic)  NSString *invitCode;
@property (strong, nonatomic)  NSString *hasSecureCode;
@property (strong, nonatomic) NSDictionary *json;

- (id)initWithJSON:(NSDictionary *)json;
- (void)updateStatsPending:(NSDictionary *)json;

- (NSString *)avatarURL:(CGSize)size;

@end
