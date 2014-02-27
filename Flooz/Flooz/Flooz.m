//
//  Flooz.m
//  Flooz
//
//  Created by jonathan on 12/30/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "Flooz.h"

#import <AFURLRequestSerialization.h>
#import <AFURLResponseSerialization.h>
#import <AFHTTPRequestOperation.h>

#import "AppDelegate.h"

@implementation Flooz

+ (Flooz *)sharedInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id)init
{
    self = [super init];
    if(self){
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.flooz.me"]];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        loadView = [FLLoadView new];
    }
    return self;
}

- (void)showLoadView
{
    [loadView show];
}

- (void)hideLoadView
{
    [loadView hide];
}

#pragma mark -

- (void)logout
{
    _currentUser = nil;
    access_token = nil;
    
    [appDelegate didDisconnected];
}

- (void)signup:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    id successBlock = ^(id result) {
        [self updateCurrentUserAfterConnect:result];
        
        if(success){
            success(result);
        }
    };
    
    [self requestPath:@"signup" method:@"POST" params:user success:successBlock failure:failure];
}

- (void)login:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    user = @{
             @"login": @"louis.grellet@gmail.com",
             @"password": @"bob"
             };
    
    id successBlock = ^(id result) {
        [self updateCurrentUserAfterConnect:result];
        
        if(success){
            success(result);
        }
    };
    
    [self requestPath:@"login/basic" method:@"POST" params:user success:successBlock failure:failure];
}

- (void)updateCurrentUser
{
    [self updateCurrentUserWithSuccess:nil];
}

- (void)updateCurrentUserWithSuccess:(void (^)())success
{
    id successBlock = ^(id result) {
        _currentUser = [[FLUser alloc] initWithJSON:[result objectForKey:@"item"]];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"reloadCurrentUser" object:nil]];
        
        if(success){
            success();
        }
    };
    
    [self requestPath:@"profile" method:@"GET" params:nil success:successBlock failure:NULL];
}

- (void)updateUser:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [self requestPath:@"profile" method:@"PUT" params:user success:^(id result) {
        _currentUser = [[FLUser alloc] initWithJSON:[result objectForKey:@"item"]];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"reloadCurrentUser" object:nil]];
        
        if(success){
            success(result);
        }
    } failure:failure];
}

- (void)updatePassword:(NSDictionary *)password success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [self requestPath:@"password/change" method:@"POST" params:password success:success failure:failure];
}

- (void)timeline:(NSString *)scope success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [self timeline:scope state:nil success:success failure:failure];
}

- (void)timeline:(NSString *)scope state:(NSString *)state success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    id successBlock = ^(id result) {
        NSMutableArray *transactions = [NSMutableArray new];
        NSArray *transactionsJSON = [result objectForKey:@"items"];
        
        for(NSDictionary *json in transactionsJSON){
            FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:json];
            [transactions addObject:transaction];
        }
        
        [_currentUser updateStatsPending:result];
        
        if(success){
            success(transactions);
        }
    };
    
    NSDictionary *params = nil;
    if(state){
        params = @{@"scope": scope, @"state": state};
    }
    else{
        params = @{@"scope": scope};
    }
    
    [self requestPath:@"flooz" method:@"GET" params:params success:successBlock failure:failure];
}

- (void)activitiesWithSuccess:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    id successBlock = ^(id result) {
        NSMutableArray *activities = [NSMutableArray new];
        NSArray *activitiesJSON = [result objectForKey:@"items"];
                
        for(NSDictionary *json in activitiesJSON){
            FLActivity *activity = [[FLActivity alloc] initWithJSON:json];
            [activities addObject:activity];
        }

        if(success){
            success(activities);
        }
    };
    
    [self requestPath:@"feed" method:@"GET" params:nil success:successBlock failure:failure];
}

