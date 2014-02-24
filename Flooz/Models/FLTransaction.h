//
//  FLTransaction.h
//  Flooz
//
//  Created by jonathan on 12/31/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLSocial.h"
#import "FLComment.h"

@interface FLTransaction : NSObject

typedef NS_ENUM(NSInteger, TransactionType) {
    TransactionTypePayment,
    TransactionTypeCollection,
    TransactionTypeEvent
};

typedef NS_ENUM(NSInteger, TransactionStatus) {
    TransactionStatusAccepted,
    TransactionStatusRefused,
    TransactionStatusPending,
    TransactionStatusCanceled,
    TransactionStatusExpired
};

typedef NS_ENUM(NSInteger, TransactionScope) {
    TransactionScopePublic,
    TransactionScopeFriend,
    TransactionScopePrivate
};

typedef NS_ENUM(NSInteger, TransactionPaymentMethod) {
    TransactionPaymentMethodWallet,
    TransactionPaymentMethodCreditCard
};

@property TransactionType type;
@property TransactionStatus status;

@property NSString *transactionId;
@property NSNumber *amount;

@property NSString *avatarURL;

@property NSString *title;
@property NSString *content;
@property NSString *attachmentURL;
@property NSString *attachmentThumbURL;

@property BOOL isPrivate;
@property BOOL isCancelable; // Si peut annuler la demande
@property BOOL isAcceptable; // Si peut accepter ou refuser de payer

@property NSDate *date;

@property FLUser *from;
@property FLUser *to;

@property FLSocial *social;

@property NSArray *comments;

- (id)initWithJSON:(NSDictionary *)json;

- (NSString *)statusText;
- (NSString *)typeText;

+ (NSString *)transactionScopeToText:(TransactionScope)scope;
+ (NSString *)transactionStatusToParams:(TransactionStatus)status;
+ (NSString *)transactionScopeToParams:(TransactionScope)scope;
+ (NSString *)transactionTypeToParams:(TransactionType)type;
+ (NSString *)transactionPaymentMethodToParams:(TransactionPaymentMethod)paymentMethod;

@end
