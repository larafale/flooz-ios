//
//  FLEvent.h
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLUser.h"
#import "FLSocial.h"
#import "FLComment.h"

#import "FLTransaction.h"

@interface FLEvent : NSObject

typedef NS_ENUM(NSInteger, EventStatus) {
    EventStatusAccepted,
    EventStatusRefused,
    EventStatusPending
};

typedef NS_ENUM(NSInteger, EventAction) {
    EventActionParticipate,
    EventActionInvite,
    EventActionTakeOffer,
    EventActionGiveOffer,
    EventActionCancelOffer,
    EventActionDeclineOffer,
    EventActionAcceptOffer,
    EventActionDeclineInvite
};

@property (nonatomic) EventStatus status;

@property (strong, nonatomic) NSString *eventId;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSNumber *amountCollected;
@property (strong, nonatomic) NSNumber *amountExpected;
@property (strong, nonatomic) NSNumber *dayLeft;
@property (strong, nonatomic) NSNumber *pourcentage;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isCreator;

@property (strong, nonatomic) NSString *avatarURL;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *attachmentURL;
@property (strong, nonatomic) NSString *attachmentThumbURL;

@property (nonatomic) BOOL isPrivate;
@property (nonatomic) BOOL isNew;
@property (nonatomic) TransactionScope scope;

@property (nonatomic) BOOL isInvited;

@property (nonatomic) BOOL canParticipate; // 1, participer
@property (nonatomic) BOOL canInvite; // 2, inviter
@property (nonatomic) BOOL canGiveOrTakeOffer; // 3, 4, offrir ou prendre une cagnotte
@property (nonatomic) BOOL canCancelOffer; // 5, annuler l offre
@property (nonatomic) BOOL canAcceptOrDeclineOffer; // 6, 7, accepter ou refuser l offre
@property (nonatomic) BOOL canDeclineInvite; // 8, refuser une invitation

@property (strong, nonatomic) NSDate *date;

@property (strong, nonatomic) FLUser *creator;
@property (strong, nonatomic) NSArray *participants;

@property (strong, nonatomic) FLSocial *social;

@property (strong, nonatomic) NSArray *comments;

- (NSString *)statusText;

- (id)initWithJSON:(NSDictionary *)json;
- (void)setJSON:(NSDictionary *)json;

+ (NSString *)eventScopeToText:(TransactionScope)scope;
+ (UIImage *)eventScopeToImage:(TransactionScope)scope;
+ (NSString *)eventActionToParams:(EventAction)action;

@end
