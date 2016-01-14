//
//  FLCreditCard.m
//  Flooz
//
//  Created by olivier on 2/20/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLCreditCard.h"

@implementation FLCreditCard

- (id)initWithJSON:(NSDictionary *)json {
	self = [super init];
	if (self) {
		[self setJSON:json];
	}
	return self;
}

- (void)setJSON:(NSDictionary *)json {
	_cardId = [json objectForKey:@"_id"];
	_owner = [json objectForKey:@"holder"];
	_number = [json objectForKey:@"number"];
    _expires = [json objectForKey:@"expires"];
}

@end
