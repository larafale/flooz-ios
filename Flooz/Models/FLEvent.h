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

@property NSString *eventId;
@property NSNumber *amount;
@property NSNumber *amountCollected;
@property NSNumber *amountExpected;
@property NSNumber *dayLeft;
@property NSNumber *pourcentage;

@property NSString *avatarURL;

@property NSString *title;
@property NSString *content;
@property NSString *attachmentURL;
@property NSString *attachmentThumbURL;

@property BOOL isPrivate;
@property BOOL isNew;
@property TransactionScope scope;

@property BOOL isInvited;

@property BOOL canParticipate; // 1, participer
@property BOOL canInvite; // 2, inviter
@property BOOL canGiveOrTakeOffer; // 3, 4, offrir ou prendre une cagnotte
@property BOOL canCancelOffer; // 5, annuler l offre
@property BOOL canAcceptOrDeclineOffer; // 6, 7, accepter ou refuser l offre
@property BOOL canDeclineInvite; // 8, refuser une invitation

@property NSDate *date;

@property FLUser *creator;
@property NSArray *participants;

@property FLSocial *social;

@property NSArray *comments;

- (NSString *)statusText;

- (id)initWithJSON:(NSDictionary *)json;
- (void)setJSON:(NSDictionary *)json;

+ (NSString *)eventScopeToText:(TransactionScope)scope;
+ (UIImage *)eventScopeToImage:(TransactionScope)scope;
+ (NSString *)eventActionToParams:(EventAction)action;

@end
