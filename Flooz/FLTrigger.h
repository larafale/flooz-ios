//
//  FLTrigger.h
//  Flooz
//
//  Created by Olivier on 10/21/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLTrigger : NSObject

typedef enum e_FLTriggerType {
    TriggerNone,
    TriggerReloadTimeline,
    TriggerShowLine,
    TriggerShowAvatar,
    TriggerReloadProfile,
    TriggerShowCard,
    TriggerReloadFriend,
    TriggerShowProfile,
    TriggerShowFriend,
    TriggerReloadLine,
    TriggerShowLogin,
    TriggerShowSignup,
    TriggerShowSignupCode,
    TriggerLogout,
    TriggerAppUpdate,
    TriggerShowContactInfo,
    TriggerShowUserIdentity,
    TriggerShow3DSecure,
    TriggerComplete3DSecure,
    TriggerResetPassword,
    TriggerFail3DSecure,
    TriggerSecureCodeClear,
    TriggerSecureCodeCheck,
    TriggerPresetLine,
    TriggerFeedRead,
    TriggerShowInvitation,
    TriggerHttpCall,
    TriggerShowPopup,
    TriggerShowHome,
    TriggerShowIban,
    TriggerResetTuto,
    TriggerCloseView
} FLTriggerType;

@property (nonatomic) FLTriggerType type;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSNumber *delay;

-(id)initWithJson:(NSDictionary*)json;

+(FLTriggerType)triggerTypeParamToEnum:(NSString*)param;

@end
