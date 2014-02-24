//
//  FLCreditCard.m
//  Flooz
//
//  Created by jonathan on 2/20/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLCreditCard.h"

@implementation FLCreditCard

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if(self){
        [self setJSON:json];
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json
{
    _cardId = [json objectForKey:@"_id"];
    _owner = [json objectForKey:@"holder"];
    _number = [json objectForKey:@"number"];
}

@end
