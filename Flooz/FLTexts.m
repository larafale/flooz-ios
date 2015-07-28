//
//  FLTexts.m
//  Flooz
//
//  Created by Olivier on 2/24/15.
//  Copyright (c) 2015 olivier Tribouharet. All rights reserved.
//

#import "FLTexts.h"

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
    self.secretQuestions = json[@"secretQuestions"];
    self.card = json[@"card"];
}

@end
