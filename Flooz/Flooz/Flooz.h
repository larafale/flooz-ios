//
//  Flooz.h
//  Flooz
//
//  Created by jonathan on 12/30/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPRequestOperationManager.h>

#import <SocketIO.h>
#import <SocketIOPacket.h>

#import "FLFriendRequest.h"
#import "FLUser.h"
#import "FLEvent.h"
#import "FLTransaction.h"
#import "FLComment.h"
#import "FLCreditCard.h"
#import "FLActivity.h"

static NSString *kNotificationConnectionError = @"kNotificationConnectionError";
static NSString *kNotificationRemoveWindowSubviews = @"kNotificationRemoveWindowSubviews";
static NSString *kNotificationCloseKeyboard = @"kNotificationCloseKeyboard";
static NSString *kNotificationReloadCurrentUser = @"kNotificationReloadCurrentUser";

@interface Flooz : NSObject<SocketIODelegate>{
    AFHTTPRequestOperationManager *manager;
    NSString *access_token;
    FLLoadView *loadView;
    
    SocketIO *_socket;
    
    NSArray *_activitiesCached;
}

@property (strong, readonly) FLUser *currentUser;
@property (strong, nonatomic) NSString *facebook_token;

@property (strong, nonatomic) NSNumber *notificationsCount;
@property (strong, nonatomic) NSArray *notifications;

+ (Flooz *)sharedInstance;

- (void)showLoadView;
- (void)hideLoadView;

- (BOOL)autologin;
- (void)logout;

- (void)signup:(NSDictionary *)user success:(void (^)(id result))block failure:(void (^)(NSError *error))failure;
- (void)login:(NSDictionary *)user;
- (void)loginWithPhone:(NSString *)phone;
- (void)loginForSecureCode:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)passwordLost:(NSString *)email success:(void (^)(id result))success;

- (void)updateCurrentUser;
- (void)updateCurrentUserWithSuccess:(void (^)())success;

- (void)updateUser:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)updatePassword:(NSDictionary *)password success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)uploadDocument:(NSData *)data field:(NSString *)field success:(void (^)())success failure:(void (^)(NSError *error))failure;

- (void)timeline:(NSString *)scope success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure;
- (void)timeline:(NSString *)scope state:(NSString *)state success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure;
- (void)timelineNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl))success;
- (void)transactionWithId:(NSString *)transactionId success:(void (^)(id result))success;

- (void)activitiesWithSuccess:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure;
- (void)activitiesNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl))success;
- (NSArray *)activitiesCached;

- (void)events:(NSString *)scope success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure;
- (void)eventsNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl))success;

- (void)createTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)createTransactionValidate:(NSDictionary *)transaction success:(void (^)(id result))success noCreditCard:(void (^)())noCreditCard;

- (void)updateTransactionValidate:(NSDictionary *)transaction success:(void (^)(id result))success noCreditCard:(void (^)())noCreditCard;
- (void)updateTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)createEvent:(NSDictionary *)event success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)createCollect:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)participateCollect:(NSString *)transactionId amount:(NSString *)amount success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)createComment:(NSDictionary *)comment success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)cashout:(NSNumber *)amount success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)cashoutValidate:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)updateNotification:(NSDictionary *)notification success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)createCreditCard:(NSDictionary *)creditCard success:(void (^)(id result))success;
- (void)removeCreditCard:(NSString *)creditCardId success:(void (^)(id result))success;

- (void)updateFriendRequest:(NSDictionary *)dictionary success:(void (^)())success;
- (void)friendsSuggestion:(void (^)(id result))success;
- (void)friendRemove:(NSString *)friendRelationId success:(void (^)())success;
- (void)friendAcceptSuggestion:(NSString *)friendId success:(void (^)())success;
- (void)friendSearch:(NSString *)text success:(void (^)(id result))success;

- (void)createLikeOnTransaction:(FLTransaction *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)createLikeOnEvent:(FLEvent *)event success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)eventWithId:(NSString *)eventId success:(void (^)(id result))success;
- (void)eventAction:(FLEvent *)event action:(EventAction)action success:(void (^)(id result))success;
- (void)eventParticipateValidate:(NSDictionary *)dictionary success:(void (^)(id result))success noCreditCard:(void (^)())noCreditCard;
- (void)eventParticipate:(NSDictionary *)dictionary success:(void (^)(id result))success;
- (void)eventInvite:(FLEvent *)event friend:(NSDictionary *)friend success:(void (^)(id result))success;
- (void)eventOffer:(FLEvent *)event friend:(NSDictionary *)friend success:(void (^)(id result))success;

- (void)sendSMSValidation;
- (void)sendEmailValidation;

- (void)connectFacebook;
- (void)disconnectFacebook;
- (void)didConnectFacebook;
- (void)facebokSearchFriends:(void (^)(id result))success;

- (void)startSocket;
- (void)socketSendSignupFocusUsername;
- (void)socketSendCloseActivities;
- (void)socketSendSessionEnd;

- (void)verifyInvitationCode:(NSString *)invitationCode success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)verifyPseudo:(NSString *)pseudo success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)verifyEmail:(NSString *)email success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)sendContacts;
- (void)sendContactsWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)createContactList:(void (^)(NSMutableArray *arrayContacts, NSMutableArray *arrayServer))lists;

- (NSMutableArray *)createFriendsArrayFromResult:(NSDictionary *)result;
- (NSMutableArray *)createEventArrayFromResult:(NSDictionary *)result;
- (NSMutableArray *)createActivityArrayFromResult:(NSDictionary *)result;
- (NSMutableArray *)createTransactionArrayFromResult:(NSDictionary *)result;

@end
