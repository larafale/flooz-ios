//
//  FLTransaction.h
//  Flooz
//
//  Created by jonathan on 12/31/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLTransaction : NSObject

typedef NS_ENUM(NSInteger, TransactionType) {
    TransactionTypePayment,
    TransactionTypeCollection
};

typedef NS_ENUM(NSInteger, TransactionStatus) {
    TransactionStatusAccepted,
    TransactionStatusRefused,
    TransactionStatusWaiting
};

@property (nonatomic) TransactionType type;
@property (nonatomic) TransactionStatus status;

@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *to;
@property (strong, nonatomic) NSNumber *amount;

@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *attachment_url;

@property (strong, nonatomic) NSNumber *commentsCount;
@property (strong, nonatomic) NSNumber *likesCount;
@property (strong, nonatomic) NSNumber *isCommented;
@property (strong, nonatomic) NSNumber *isLiked;

- (NSString *)typeText;
- (NSString *)statusText;
- (NSString *)amountText;
- (NSString *)text;

+ (NSArray *)testTransactions;

@end
