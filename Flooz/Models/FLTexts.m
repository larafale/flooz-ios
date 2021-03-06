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
    self.json = json;
    self.name = json[@"name"];
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
    
    if (json[@"balance"]) {
        self.balancePopupTitle = json[@"balance"][@"title"];
        self.balancePopupText = json[@"balance"][@"text"];
    }
    
    if (json[@"audiotel"]) {
        self.audiotelNumber = json[@"audiotel"][@"number"];
        self.audiotelImage = json[@"audiotel"][@"image"];
        self.audiotelInfos = json[@"audiotel"][@"info"];
    }
    
    if (json[@"cardHolder"])
        self.cardHolder = [json[@"cardHolder"] boolValue] ? @"true" : @"false";
    
    self.friendSearch = json[@"friendSearch"];
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

    self.homeTriggers = [FLTriggerManager convertDataInList:json[@"homeTriggers"]];

    NSMutableArray *cashinMutableButtons = [NSMutableArray new];
    
    if (json[@"cashins"]) {
        for (id cashinButton in json[@"cashins"]) {
            if ([cashinButton isKindOfClass:[NSDictionary class]])
                [cashinMutableButtons addObject:[[FLHomeButton alloc] initWithJSON:cashinButton]];
        }
    }
    
    self.cashinButtons = cashinMutableButtons;
    
    NSMutableArray *sourcesMutableArray = [NSMutableArray new];
    
    if (json[@"sources"]) {
        for (id paymentSource in json[@"sources"]) {
            if ([paymentSource isKindOfClass:[NSDictionary class]])
                [sourcesMutableArray addObject:[[FLHomeButton alloc] initWithJSON:paymentSource]];
        }
    }
    
    self.floozOptions = [FLTransactionOptions defaultWithJSON:[json objectForKey:@"floozOptions"]];
    
    self.paymentSources = sourcesMutableArray;

    self.defaultScope = nil;
    if ([json objectForKey:@"defaultScope"]) {
        self.defaultScope = [FLScope scopeFromObject:[json objectForKey:@"defaultScope"]];
    }
    
    if ([json objectForKey:@"homeScopes"]) {
        NSMutableArray *fixScopes = [NSMutableArray new];
        for (id scopeData in [json objectForKey:@"homeScopes"]) {
            [fixScopes addObject:[FLScope scopeFromObject:scopeData]];
        }
        self.homeScopes = fixScopes;
    } else
        self.homeScopes = [FLScope defaultScopeList];

    for (NSDictionary *country in countries) {
        [self.avalaibleCountries addObject:[[FLCountry alloc] initWithJSON:country]];
    }
    
    if (!self.avalaibleCountries.count)
        [self.avalaibleCountries addObject:[FLCountry defaultCountry]];
    
    self.createFloozOptions = [FLNewFloozOptions defaultWithJson:[json objectForKey:@"newFloozOptions"]];
    
    self.suggestGif = json[@"suggest"][@"gifs"];
    self.suggestWeb = json[@"suggest"][@"webs"];
    
    self.mangopayOptions = [[FLMangopayOptions alloc] initWithJSON:[json objectForKey:@"mangopay"]];
}

@end
