//
//  FLTransaction.h
//  Flooz
//
//  Created by Olivier on 12/31/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

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


typedef NS_ENUM (NSInteger, TransactionPaymentMethod) {
    TransactionPaymentMethodWallet,
    TransactionPaymentMethodCreditCard
};

typedef NS_ENUM (NSInteger, TransactionAttachmentType) {
    TransactionAttachmentVideo,
    TransactionAttachmentImage,
    TransactionAttachmentAudio,
    TransactionAttachmentNone
};


#import "FLSocial.h"
#import "FLComment.h"

@interface FLTransactionOptions: NSObject

@property (nonatomic) BOOL likeEnabled;
@property (nonatomic) BOOL commentEnabled;
@property (nonatomic) BOOL shareEnabled;

- (id)initWithJSON:(NSDictionary *)json;

+ (id)default;
+ (id)newWithJSON:(NSDictionary *)json;
+ (id)defaultWithJSON:(NSDictionary *)json;

@end

@interface FLTransaction : NSObject

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

@property (nonatomic) TransactionAttachmentType attachmentType;
@property (strong, nonatomic) NSString *attachmentURL;
@property (strong, nonatomic) NSString *attachmentThumbURL;
@property (strong, nonatomic) NSString *when;
@property (strong, nonatomic) NSArray *text3d;

@property (nonatomic) BOOL isCancelable; // Si peut annuler la demande
@property (nonatomic) BOOL isAcceptable; // Si peut accepter ou refuser de payer

@property (nonatomic) BOOL isAvailable;
@property (nonatomic) BOOL isClosable;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isPublishable;
@property (nonatomic) BOOL isShareable;

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
@property (strong, nonatomic) NSArray *triggerOptions;
@property (strong, nonatomic) NSArray *invitations;
@property (strong, nonatomic) NSArray *triggerImage;

@property (strong, nonatomic) FLTransactionOptions *options;

@property (nonatomic) BOOL isCollect;
@property (nonatomic) BOOL isParticipation;

@property (nonatomic) BOOL haveAction;

- (id)initWithJSON:(NSDictionary *)json;
- (void)setJSON:(NSDictionary *)json;

- (NSString *)statusText;

+ (NSString *)transactionStatusToParams:(TransactionStatus)status;
+ (NSString *)transactionTypeToParams:(TransactionType)type;
+ (NSString *)transactionPaymentMethodToParams:(TransactionPaymentMethod)paymentMethod;

@end
