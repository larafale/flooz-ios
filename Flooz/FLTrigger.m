//
//  FLTrigger.m
//  Flooz
//
//  Created by Epitech on 10/21/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLTrigger.h"

@implementation FLTrigger

-(id)initWithJson:(NSDictionary*)json {
    self = [super init];
    if (self) {
        [self setJson:json];
    }
    return self;
}

-(void)setJson:(NSDictionary*)json {
    self.type = [FLTrigger triggerTypeParamToEnum:json[@"type"]];
    self.delay = json[@"delay"];
    
    if (!self.delay)
        self.delay = @0;
    
    NSMutableDictionary *tmp = [json mutableCopy];
    [tmp removeObjectForKey:@"type"];
    [tmp removeObjectForKey:@"delay"];
    self.data = tmp;
}

+(FLTriggerType)triggerTypeParamToEnum:(NSString*)param {
    
    if ([param isEqualToString:@"timeline:reload"])
        return TriggerReloadTimeline;
    else if ([param isEqualToString:@"line:show"])
        return TriggerShowLine;
    else if ([param isEqualToString:@"avatar:show"])
        return TriggerShowAvatar;
    else if ([param isEqualToString:@"profile:reload"])
        return TriggerReloadProfile;
    else if ([param isEqualToString:@"card:show"])
        return TriggerShowCard;
    else if ([param isEqualToString:@"friend:show"])
        return TriggerShowFriend;
    else if ([param isEqualToString:@"friend:reload"])
        return TriggerReloadFriend;
    else if ([param isEqualToString:@"line:reload"])
        return TriggerReloadLine;
    else if ([param isEqualToString:@"profile:show"])
        return TriggerShowProfile;
    else if ([param isEqualToString:@"signup:show"])
        return TriggerShowSignup;
    else if ([param isEqualToString:@"login:show"])
        return TriggerShowLogin;
    else if ([param isEqualToString:@"signup:invitation"])
        return TriggerShowSignupCode;
    else if ([param isEqualToString:@"logout"])
        return TriggerLogout;
    else if ([param isEqualToString:@"app:update"])
        return TriggerAppUpdate;
    else if ([param isEqualToString:@"contactInfo:show"])
        return TriggerShowContactInfo;
    else if ([param isEqualToString:@"identity:show"])
        return TriggerShowUserIdentity;
    else if ([param isEqualToString:@"3dSecure:show"])
        return TriggerShow3DSecure;
    else if ([param isEqualToString:@"3dSecure:complete"])
        return TriggerComplete3DSecure;
    else if ([param isEqualToString:@"password:change"])
        return TriggerResetPassword;
    else if ([param isEqualToString:@"3dSecure:fail"])
        return TriggerFail3DSecure;
    else if ([param isEqualToString:@"secureCode:clear"])
        return TriggerSecureCodeClear;
    else if ([param isEqualToString:@"secureCode:check"])
        return TriggerSecureCodeCheck;
    else if ([param isEqualToString:@"line:preset"])
        return TriggerPresetLine;
    else if ([param isEqualToString:@"feed:read"])
        return TriggerFeedRead;
    else
        return TriggerNone;
}

@end
