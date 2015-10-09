//
//  FLUser.h
//  Flooz
//
//  Created by olivier on 1/20/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLCreditCard.h"

typedef struct s_FLUserPublicStats {
    NSInteger nbFlooz;
    NSInteger nbFriends;
    NSInteger nbFollowers;
    NSInteger nbFollowings;
} FLUserPublicStats;

typedef enum e_FLUserSelectedCanal {
    RecentCanal,
    SuggestionCanal,
    FriendsCanal,
    ContactCanal,
    SearchCanal,
    TimelineCanal
} FLUserSelectedCanal;

typedef enum e_FLUserKind {
    FloozUser,
    PhoneUser,
    CactusUser
} FLUserKind;

@interface FLUser : NSObject

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSString *firstname;
@property (strong, nonatomic) NSString *lastname;
@property (strong, nonatomic) NSString *fullname;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *bio;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *birthdate;
@property (strong, nonatomic) NSString *avatarURL;
@property (strong, nonatomic) NSString *avatarLargeURL;
@property (strong, nonatomic) NSString *coverURL;
@property (strong, nonatomic) NSString *coverLargeURL;
@property (strong, nonatomic) NSData *avatarData;
@property (strong, nonatomic) NSString *profileCompletion;
@property (strong, nonatomic) NSNumber *friendsCount;
@property (strong, nonatomic) NSNumber *transactionsCount;
@property (strong, nonatomic) NSString *selectedFrom;

@property (strong, nonatomic) NSString *deviceToken;

@property (strong, nonatomic) NSMutableDictionary *metrics;
@property (strong, nonatomic) NSMutableDictionary *address;
@property (strong, nonatomic) NSMutableDictionary *sepa;
@property (strong, nonatomic) NSMutableDictionary *notifications;
@property (strong, nonatomic) NSMutableDictionary *notificationsText;
@property (strong, nonatomic) NSDictionary *checkDocuments;
@property (strong, nonatomic) FLCreditCard *creditCard;
@property (strong, nonatomic) NSMutableDictionary *blockObject;

@property (strong, nonatomic) NSMutableArray *actions;

@property (strong, nonatomic) NSArray *followings;
@property (strong, nonatomic) NSArray *followers;
@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) NSArray *friendsRecent;
@property (strong, nonatomic) NSArray *friendsRequest;

@property (nonatomic)  BOOL needDocuments;

@property (nonatomic)  BOOL isFriendWaiting;
@property (nonatomic)  BOOL isStar;
@property (nonatomic)  BOOL isPro;
@property (nonatomic)  BOOL isCactus;
@property (nonatomic)  BOOL isFriend;
@property (nonatomic)  BOOL isComplete;

@property (nonatomic)  BOOL isIdentified;
@property (nonatomic)  BOOL isFloozer;

@property (nonatomic) FLUserPublicStats publicStats;

@property (nonatomic)  FLUserKind userKind;

@property (strong, nonatomic) NSString *record;
@property (strong, nonatomic) NSString *device;
@property (strong, nonatomic) NSDictionary *settings;
@property (strong, nonatomic) NSDictionary *ux;
@property (strong, nonatomic) NSString *invitCode;
@property (strong, nonatomic) NSString *hasSecureCode;
@property (strong, nonatomic) NSDictionary *json;

- (id)initWithJSON:(NSDictionary *)json;

- (NSString *)avatarURL:(CGSize)size;
- (void)setSelectedCanal:(FLUserSelectedCanal)canal;

@end
