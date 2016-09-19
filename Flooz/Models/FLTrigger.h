//
//  FLTrigger.h
//  Flooz
//
//  Created by Olivier on 10/21/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLTrigger : NSObject

typedef NS_ENUM(NSInteger, FLTriggerAction) {
    FLTriggerActionAsk,
    FLTriggerActionCall,
    FLTriggerActionClear,
    FLTriggerActionHide,
    FLTriggerActionLogin,
    FLTriggerActionLogout,
    FLTriggerActionOpen,
    FLTriggerActionNone,
    FLTriggerActionPicker,
    FLTriggerActionSend,
    FLTriggerActionShow,
    FLTriggerActionSync
};

@property (nonatomic) FLTriggerAction action;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *view;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *viewCategory;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSNumber *delay;
@property (nonatomic, strong) NSArray<FLTrigger *> *triggers;
@property (nonatomic, strong) NSDictionary *jsonData;

+(id)newWithJson:(NSDictionary *)json;

-(id)initWithJson:(NSDictionary*)json;

@end