- (void)events:(NSString *)scope success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    id successBlock = ^(id result) {
        NSMutableArray *events = [NSMutableArray new];
        NSArray *eventsJSON = [result objectForKey:@"items"];
        
        for(NSDictionary *json in eventsJSON){
            FLEvent *event = [[FLEvent alloc] initWithJSON:json];
            [events addObject:event];
        }
        
        if(success){
            success(events);
        }
    };
    
    [self requestPath:@"cagnottes" method:@"GET" params:@{ @"scope": scope } success:successBlock failure:failure];
}

- (void)createTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    if([transaction objectForKey:@"image"]){
        NSData *image = [transaction objectForKey:@"image"];
        [transaction setValue:nil forKey:@"image"];
        
        [self requestPath:@"flooz" method:@"POST" params:transaction success:success failure:failure constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFormData:image name:@"image"];
        }];
    }
    else{
        [self requestPath:@"flooz" method:@"POST" params:transaction success:success failure:failure];
    }
}

- (void)updateTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    id successBlock = ^(id result) {
        [self updateCurrentUser];
        
        if(success){
            success(result);
        }
    };
    
    NSString *path = [@"flooz/" stringByAppendingString:[transaction objectForKey:@"id"]];
    [self requestPath:path method:@"POST" params:transaction success:successBlock failure:failure];
}

- (void)createEvent:(NSDictionary *)event success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{    
    if([event objectForKey:@"image"]){
        NSData *image = [event objectForKey:@"image"];
        [event setValue:nil forKey:@"image"];
        
        [self requestPath:@"cagnottes" method:@"POST" params:event success:success failure:failure constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFormData:image name:@"image"];
        }];
    }
    else{
        [self requestPath:@"cagnottes" method:@"POST" params:event success:success failure:failure];
    }
}

- (void)createComment:(NSDictionary *)comment success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [self requestPath:@"comments" method:@"POST" params:comment success:success failure:failure];
}

- (void)cashout:(NSNumber *)amount success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{    
    [self requestPath:@"cashout" method:@"POST" params:@{ @"amount": amount } success:success failure:failure];
}

- (void)updateNotification:(NSDictionary *)notification success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [self requestPath:@"alerts" method:@"PUT" params:notification success:success failure:failure];
}

- (void)createCreditCard:(NSDictionary *)creditCard success:(void (^)(id result))success
{
    id successBlock = ^(id result) {
        if(success){
            [_currentUser setCreditCard:[[FLCreditCard alloc] initWithJSON:[result objectForKey:@"item"]]];
            success(result);
        }
    };
    
    [self requestPath:@"cards" method:@"POST" params:creditCard success:successBlock failure:nil];
}

- (void)removeCreditCard:(NSString *)creditCardId success:(void (^)(id result))success
{
    NSString *path = [@"cards/" stringByAppendingString:creditCardId];
    [self requestPath:path method:@"DELETE" params:nil success:success failure:nil];
}

- (void)updateFriendRequest:(NSDictionary *)dictionary success:(void (^)())success
{
    NSString *path = [@"friends/" stringByAppendingFormat:@"%@/%@", [dictionary objectForKey:@"id"], [dictionary objectForKey:@"action"]];
    [self requestPath:path method:@"GET" params:nil success:success failure:nil];
}

- (void)createLikeOnTransaction:(FLTransaction *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [self requestPath:@"likes" method:@"POST" params:@{ @"lineId": [transaction transactionId] } success:success failure:failure];
}

- (void)createLikeOnEvent:(FLEvent *)event success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [self requestPath:@"likes" method:@"POST" params:@{ @"eventId": [event eventId] } success:success failure:failure];
}

- (void)eventWithId:(NSString *)eventId success:(void (^)(id result))success
{
    NSString *path = [NSString stringWithFormat:@"cagnottes/%@", eventId];
    [self requestPath:path method:@"GET" params:nil success:success failure:NULL];
}

- (void)eventParticipate:(NSDictionary *)dictionary success:(void (^)(id result))success
{
    NSString *path = [NSString stringWithFormat:@"cagnottes/%@/participate", [dictionary objectForKey:@"id"]];
    [self requestPath:path method:@"POST" params:dictionary success:success failure:NULL];
}

