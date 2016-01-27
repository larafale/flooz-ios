//
//  FLTrigger.h
//  Flooz
//
//  Created by Olivier on 10/21/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLTrigger : NSObject

//typedef enum e_FLTriggerType {
//    TriggerNone,
//    TriggerReloadTimeline,
//    TriggerShowLine,
//    TriggerShowAvatar,
//    TriggerReloadProfile,
//    TriggerShowCard,
//    TriggerReloadFriend,
//    TriggerShowProfile,
//    TriggerShowFriend,
//    TriggerReloadLine,
//    TriggerShowSignup,
//    TriggerLogout,
//    TriggerAppUpdate,
//    TriggerShowContactInfo,
//    TriggerShowUserDocuments,
//    TriggerShow3DSecure,
//    TriggerComplete3DSecure,
//    TriggerFail3DSecure,
//    TriggerSecureCodeClear,
//    TriggerSecureCodeCheck,
//    TriggerPresetLine,
//    TriggerFeedRead,
//    TriggerShowInvitation,
//    TriggerHttpCall,
//    TriggerShowPopup,
//    TriggerShowHome,
//    TriggerShowIban,
//    TriggerResetTuto,
//    TriggerCloseView,
//    TriggerSendContacts,
//    TriggerUserShow,
//    TriggerInvitationSMSShow,
//    TriggerSMSValidate,
//    TriggerSecureCodeValidate,
//    TriggerEditProfile,
//    TriggerAskNotification,
//    TriggerFbConnect,
//    TriggerPayClick,
//    TriggerShowNotification,
//    TriggerReloadNotification,
//    TriggerReloadShareTexts
//} FLTriggerType;

typedef NS_ENUM(NSInteger, FLTriggerAction) {
    FLTriggerActionAsk,
    FLTriggerActionCheck,
    FLTriggerActionClear,
    FLTriggerActionHide,
    FLTriggerActionIn,
    FLTriggerActionLoad,
    FLTriggerActionNone,
    FLTriggerActionOut,
    FLTriggerActionSend,
    FLTriggerActionSet,
    FLTriggerActionShow
};

@property (nonatomic) FLTriggerAction action;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSNumber *delay;
@property (nonatomic, strong) NSArray<FLTrigger *> *triggers;

+(id)newWithJson:(NSDictionary *)json;

-(id)initWithJson:(NSDictionary*)json;

@end
