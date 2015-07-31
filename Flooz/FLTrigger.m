//
//  FLTrigger.m
//  Flooz
//
//  Created by Olivier on 10/21/14.
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
    else if ([param isEqualToString:@"logout"])
        return TriggerLogout;
    else if ([param isEqualToString:@"app:update"])
        return TriggerAppUpdate;
    else if ([param isEqualToString:@"informations:show"])
        return TriggerShowContactInfo;
    else if ([param isEqualToString:@"documents:show"])
        return TriggerShowUserDocuments;
    else if ([param isEqualToString:@"3dSecure:show"])
        return TriggerShow3DSecure;
    else if ([param isEqualToString:@"3dSecure:complete"])
        return TriggerComplete3DSecure;
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
    else if ([param isEqualToString:@"invitation:show"])
        return TriggerShowInvitation;
    else if ([param isEqualToString:@"http:call"])
        return TriggerHttpCall;
    else if ([param isEqualToString:@"popup:show"])
        return TriggerShowPopup;
    else if ([param isEqualToString:@"home:show"])
        return TriggerShowHome;
    else if ([param isEqualToString:@"iban:show"])
        return TriggerShowIban;
    else if ([param isEqualToString:@"tuto:reset"])
        return TriggerResetTuto;
    else if ([param isEqualToString:@"view:close"])
        return TriggerCloseView;
    else if ([param isEqualToString:@"contacts:send"])
        return TriggerSendContacts;
    else
        return TriggerNone;
}

@end
