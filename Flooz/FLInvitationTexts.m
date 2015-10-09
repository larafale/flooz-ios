//
//  FLInvitationTexts.m
//  Flooz
//
//  Created by Flooz on 7/27/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "FLInvitationTexts.h"

@implementation FLInvitationTexts

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self setJSON:json];
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json {
    self.json = json;
    
    self.shareSubheader = json[@"h2"];
    self.shareCode = json[@"code"];
    self.shareText = json[@"text"];
    self.shareFb = json[@"facebook"];
    self.shareMail = json[@"mail"];
    self.shareTwitter = json[@"twitter"];
    self.shareSms = json[@"sms"];
    self.shareTitle = json[@"title"];
    self.shareHeader = json[@"h1"];
    self.shareMultiSms = json[@"sms-multi"];
}

@end
