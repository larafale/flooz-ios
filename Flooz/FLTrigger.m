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
    self.key = json[@"key"];
    
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

    if ([json[@"triggers"] isKindOfClass:[NSArray class]]) {
        NSArray *triggersData = json[@"triggers"];
        
        if (triggersData && [triggersData count]) {
            self.triggers = [FLTriggerManager convertDataInList:triggersData];
        }
    } else if ([json[@"triggers"] isKindOfClass:[NSDictionary class]]) {
        FLTrigger *trigger = [[FLTrigger alloc] initWithJson:json[@"triggers"]];
        
        if (trigger) {
            self.triggers = @[trigger];
        }
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
    }
    
    if (self.action == FLTriggerActionNone)
        return NO;
    
    return YES;
};

@end
