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
    if (![self fillTriggerActionFromData:json])
        return NO;
    
    self.key = json[@"key"];
    
    self.delay = json[@"delay"];
    if (!self.delay)
        self.delay = @0;
    
    self.data = json[@"data"];
    
    NSArray *triggersData = json[@"triggers"];
    
    if (triggersData && [triggersData count]) {
        self.triggers = [FLTriggerManager convertDataInList:triggersData];
    } else
        self.triggers = [NSArray new];
    
    return YES;
}

- (BOOL)fillTriggerActionFromData:(NSDictionary *)data {
    NSString *actionData = data[@"action"];
    
    self.action = FLTriggerActionNone;
    
    if (actionData) {
        if ([actionData isEqualToString:@"ask"])
            self.action = FLTriggerActionAsk;
        else if ([actionData isEqualToString:@"check"])
            self.action = FLTriggerActionCheck;
        else if ([actionData isEqualToString:@"clear"])
            self.action = FLTriggerActionClear;
        else if ([actionData isEqualToString:@"hide"])
            self.action = FLTriggerActionHide;
        else if ([actionData isEqualToString:@"in"])
            self.action = FLTriggerActionIn;
        else if ([actionData isEqualToString:@"load"])
            self.action = FLTriggerActionLoad;
        else if ([actionData isEqualToString:@"out"])
            self.action = FLTriggerActionOut;
        else if ([actionData isEqualToString:@"send"])
            self.action = FLTriggerActionSend;
        else if ([actionData isEqualToString:@"set"])
            self.action = FLTriggerActionSet;
        else if ([actionData isEqualToString:@"show"])
            self.action = FLTriggerActionShow;
    }
    
    if (self.action == FLTriggerActionNone)
        return NO;
    
    return YES;
};

@end
