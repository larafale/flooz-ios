//
//  FLTransaction.h
//  Flooz
//
//  Created by jonathan on 12/31/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLSocial.h"

@interface FLTransaction : NSObject

typedef NS_ENUM(NSInteger, TransactionType) {
    TransactionTypePayment,
    TransactionTypeCollection
};

typedef NS_ENUM(NSInteger, TransactionStatus) {
    TransactionStatusAccepted,
    TransactionStatusRefused,
    TransactionStatusPending,
    TransactionStatusCanceled,
    TransactionStatusExpired
};

@property TransactionType type;
@property TransactionStatus status;

@property NSNumber *amount;

@property NSString *avatarURL;

@property NSString *text;
@property NSString *why;
@property NSString *attachmentURL;
@property NSString *attachmentThumbURL;

@property FLSocial* social;

- (id)initWithJSON:(NSDictionary *)json;

- (NSString *)typeText;
- (NSString *)statusText;

+ (NSArray *)testData;

@end
