//
//  FLActivity.h
//  Flooz
//
//  Created by olivier on 2/14/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLActivity : NSObject

typedef enum e_FLActivityType {
    AccountLocked,
    AccountUnlocked,
    AddAvatar,
    CardExpired,
    Cashout,
    CheckDeclined,
    CommentsLine,
    CompleteProfile,
    FriendJoined,
    FriendRequest,
    FriendRequestCancelled,
    LineExpired,
    LineExpiredReceiver,
    LikesLine,
    LineCharge,
    LineChargeDeclined,
    LinePay,
    LinePreset
} FLActivityType;

@property (nonatomic, retain) NSString *activityId;
@property (nonatomic) FLActivityType type;
@property (strong, nonatomic) FLUser *user;
@property (strong, nonatomic) NSString *content;
@property (nonatomic) BOOL isRead;

@property (strong, nonatomic) NSString *transactionId;
@property (nonatomic) BOOL isFriend;
@property (nonatomic) BOOL isForCompleteProfil;
@property (nonatomic) BOOL isForAvatarMissing;

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *when;
@property (strong, nonatomic) NSString *dateText;

@property (strong, nonatomic) NSArray *triggers;

- (id)initWithJSON:(NSDictionary *)json;
+ (FLActivityType)activityTypeParamToEnum:(NSString *)param;

@end
