//
//  FLDeal.m
//  Flooz
//
//  Created by Olive on 1/6/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLDeal.h"

@implementation FLDeal

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        if (json && json.allKeys.count > 0) {
            [self setJSON:json];
        }
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json {
    
    self.dealId = json[@"_id"];
    self.amount = json[@"amount"];
    
    if ([json[@"amount_type"] isEqualToString:@"fixed"])
        self.amountType = FLDealAmountTypeFixed;
    else
        self.amountType = FLDealAmountTypeVariable;
    
    if (json[@"emitter"])
        self.emitter = [[FLUser alloc] initWithJSON:json[@"emitter"]];
    
    self.title = json[@"title"];
    
    self.desc = json[@"description"];
    
    self.pic = json[@"pic"];
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    }
    
    self.expires = [dateFormatter dateFromString:[json objectForKey:@"expires"]];
    self.combinable = [json[@"combinable"] boolValue];
    
    if (json[@"used"]) {
        self.used = YES;
        self.flooz = [[FLTransaction alloc] initWithJSON:json[@"used"]];
    } else
        self.used = NO;
}

@end
