//
//  FLPreset.m
//  Flooz
//
//  Created by Epitech on 11/27/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLPreset.h"

@implementation FLPreset

- (id)initWithJson:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self setJson:json];
    }
    return self;
}

- (void)setJson:(NSDictionary *)json {
    
    self.blockAmount = NO;
    self.blockTo = NO;
    
    self.to = [[FLUser alloc] initWithJSON:json[@"to"]];
    
    NSString *method = [json objectForKey:@"method"];
    
    if ([method isEqualToString:@"pay"])
        self.type = TransactionTypePayment;
    else if ([method isEqualToString:@"charge"])
        self.type = TransactionTypeCharge;
    else
        self.type = TransactionTypeBase;
    
    self.amount = [json objectForKey:@"amount"];
    self.why = [json objectForKey:@"why"];
    self.payload = [json objectForKey:@"payload"];
    
    if ([json objectForKey:@"block"]) {
        if ([[json objectForKey:@"block"] objectForKey:@"amount"])
            self.blockAmount = [[json objectForKey:@"block"] objectForKey:@"amount"];

        if ([[json objectForKey:@"block"] objectForKey:@"to"])
            self.blockTo = [[json objectForKey:@"block"] objectForKey:@"to"];
    }
}

@end
