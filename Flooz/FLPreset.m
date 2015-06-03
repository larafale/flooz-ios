//
//  FLPreset.m
//  Flooz
//
//  Created by Olivier on 11/27/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
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
    self.blockBack = NO;
    self.blockWhy = NO;
    self.focusAmount = NO;
    self.focusWhy = NO;
    
    if (json[@"to"])
        self.to = [[FLUser alloc] initWithJSON:json[@"to"]];
    
    self.type = TransactionTypeBase;
    
    self.amount = [json objectForKey:@"amount"];
    self.why = [json objectForKey:@"why"];
    self.whyPlaceholder = [json objectForKey:@"whyPlaceholder"];
    self.payload = [json objectForKey:@"payload"];
    self.image = [json objectForKey:@"image"];
    
    self.popup = [json objectForKey:@"popup"];
    self.steps = [json objectForKey:@"steps"];
    
    self.title = [json objectForKey:@"title"];
    
    if ([json objectForKey:@"block"]) {
        if ([[json objectForKey:@"block"] objectForKey:@"amount"])
            self.blockAmount = [[[json objectForKey:@"block"] objectForKey:@"amount"] boolValue];
        
        if ([[json objectForKey:@"block"] objectForKey:@"balance"])
            self.blockBalance = [[[json objectForKey:@"block"] objectForKey:@"balance"] boolValue];
        
        if ([[json objectForKey:@"block"] objectForKey:@"to"])
            self.blockTo = [[[json objectForKey:@"block"] objectForKey:@"to"] boolValue];
        
        if ([[json objectForKey:@"block"] objectForKey:@"close"])
            self.blockBack = [[[json objectForKey:@"block"] objectForKey:@"close"] boolValue];
        
        if ([[json objectForKey:@"block"] objectForKey:@"pay"])
            self.type = TransactionTypeCharge;
        
        if ([[json objectForKey:@"block"] objectForKey:@"charge"])
            self.type = TransactionTypePayment;
        
        if ([[json objectForKey:@"block"] objectForKey:@"why"])
            self.blockWhy = [[[json objectForKey:@"block"] objectForKey:@"why"] boolValue];
    }
    
    if ([json objectForKey:@"focus"]) {
        NSString *focus = [json objectForKey:@"focus"];
        if ([focus isEqualToString:@"amount"])
            self.focusAmount = YES;
        else if ([focus isEqualToString:@"why"])
            self.focusWhy = YES;
    }
}

@end
