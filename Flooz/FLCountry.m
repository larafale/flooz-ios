//
//  FLCountry.m
//  Flooz
//
//  Created by Epitech on 9/8/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import "FLCountry.h"

@implementation FLCountry

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self setJSON:json];
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json {
    self.name = json[@"name"];
    self.code = json[@"code"];
    self.phoneCode = json[@"phoneCode"];
    self.imageName = [NSString stringWithFormat:@"CountryPicker.bundle/%@", self.code];
}

+ (FLCountry *) defaultCountry {
    return [[FLCountry alloc] initWithJSON:@{@"name":@"France", @"code":@"FR", @"phoneCode":@"+33"}];
}

+ (FLCountry *) countryFromCode:(NSString *)code {
    if ([Flooz sharedInstance].currentTexts) {
        for (FLCountry *country in [Flooz sharedInstance].currentTexts.avalaibleCountries) {
            if ([code isEqualToString:country.code])
                return country;
        }
    } else if ([code isEqualToString:[self.class defaultCountry].code]) {
        return [self.class defaultCountry];
    }
    
    return nil;
}

@end
