//
//  FLTimelineDeal.h
//  Flooz
//
//  Created by Olive on 1/20/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLSocial.h"

@interface FLTimelineDeal : NSObject

@property (nonatomic, strong) NSDictionary *json;
@property (nonatomic, strong) NSString *dealId;
@property (nonatomic, strong) FLUser *from;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *contentLarge;
@property (nonatomic, strong) NSNumber *shippingAmount;
@property (nonatomic, strong) NSString *attachmentURL;
@property (nonatomic, strong) FLSocial *social;

- (id)initWithJSON:(NSDictionary *)json;

@end
