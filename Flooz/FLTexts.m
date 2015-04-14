//
//  FLTexts.m
//  Flooz
//
//  Created by Epitech on 2/24/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
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
    
    self.shareCode = json[@"code"];
    self.shareText = json[@"text"];
    self.shareFb = json[@"facebook"];
    self.shareMail = json[@"mail"];
    self.shareTwitter = json[@"twitter"];
    self.shareSms = json[@"sms"];
    self.shareTitle = json[@"title"];
    self.shareHeader = json[@"h1"];
    self.notificationsText = json[@"notificationsText"];
    self.slider = [[FLSlider alloc] initWithJson:json[@"slider"]];
    self.couponButton = json[@"couponButton"];
}

@end
