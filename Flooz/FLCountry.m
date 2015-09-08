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

@end
