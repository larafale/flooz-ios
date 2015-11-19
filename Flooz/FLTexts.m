//
//  FLTexts.m
//  Flooz
//
//  Created by Olivier on 2/24/15.
//  Copyright (c) 2015 olivier Tribouharet. All rights reserved.
//

#import "FLTexts.h"
#import "FLCountry.h"

@implementation FLTexts

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self setJSON:json];
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json {
    self.json = json;
    
    self.notificationsText = json[@"notificationsText"];
    self.slider = [[FLSlider alloc] initWithJson:json[@"slider"]];
    self.couponButton = json[@"couponButton"];
    self.card = json[@"card"];
    self.menu = json[@"menu"];
    if (json[@"signup"]) {
        self.signupSponsor = json[@"signup"][@"promo"];
    }
    
    self.avalaibleCountries = [NSMutableArray new];
    
    NSArray *countries = json[@"countries"];
    
    for (NSDictionary *country in countries) {
        [self.avalaibleCountries addObject:[[FLCountry alloc] initWithJSON:country]];
    }
    
    if (!self.avalaibleCountries.count)
        [self.avalaibleCountries addObject:[FLCountry defaultCountry]];
}

@end
