//
//  Flooz.h
//  Flooz
//
//  Created by jonathan on 12/30/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPRequestOperationManager.h>

#import "FLUser.h"
#import "FLEvent.h"
#import "FLTransaction.h"
#import "FLComment.h"
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

- (void)updateUser:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)updatePassword:(NSDictionary *)password success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)timeline:(NSString *)scope success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)timeline:(NSString *)scope state:(NSString *)state success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)activitiesWithSuccess:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)eventsWithSuccess:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)createTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)updateTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)createComment:(NSDictionary *)comment success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)cashout:(NSNumber *)amount success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)connectFacebook;
- (void)didConnectFacebook;

@end
