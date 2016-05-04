//
//  FLTrigger.m
//  Flooz
//
//  Created by Olivier on 10/21/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLTrigger.h"
#import "FLTriggerManager.h"

@interface FLTrigger ()

@end

@implementation FLTrigger

+(id)newWithJson:(NSDictionary *)json {
    return [[FLTrigger alloc] initWithJson:json];
}

-(id)initWithJson:(NSDictionary*)json {
    self = [super init];
    if (self) {
        if (![self setJson:json])
            return nil;
    }
    return self;
}

-(BOOL)setJson:(NSDictionary*)json {
    if (json[@"key"])
        self.key = json[@"key"];
    else
        return NO;
    
    if ([self.key isEqualToString:@"card:card:show"] && [Flooz sharedInstance].currentTexts.cashinButtons && [Flooz sharedInstance].currentTexts.cashinButtons.count)
        self.key = @"cashin:card:show";
    
    if ([self.key isEqualToString:@"card:card:hide"] && [Flooz sharedInstance].currentTexts.cashinButtons && [Flooz sharedInstance].currentTexts.cashinButtons.count)
        self.key = @"cashin:card:hide";
    
    NSArray *splitKey = [self.key componentsSeparatedByString:@":"];
    
    if (splitKey == nil || splitKey.count != 3)
        return NO;
    
    self.category = splitKey[0];
    self.view = splitKey[1];
    self.viewCaregory = [NSString stringWithFormat:@"%@:%@", splitKey[0], splitKey[1]];
    
    if (![self fillTriggerActionFromData:splitKey[2]])
        return NO;
    
    self.delay = json[@"delay"];
    if (!self.delay)
        self.delay = @0;
    
    self.data = json[@"data"];
    
    self.triggers = @[];

    if (json[@"triggers"]) {
        self.triggers = [FLTriggerManager convertDataInList:json[@"triggers"]];
    }
    
    return YES;
}

- (BOOL)fillTriggerActionFromData:(NSString *)actionData {
    
    self.action = FLTriggerActionNone;
    
    if (actionData) {
        if ([actionData isEqualToString:@"ask"])
            self.action = FLTriggerActionAsk;
        else if ([actionData isEqualToString:@"call"])
            self.action = FLTriggerActionCall;
        else if ([actionData isEqualToString:@"clear"])
            self.action = FLTriggerActionClear;
        else if ([actionData isEqualToString:@"hide"])
            self.action = FLTriggerActionHide;
        else if ([actionData isEqualToString:@"login"])
            self.action = FLTriggerActionLogin;
        else if ([actionData isEqualToString:@"logout"])
            self.action = FLTriggerActionLogout;
        else if ([actionData isEqualToString:@"open"])
            self.action = FLTriggerActionOpen;
        else if ([actionData isEqualToString:@"show"])
            self.action = FLTriggerActionShow;
        else if ([actionData isEqualToString:@"sync"])
            self.action = FLTriggerActionSync;
        else if ([actionData isEqualToString:@"send"])
            self.action = FLTriggerActionSend;
    }
    
    if (self.action == FLTriggerActionNone)
        return NO;
    
    return YES;
};

@end
