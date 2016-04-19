//
//  FLTransaction.h
//  Flooz
//
//  Created by Olivier on 12/31/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLSocial.h"
#import "FLComment.h"

@interface FLTransaction : NSObject

	typedef NS_ENUM (NSInteger, TransactionType) {
	TransactionTypePayment,
	TransactionTypeCharge,
	TransactionTypeCollect,
    TransactionTypeBase
};

typedef NS_ENUM (NSInteger, TransactionStatus) {
	TransactionStatusAccepted,
	TransactionStatusRefused,
	TransactionStatusPending,
	TransactionStatusCanceled,
	TransactionStatusExpired,
	TransactionStatusNone
};

typedef NS_ENUM (NSInteger, TransactionScope) {
	TransactionScopePublic,
	TransactionScopeFriend,
	TransactionScopePrivate,
    TransactionScopeAll
};

typedef NS_ENUM (NSInteger, TransactionPaymentMethod) {
	TransactionPaymentMethodWallet,
	TransactionPaymentMethodCreditCard
};

@property (nonatomic) TransactionType type;
@property (nonatomic) TransactionStatus status;

@property (nonatomic, retain) NSDictionary *json;

@property (strong, nonatomic) NSString *transactionId;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSString *amountText;
@property (strong, nonatomic) NSString *avatarURL;
@property (strong, nonatomic) NSString *link;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *attachmentURL;
@property (strong, nonatomic) NSString *attachmentThumbURL;
@property (strong, nonatomic) NSString *when;
@property (strong, nonatomic) NSArray *text3d;

@property (nonatomic) BOOL isCancelable; // Si peut annuler la demande
@property (nonatomic) BOOL isAcceptable; // Si peut accepter ou refuser de payer

@property (nonatomic) BOOL isAvailable;
@property (nonatomic) BOOL isClosable;

@property (strong, nonatomic) NSDate *date;

@property (strong, nonatomic) FLUser *from;
@property (strong, nonatomic) FLUser *to;
@property (strong, nonatomic) FLUser *starter;
@property (strong, nonatomic) FLUser *creator;

@property (strong, nonatomic) FLSocial *social;

@property (strong, nonatomic) NSString *location;

@property (strong, nonatomic) NSArray *comments;
@property (strong, nonatomic) NSArray *participants;
@property (strong, nonatomic) NSArray *participations;
@property (strong, nonatomic) NSDictionary *actions;

@property (nonatomic) BOOL isCollect;
@property (nonatomic) BOOL isParticipation;

@property (nonatomic) BOOL haveAction;

- (id)initWithJSON:(NSDictionary *)json;
- (void)setJSON:(NSDictionary *)json;

- (NSString *)statusText;

+ (NSString *)transactionScopeToText:(TransactionScope)scope;
+ (UIImage *)transactionScopeToImage:(TransactionScope)scope;
+ (NSString *)transactionStatusToParams:(TransactionStatus)status;
+ (NSString *)transactionScopeToParams:(TransactionScope)scope;
+ (NSString *)transactionTypeToParams:(TransactionType)type;
+ (NSString *)transactionPaymentMethodToParams:(TransactionPaymentMethod)paymentMethod;
+ (TransactionScope)transactionParamsToScope:(NSString *)param;
+ (TransactionScope)transactionIDToScope:(NSNumber *)param;
+ (NSString *)transactionScopeToTextParams:(TransactionScope)scope;

@end
