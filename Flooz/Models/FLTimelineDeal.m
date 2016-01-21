//
//  FLTimelineDeal.m
//  Flooz
//
//  Created by Olive on 1/20/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLTimelineDeal.h"

@implementation FLTimelineDeal

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self setJSON:json];
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json {
    _json = json;
    _dealId = [json objectForKey:@"_id"];
    _amount = [json objectForKey:@"amount"];
    _title = [json objectForKey:@"title"];
    _content = [json objectForKey:@"why"];
    _contentLarge = [json objectForKey:@"whyLarge"];
    _shippingAmount = [json objectForKey:@"shipping"];
    _attachmentURL = [json objectForKey:@"pic"];
    _social = [[FLSocial alloc] initWithJSON:json];
    _from = [[FLUser alloc] initWithJSON:[json objectForKey:@"from"]];
}

@end
