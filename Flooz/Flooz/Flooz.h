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
#import "FLTransaction.h"

@interface Flooz : NSObject{
    AFHTTPRequestOperationManager *manager;
    NSString *access_token;
    JTLoadView *loadView;
}

@property (strong, readonly) FLUser *currentUser;

+ (Flooz *)sharedInstance;

- (void)signup:(NSDictionary *)user success:(void (^)(id result))block failure:(void (^)(NSError *error))failure;
- (void)login:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)timeline:(NSString *)scope success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

@end
