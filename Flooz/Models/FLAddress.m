//
//  FLAddress.m
//  Flooz
//
//  Created by Olive on 1/22/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLAddress.h"

@implementation FLAddress

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self setJSON:json];
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json {
    self.addressId = json[@"_id"];
    self.fullName = json[@"name"];
    self.address = json[@"address"];
    self.zip = json[@"zip"];
    self.city = json[@"city"];
    self.country = [[FLCountry alloc] initWithJSON:json[@"country"]];
    self.hint = json[@"hint"];
}

@end
