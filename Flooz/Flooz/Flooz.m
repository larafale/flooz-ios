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
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.flooz.me"]];
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
    [self requestPath:@"profile" method:@"GET" params:nil success:^(id result) {
        _currentUser = [[FLUser alloc] initWithJSON:[result objectForKey:@"item"]];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"reloadCurrentUser" object:nil]];
    } failure:NULL];
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

- (void)eventsWithSuccess:(void (^)(id result))success failure:(void (^)(NSError *error))failure
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
    
    [self requestPath:@"cagnottes" method:@"GET" params:nil success:successBlock failure:failure];
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
    NSString *path = [@"flooz/" stringByAppendingString:[transaction objectForKey:@"id"]];
    [self requestPath:path method:@"POST" params:transaction success:success failure:failure];
}

- (void)createComment:(NSDictionary *)comment success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [self requestPath:@"comments" method:@"POST" params:comment success:success failure:failure];
}

- (void)cashout:(NSNumber *)amount success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{    
    [self requestPath:@"cashout" method:@"POST" params:@{ @"amount": amount } success:success failure:failure];
}

#pragma mark -

-(void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [self requestPath:path method:method params:params success:success failure:failure constructingBodyWithBlock:NULL];
}

-(void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))constructingBodyWithBlock
{
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
        else if(operation.responseObject){
            NSString *message = [operation.responseObject objectForKey:@"item"];
            if(message){
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
    else{
        NSLog(@"no method");
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
