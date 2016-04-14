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
    self.blockScope = NO;
    self.focusAmount = NO;
    self.focusWhy = NO;
    self.isParticipation = NO;
    
    if (json[@"isParticipation"]) {
        self.isParticipation = [json[@"isParticipation"] boolValue];
    }
    
    if (!self.isParticipation) {
        if (json[@"to"])
            self.to = [[FLUser alloc] initWithJSON:json[@"to"]];
    } else {
        self.collectName = json[@"to"];
    }
    
    self.type = TransactionTypeBase;
    
    self.presetId = [json objectForKey:@"_id"];
    self.amount = [json objectForKey:@"amount"];
    self.why = [json objectForKey:@"why"];
    self.whyPlaceholder = [json objectForKey:@"whyPlaceholder"];
    self.payload = [json objectForKey:@"payload"];
    self.image = [json objectForKey:@"image"];
    self.geo = [json objectForKey:@"geo"];
    self.name = [json objectForKey:@"name"];
    self.namePlaceholder = [json objectForKey:@"namePlaceholder"];
    self.popup = [json objectForKey:@"popup"];
    self.steps = [json objectForKey:@"steps"];

    if ([json objectForKey:@"scope"]) {
        self.scopeDefined = YES;
        self.scope = [FLTransaction transactionIDToScope:[json objectForKey:@"scope"]];
    }
    
    self.title = [json objectForKey:@"title"];
    
    self.type = TransactionTypeBase;
    
    if ([json objectForKey:@"block"]) {
        if ([[json objectForKey:@"block"] objectForKey:@"amount"])
            self.blockAmount = [[[json objectForKey:@"block"] objectForKey:@"amount"] boolValue];
        
        self.scopes = [[json objectForKey:@"block"] objectForKey:@"scopes"];
        
        if ([[json objectForKey:@"block"] objectForKey:@"balance"])
            self.blockBalance = [[[json objectForKey:@"block"] objectForKey:@"balance"] boolValue];
        
        if ([[json objectForKey:@"block"] objectForKey:@"to"])
            self.blockTo = [[[json objectForKey:@"block"] objectForKey:@"to"] boolValue];

        if ([[json objectForKey:@"block"] objectForKey:@"scope"])
            self.blockScope = [[[json objectForKey:@"block"] objectForKey:@"scope"] boolValue];

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
