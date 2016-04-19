//
//  FLTexts.m
//  Flooz
//
//  Created by Olivier on 2/24/15.
//  Copyright (c) 2015 Olivier Mouren. All rights reserved.
//

#import "FLTexts.h"
#import "FLCountry.h"

@implementation FLHomeButton

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self setJSON:json];
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json {

    self.title = json[@"title"];
    self.subtitle = json[@"subtitle"];
    self.defaultImg = json[@"defaultPic"];
    self.imgUrl = json[@"urlPic"];
    
    if (json[@"soon"])
        self.soon = [json[@"soon"] boolValue];
    else
        self.soon = NO;
        
    self.triggers = [FLTriggerManager convertDataInList:json[@"triggers"]];
}

@end

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
    
    self.audiotelNumber = json[@"audiotelNumber"] ? json[@"audiotelNumber"] : @"0660718983";
    
    
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
    
    NSMutableArray *homeMutableButtons = [NSMutableArray new];
    
    if (json[@"homeButtons"]) {
        for (id homeButton in json[@"homeButtons"]) {
            if ([homeButton isKindOfClass:[NSDictionary class]])
                [homeMutableButtons addObject:[[FLHomeButton alloc] initWithJSON:homeButton]];
        }
    }
    
    self.homeButtons = homeMutableButtons;
    
    for (NSDictionary *country in countries) {
        [self.avalaibleCountries addObject:[[FLCountry alloc] initWithJSON:country]];
    }
    
    if (!self.avalaibleCountries.count)
        [self.avalaibleCountries addObject:[FLCountry defaultCountry]];
}

@end
