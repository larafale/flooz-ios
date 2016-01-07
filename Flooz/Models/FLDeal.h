//
//  FLDeal.h
//  Flooz
//
//  Created by Olive on 1/6/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FLDealAmountType) {
    FLDealAmountTypeFixed,
    FLDealAmountTypeVariable
};

@interface FLDeal : NSObject

@property (strong, nonatomic) NSString *dealId;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) FLUser *emitter;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *pic;
@property (strong, nonatomic) NSDate *expires;
@property (nonatomic) BOOL combinable;
@property (nonatomic) BOOL used;
@property (nonatomic) FLTransaction *flooz;
@property (nonatomic) FLDealAmountType amountType;

- (id)initWithJSON:(NSDictionary *)json;


@end