- (void)eventDecline:(FLEvent *)event success:(void (^)(id result))success
{
    NSString *path = [NSString stringWithFormat:@"cagnottes/%@/decline", [event eventId]];
    [self requestPath:path method:@"POST" params:nil success:success failure:NULL];
}

- (void)eventInvite:(FLEvent *)event friend:(NSString *)friend success:(void (^)(id result))success
{
    NSString *path = [NSString stringWithFormat:@"cagnottes/%@/invite", [event eventId]];
    [self requestPath:path method:@"POST" params:@{ @"q": friend } success:success failure:NULL];
}

#pragma mark -

-(void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [self requestPath:path method:method params:params success:success failure:failure constructingBodyWithBlock:NULL];
}

-(void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))constructingBodyWithBlock
{
//    NSLog(@"request: %@", path);
    
    if(access_token){
        path = [path stringByAppendingFormat:@"?token=%@", access_token];
    }

    id successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        [loadView hide];
        
        if(success){
            success(responseObject);
        }
    };
    
    id failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseString);
        [loadView hide];
                
        if(error.code == kCFURLErrorTimedOut ||
           error.code == kCFURLErrorCannotConnectToHost ||
           error.code == kCFURLErrorNotConnectedToInternet ||
           error.code == kCFURLErrorNetworkConnectionLost
           ){
            DISPLAY_ERROR(FLNetworkError);
        }
        else if(error.code == kCFURLErrorUserCancelledAuthentication){
            // Token expire
            DISPLAY_ERROR(FLBadLoginError);
            [self logout];
        }
        else if(operation.responseObject){
            id message = [operation.responseObject objectForKey:@"item"];
            if([message respondsToSelector:@selector(length)]){ // Test si string
                DISPLAY_ERROR_MESSAGE(message);
            }
        }
        
        if(failure){
            failure(error);
        }
    };
    
    if([method isEqualToString:@"GET"]){
        [manager GET:path parameters:params success:successBlock failure:failureBlock];
    }
    else if([method isEqualToString:@"POST"]){
        [manager POST:path parameters:params constructingBodyWithBlock:constructingBodyWithBlock success:successBlock failure:failureBlock];
    }
    else if([method isEqualToString:@"PUT"]){
        [manager PUT:path parameters:params success:successBlock failure:failureBlock];
    }
    else if([method isEqualToString:@"DELETE"]){
        [manager DELETE:path parameters:params success:successBlock failure:failureBlock];
    }
    else{
        NSLog(@"Flooz request no valid method");
        [loadView hide];
    }
}

#pragma mark -

- (void)updateCurrentUserAfterConnect:(id)result
{
    _currentUser = [[FLUser alloc] initWithJSON:[[result objectForKey:@"items"] objectAtIndex:1]];
    access_token = [[[result objectForKey:@"items"] objectAtIndex:0] objectForKey:@"token"];
    [appDelegate didConnected];
}

#pragma mark - Facebook

- (void)connectFacebook
{ 
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info,email"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         [appDelegate sessionStateChanged:session state:state error:error];
     }];
}

- (void)didConnectFacebook
{
    NSString *accessToken = [[[FBSession activeSession] accessTokenData] accessToken];
    
    [self requestPath:@"/login/facebook" method:@"POST" params:@{@"token": accessToken} success:^(id result) {
        [self updateCurrentUserAfterConnect:result];
    } failure:^(NSError *error) {
    
        [FBRequestConnection startWithGraphPath:@"/me?field=email,first_name,last_name" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSDictionary *user = @{
                                       @"email": [result objectForKey:@"email"],
                                       @"lastName": [result objectForKey:@"last_name"],
                                       @"firstName": [result objectForKey:@"first_name"],
                                       @"avatarURL": [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=360&height=360", [result objectForKey:@"id"]],
                                       @"token": accessToken
                                       };
                [appDelegate loadSignupWithUser:user];
            } else {
                NSLog(@"didConnectFacebook error");
                // An error occurred, we need to handle the error
                // See: https://developers.facebook.com/docs/ios/errors
            }
        }];
    }];
}

@end
