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

@interface FLEvent : NSObject

typedef NS_ENUM(NSInteger, EventStatus) {
    EventStatusAccepted,
    EventStatusRefused,
    EventStatusPending
};

@property (nonatomic) EventStatus status;

@property NSString *eventId;
@property NSNumber *amount;
@property NSNumber *amountCollect;

@property NSString *avatarURL;

@property NSString *title;
@property NSString *content;
@property NSString *attachmentURL;
@property NSString *attachmentThumbURL;

@property BOOL isPrivate;

@property BOOL isAcceptable; // Si peut y participer
@property BOOL isRefusable; // Si peut decliner invitation
@property BOOL isCollectable; // Si peut recolter ou donner la cagnotte

@property NSDate *date;

@property FLUser *creator;
@property NSArray *participants;

@property FLSocial *social;

@property NSArray *comments;

- (NSString *)statusText;

- (id)initWithJSON:(NSDictionary *)json;

@end
