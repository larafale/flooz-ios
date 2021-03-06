//
//  FLPreset.m
//  Flooz
//
//  Created by Olivier on 11/27/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLPreset.h"

@implementation FLNewFloozOptions

- (id)init {
    self = [super init];
    if (self) {
        self.allowTo = true;
        self.allowPic = true;
        self.allowGif = true;
        self.allowGeo = true;
        self.allowWhy = true;
        self.allowAmount = true;
        self.allowBalance = true;
        self.scopeDefined = false;
        self.allowPay = true;
        self.allowCharge = true;
        self.type = TransactionTypeBase;
    }
    return self;
}

- (id)initWithJson:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self setJson:json];
    }
    return self;
}

+ (id)defaultWithJson:(NSDictionary *)json {
    FLNewFloozOptions *ret = [FLNewFloozOptions default];
    if (ret && json) {
        [ret setJson:json];
    }
    return ret;
}

+ (id)default {
    if ([[Flooz sharedInstance] currentTexts] && [[[Flooz sharedInstance] currentTexts] createFloozOptions])
        return [[[[Flooz sharedInstance] currentTexts] createFloozOptions] copy];
    else
        return [FLNewFloozOptions new];
}

- (void)setJson:(NSDictionary *)json {
    self.jsonData = json;
    
    if ([json objectForKey:@"scope"]) {
        self.scopeDefined = YES;
        self.scope = [FLScope scopeFromObject:[json objectForKey:@"scope"]];
    }
    
    if ([json objectForKey:@"scopes"]) {
        NSMutableArray *fixScopes = [NSMutableArray new];
        for (id scopeData in [json objectForKey:@"scopes"]) {
            [fixScopes addObject:[FLScope scopeFromObject:scopeData]];
        }
        self.scopes = fixScopes;
    }
    
    if ([json objectForKey:@"amount"])
        self.allowAmount = [[json objectForKey:@"amount"] boolValue];
    
    if ([json objectForKey:@"balance"])
        self.allowBalance = [[json objectForKey:@"balance"] boolValue];
    
    if ([json objectForKey:@"to"])
        self.allowTo = [[json objectForKey:@"to"] boolValue];
    
    if ([json objectForKey:@"pic"])
        self.allowPic = [[json objectForKey:@"pic"] boolValue];
    
    if ([json objectForKey:@"gif"])
        self.allowGif = [[json objectForKey:@"gif"] boolValue];
    
    if ([json objectForKey:@"geo"])
        self.allowGeo = [[json objectForKey:@"geo"] boolValue];
    
    if ([json objectForKey:@"pay"])
        self.allowPay = [[json objectForKey:@"pay"] boolValue];
    
    if ([json objectForKey:@"charge"])
        self.allowCharge = [[json objectForKey:@"charge"] boolValue];
    
    if (self.allowPay && self.allowCharge)
        self.type = TransactionTypeBase;
    else if (self.allowPay || !self.allowCharge)
        self.type = TransactionTypePayment;
    else if (self.allowCharge || !self.allowPay)
        self.type = TransactionTypeCharge;
    
    if ([json objectForKey:@"why"])
        self.allowWhy = [[json objectForKey:@"why"] boolValue];
}

- (id)copy {
    FLNewFloozOptions *ret = [[FLNewFloozOptions alloc] init];
    
    ret.allowTo = self.allowTo;
    ret.allowPic = self.allowPic;
    ret.allowGif = self.allowGif;
    ret.allowGeo = self.allowGeo;
    ret.allowWhy = self.allowWhy;
    ret.allowAmount = self.allowAmount;
    ret.allowBalance = self.allowBalance;
    ret.scopeDefined = self.scopeDefined;
    ret.type = self.type;
    ret.allowCharge = self.allowCharge;
    ret.allowPay = self.allowPay;
    ret.scope = self.scope;
    ret.scopes = self.scopes;

    return ret;
}

@end

@implementation FLPreset

- (id)initWithJson:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self setJson:json];
    }
    return self;
}

- (void)setJson:(NSDictionary *)json {
    
    self.focusAmount = NO;
    self.focusWhy = NO;
    self.isParticipation = NO;
    
    if (json[@"isParticipation"]) {
        self.isParticipation = [json[@"isParticipation"] boolValue];
    }
    
    if (!self.isParticipation) {
        self.to = json[@"to"];
        self.toFullName = json[@"toFullName"];
        self.contact = json[@"contact"];
    } else {
        self.collectName = json[@"to"];
    }
        
    self.presetId = [json objectForKey:@"_id"];
    self.amount = [json objectForKey:@"amount"];
    self.why = [json objectForKey:@"why"];
    self.whyPlaceholder = [json objectForKey:@"whyPlaceholder"];
    self.payload = [json objectForKey:@"payload"];
    self.image = [json objectForKey:@"image"];
    self.geo = [json objectForKey:@"geo"];
    self.name = [json objectForKey:@"name"];
    self.namePlaceholder = [json objectForKey:@"namePlaceholder"];
    self.popup = [json objectForKey:@"popup"];
    
    self.title = [json objectForKey:@"title"];
    
    self.options = [FLNewFloozOptions defaultWithJson:json[@"options"]];
    
    if ([json objectForKey:@"focus"]) {
        NSString *focus = [json objectForKey:@"focus"];
        if ([focus isEqualToString:@"amount"])
            self.focusAmount = YES;
        else if ([focus isEqualToString:@"why"])
            self.focusWhy = YES;
    }
}

@end
