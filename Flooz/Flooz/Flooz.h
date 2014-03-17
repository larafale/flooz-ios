//
//  Flooz.h
//  Flooz
//
//  Created by jonathan on 12/30/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPRequestOperationManager.h>

#import "FLFriendRequest.h"
#import "FLUser.h"
#import "FLEvent.h"
#import "FLTransaction.h"
#import "FLComment.h"
#import "FLCreditCard.h"
#import "FLActivity.h"

@interface Flooz : NSObject{
    AFHTTPRequestOperationManager *manager;
    NSString *access_token;
    FLLoadView *loadView;
}

@property (strong, readonly) FLUser *currentUser;

+ (Flooz *)sharedInstance;

- (void)showLoadView;
- (void)hideLoadView;

- (void)logout;

- (void)signup:(NSDictionary *)user success:(void (^)(id result))block failure:(void (^)(NSError *error))failure;
- (void)login:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)updateCurrentUser;
- (void)updateCurrentUserWithSuccess:(void (^)())success;

- (void)updateUser:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)updatePassword:(NSDictionary *)password success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)uploadDocument:(NSData *)data field:(NSString *)field success:(void (^)())success failure:(void (^)(NSError *error))failure;

- (void)timeline:(NSString *)scope success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure;
- (void)timeline:(NSString *)scope state:(NSString *)state success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure;
- (void)timelineNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl))success;
- (void)transactionWithId:(NSString *)transactionId success:(void (^)(id result))success;

- (void)activitiesWithSuccess:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)events:(NSString *)scope success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure;
- (void)eventsNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl))success;

- (void)createTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)updateTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)createEvent:(NSDictionary *)event success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)createComment:(NSDictionary *)comment success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)cashout:(NSNumber *)amount success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

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
- (void)eventParticipate:(NSDictionary *)dictionary success:(void (^)(id result))success;
- (void)eventInvite:(FLEvent *)event friend:(NSDictionary *)friend success:(void (^)(id result))success;
- (void)eventOffer:(FLEvent *)event friend:(NSDictionary *)friend success:(void (^)(id result))success;

- (void)connectFacebook;
- (void)didConnectFacebook;
- (void)facebokSearchFriends:(void (^)(id result))success;

@end
