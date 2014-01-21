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
    TransactionStatusPending
};

@property TransactionType type;
@property TransactionStatus status;

@property NSNumber *amount;

@property NSString *text;
@property NSString *content;
@property NSString *attachment_url;
@property NSString *attachment_thumb_url;

@property NSNumber *commentsCount;
@property NSNumber *likesCount;
@property NSNumber *isCommented;
@property NSNumber *isLiked;

- (id)initWithJSON:(NSDictionary *)json;

- (NSString *)typeText;
- (NSString *)statusText;
- (NSString *)amountFormated;

+ (NSArray *)testData;

@end
