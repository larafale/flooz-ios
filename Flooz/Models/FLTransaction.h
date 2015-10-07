//
//  FLTransaction.h
//  Flooz
//
//  Created by olivier on 12/31/2013.
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
@property (strong, nonatomic) NSString *amountTextFull;
@property (strong, nonatomic) NSString *avatarURL;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *attachmentURL;
@property (strong, nonatomic) NSString *attachmentThumbURL;
@property (strong, nonatomic) NSString *when;
@property (strong, nonatomic) NSArray *text3d;

@property (nonatomic) BOOL isCancelable; // Si peut annuler la demande
@property (nonatomic) BOOL isAcceptable; // Si peut accepter ou refuser de payer

@property (strong, nonatomic) NSDate *date;

@property (strong, nonatomic) FLUser *from;
@property (strong, nonatomic) FLUser *to;
@property (strong, nonatomic) FLUser *starter;

@property (strong, nonatomic) FLSocial *social;

@property (strong, nonatomic) NSArray *comments;

@property (nonatomic) BOOL isCollect;
@property (nonatomic) BOOL collectCanParticipate;
@property (strong, nonatomic) NSArray *collectUsers;
@property (strong, nonatomic) NSString *collectTitle;

@property (nonatomic) BOOL haveAction;

- (id)initWithJSON:(NSDictionary *)json;

- (NSString *)statusText;

+ (NSString *)transactionScopeToText:(TransactionScope)scope;
+ (UIImage *)transactionScopeToImage:(TransactionScope)scope;
+ (NSString *)transactionStatusToParams:(TransactionStatus)status;
+ (NSString *)transactionScopeToParams:(TransactionScope)scope;
+ (NSString *)transactionTypeToParams:(TransactionType)type;
+ (NSString *)transactionPaymentMethodToParams:(TransactionPaymentMethod)paymentMethod;
+ (TransactionScope)transactionParamsToScope:(NSString *)param;
+ (NSString *)transactionScopeToTextParams:(TransactionScope)scope;

@end
