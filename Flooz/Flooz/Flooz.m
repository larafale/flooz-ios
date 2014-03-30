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

#import <Accounts/Accounts.h>

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
    _facebook_token = nil;
    
    [self closeSocket];
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
    if(!user || ![user objectForKey:@"login"] || [[user objectForKey:@"login"] isBlank]){
        user = @{
                 @"login": @"louis.grellet@gmail.com",
                 @"password": @"bob"
                 };
    }
    
    id successBlock = ^(id result) {
        [self updateCurrentUserAfterConnect:result];
        
        if(success){
            success(result);
        }
    };
    
    [self requestPath:@"/login/basic" method:@"POST" params:user success:successBlock failure:failure];
}

- (void)loginForSecureCode:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [self requestPath:@"/login/basic" method:@"POST" params:user success:success failure:failure];
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

- (void)uploadDocument:(NSData *)data field:(NSString *)field success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    [self requestPath:@"/profile/upload" method:@"POST" params:@{@"field": field} success:success failure:failure constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSLog(@"image size: %.2fMB", data.length / 1024. / 1024.);
        [formData appendPartWithFileData:data name:field fileName:@"image.jpg" mimeType:@"image/jpg"];
    }];
}

- (void)timeline:(NSString *)scope success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure
{
    [self timeline:scope state:nil success:success failure:failure];
}

- (void)timeline:(NSString *)scope state:(NSString *)state success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure
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
            success(transactions, [result objectForKey:@"next"]);
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

- (void)timelineNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl))success
{
    id successBlock = ^(id result) {
        NSMutableArray *transactions = [NSMutableArray new];
        NSArray *transactionsJSON = [result objectForKey:@"items"];
        
        for(NSDictionary *json in transactionsJSON){
            FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:json];
            [transactions addObject:transaction];
        }
        
        if(success){
            success(transactions, [result objectForKey:@"next"]);
        }
    };
    
    [self requestPath:nextPageUrl method:@"GET" params:nil success:successBlock failure:NULL];
}

- (void)transactionWithId:(NSString *)transactionId success:(void (^)(id result))success
{
    NSString *path = [NSString stringWithFormat:@"flooz/%@", transactionId];
    [self requestPath:path method:@"GET" params:nil success:success failure:NULL];
}

- (void)activitiesWithSuccess:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure
{
    id successBlock = ^(id result) {
        NSMutableArray *activities = [NSMutableArray new];
        NSArray *activitiesJSON = [result objectForKey:@"items"];
                
        for(NSDictionary *json in activitiesJSON){
            FLActivity *activity = [[FLActivity alloc] initWithJSON:json];
            [activities addObject:activity];
        }

        if(success){
            success(activities, [result objectForKey:@"next"]);
        }
    };
    
    [self requestPath:@"feeds" method:@"GET" params:@{ @"scope": @"private" } success:successBlock failure:failure];
}

- (void)activitiesNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl))success
{
    id successBlock = ^(id result) {
        NSMutableArray *activities = [NSMutableArray new];
        NSArray *activitiesJSON = [result objectForKey:@"items"];
        
        for(NSDictionary *json in activitiesJSON){
            FLActivity *activity = [[FLActivity alloc] initWithJSON:json];
            [activities addObject:activity];
        }
        
        if(success){
            success(activities, [result objectForKey:@"next"]);
        }
    };
    
    [self requestPath:nextPageUrl method:@"GET" params:nil success:successBlock failure:NULL];
}

- (void)events:(NSString *)scope success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure
{
    id successBlock = ^(id result) {
        NSMutableArray *events = [NSMutableArray new];
        NSArray *eventsJSON = [result objectForKey:@"items"];
        
        for(NSDictionary *json in eventsJSON){
            FLEvent *event = [[FLEvent alloc] initWithJSON:json];
            [events addObject:event];
        }
        
        if(success){
            success(events, [result objectForKey:@"next"]);
        }
    };
    
    [self requestPath:@"pots" method:@"GET" params:@{ @"scope": scope } success:successBlock failure:failure];
}

- (void)eventsNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl))success
{
    id successBlock = ^(id result) {
        NSMutableArray *events = [NSMutableArray new];
        NSArray *eventsJSON = [result objectForKey:@"items"];
        
        for(NSDictionary *json in eventsJSON){
            FLEvent *event = [[FLEvent alloc] initWithJSON:json];
            [events addObject:event];
        }
        
        if(success){
            success(events, [result objectForKey:@"next"]);
        }
    };
    
    [self requestPath:nextPageUrl method:@"GET" params:nil success:successBlock failure:NULL];
}

- (void)createTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    void(^ failureBlock1)(NSError *error);
    
    failureBlock1 = ^(NSError *error) {
        if(failure){
            failure(error);
        }
    };
    
    if([transaction objectForKey:@"toImage"]){
         NSData *image = [transaction objectForKey:@"toImage"];
        [transaction setValue:nil forKey:@"toImage"];
        
        failureBlock1 = ^(NSError *error) {
            [transaction setValue:image forKey:@"toImage"];
            if(failure){
                failure(error);
            }
        };
    }
    
    if([transaction objectForKey:@"image"]){
        NSData *image = [transaction objectForKey:@"image"];
        [transaction setValue:nil forKey:@"image"];
        
        id failureBlock2 = ^(NSError *error) {
            [transaction setValue:image forKey:@"image"];
            
            failureBlock1(error);
        };
        
        [self requestPath:@"flooz" method:@"POST" params:transaction success:success failure:failureBlock2 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSLog(@"image size: %.2fMB", image.length / 1024. / 1024.);
            [formData appendPartWithFileData:image name:@"image" fileName:@"image.jpg" mimeType:@"image/jpg"];
        }];
    }
    else{
        [self requestPath:@"flooz" method:@"POST" params:transaction success:success failure:failureBlock1];
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
        
        id failureBlock = ^(NSError *error) {
            [event setValue:image forKey:@"image"];
            if(failure){
                failure(error);
            }
        };
        
        [self requestPath:@"pots" method:@"POST" params:event success:success failure:failureBlock constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSLog(@"image size: %.2fMB", image.length / 1024. / 1024.);
            [formData appendPartWithFileData:image name:@"image" fileName:@"image.jpg" mimeType:@"image/jpg"];
        }];
    }
    else{
        [self requestPath:@"pots" method:@"POST" params:event success:success failure:failure];
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

- (void)friendsSuggestion:(void (^)(id result))success
{
    id successBlock = ^(id result) {
        NSMutableArray *friends = [NSMutableArray new];
        
        if([result objectForKey:@"items"]){
            for(NSDictionary *friendJSON in [result objectForKey:@"items"]){
                FLUser *friend = [[FLUser alloc] initWithJSON:friendJSON];
                [friends addObject:friend];
            }
        }
        
        if(success){
            success(friends);
        }
    };
    
    [self requestPath:@"/friends/suggestion" method:@"GET" params:nil success:successBlock failure:NULL];
}

- (void)friendRemove:(NSString *)friendRelationId success:(void (^)())success
{
    NSString *path = [@"/friends/" stringByAppendingFormat:@"%@/delete", friendRelationId];
    [self requestPath:path method:@"GET" params:nil success:success failure:nil];
}

- (void)friendAcceptSuggestion:(NSString *)friendId success:(void (^)())success
{
    NSString *path = [@"/friends/request/" stringByAppendingString:friendId];
    [self requestPath:path method:@"GET" params:nil success:success failure:nil];
}

- (void)friendSearch:(NSString *)text success:(void (^)(id result))success
{
    id successBlock = ^(id result) {
        NSMutableArray *friends = [NSMutableArray new];
        
        if([result objectForKey:@"items"]){
            for(NSDictionary *friendJSON in [result objectForKey:@"items"]){
                FLUser *friend = [[FLUser alloc] initWithJSON:friendJSON];
                [friends addObject:friend];
            }
        }
        
        if(success){
            success(friends);
        }
    };
    
    [self requestPath:@"/friends/search" method:@"GET" params:@{@"q" : text} success:successBlock failure:nil];
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
    NSString *path = [NSString stringWithFormat:@"pots/%@", eventId];
    [self requestPath:path method:@"GET" params:nil success:success failure:NULL];
}

- (void)eventAction:(FLEvent *)event action:(EventAction)action success:(void (^)(id result))success
{
    NSString *path = [NSString stringWithFormat:@"pots/%@/%@", [event eventId], [FLEvent eventActionToParams:action]];
    [self requestPath:path method:@"POST" params:nil success:success failure:NULL];
}

- (void)eventParticipate:(NSDictionary *)dictionary success:(void (^)(id result))success
{
    NSString *path = [NSString stringWithFormat:@"pots/%@/participate", [dictionary objectForKey:@"id"]];
    [self requestPath:path method:@"POST" params:dictionary success:success failure:NULL];
}

- (void)eventInvite:(FLEvent *)event friend:(NSDictionary *)friend success:(void (^)(id result))success
{
    NSString *path = [NSString stringWithFormat:@"pots/%@/invite", [event eventId]];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[friend objectForKey:@"to"] forKey:@"q"];
    
    if([friend objectForKey:@"fb"]){
        [params setObject:[friend objectForKey:@"fb"] forKey:@"fb"];
    }
    if([friend objectForKey:@"contact"]){
        [params setObject:[friend objectForKey:@"contact"] forKey:@"contact"];
    }
    
    [self requestPath:path method:@"POST" params:params success:success failure:NULL];
}

- (void)eventOffer:(FLEvent *)event friend:(NSDictionary *)friend success:(void (^)(id result))success
{
    NSString *path = [NSString stringWithFormat:@"pots/%@/give", [event eventId]];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[friend objectForKey:@"to"] forKey:@"q"];
    
    if([friend objectForKey:@"fb"]){
        [params setObject:[friend objectForKey:@"fb"] forKey:@"fb"];
    }
    
    [self requestPath:path method:@"POST" params:params success:success failure:NULL];
}

#pragma mark -

-(void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [self requestPath:path method:method params:params success:success failure:failure constructingBodyWithBlock:NULL];
}

-(void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))constructingBodyWithBlock
{
    NSLog(@"%@ request: %@ - %@", method, path, params);
    
    if(access_token){
        if([path rangeOfString:@"?"].location == NSNotFound){
            path = [path stringByAppendingFormat:@"?token=%@", access_token];
        }
        else if([path rangeOfString:@"token="].location == NSNotFound){ // Dans le cas des next url ou le token est deja forni
            path = [path stringByAppendingFormat:@"&token=%@", access_token];
        }
    }

    id successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        [loadView hide];
        
        [self displayPopupMessage:responseObject];
        
        if(success){
            success(responseObject);
        }
    };
    
    id failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error request: %@", operation.responseString);
        [loadView hide];
        
        if([path isEqualToString:@"/login/facebook"]){
            
        }
        else if(error.code == kCFURLErrorTimedOut ||
           error.code == kCFURLErrorCannotConnectToHost ||
           error.code == kCFURLErrorNotConnectedToInternet ||
           error.code == kCFURLErrorNetworkConnectionLost
           ){
            DISPLAY_ERROR(FLNetworkError);
        }
        else if(error.code == kCFURLErrorUserCancelledAuthentication && access_token){
            // Token expire
            DISPLAY_ERROR(FLBadLoginError);
            [self logout];
        }
        else if(operation.responseObject){
            [self displayPopupMessage:operation.responseObject];
            
//            id statusCode = [operation.responseObject objectForKey:@"statusCode"];
//            if(access_token && [statusCode respondsToSelector:@selector(intValue)] && [statusCode intValue] == 401){
//                // Token expire
//                DISPLAY_ERROR(FLBadLoginError);
//                [self logout];
//            }
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
    access_token = [[[result objectForKey:@"items"] objectAtIndex:0] objectForKey:@"token"];
    _currentUser = [[FLUser alloc] initWithJSON:[[result objectForKey:@"items"] objectAtIndex:1]];
    
    [appDelegate didConnected];
    [self startSocket];
}

#pragma mark - Facebook

- (void)connectFacebook
{
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info,email,user_friends,publish_actions"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         [self hideLoadView];
         [appDelegate facebookSessionStateChanged:session state:state error:error];
     }];
}

- (void)didConnectFacebook
{
    _facebook_token = [[[FBSession activeSession] accessTokenData] accessToken];
    
    [self requestPath:@"/login/facebook" method:@"POST" params:@{@"token": _facebook_token} success:^(id result) {
        [self updateCurrentUserAfterConnect:result];
    } failure:^(NSError *error) {
        
        [FBRequestConnection startWithGraphPath:@"/me?fields=id,email,first_name,last_name,name,username,devices" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            [self hideLoadView];
            
            if (!error) {
                NSDictionary *user = @{
                                       @"email": [result objectForKey:@"email"],
                                       @"lastName": [result objectForKey:@"last_name"],
                                       @"firstName": [result objectForKey:@"first_name"],
                                       @"avatarURL": [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=360&height=360", [result objectForKey:@"id"]],
                                           @"fb": [@{
                                               @"devices": [result objectForKey:@"devices"],
                                               @"email": [result objectForKey:@"email"],
                                               @"id": [result objectForKey:@"id"],
                                               @"name": [result objectForKey:@"name"],
                                               @"username": [result objectForKey:@"username"],
                                               @"token": _facebook_token
                                           } mutableCopy]
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

- (void)facebokSearchFriends:(void (^)(id result))success
{
    [FBRequestConnection startWithGraphPath:@"/me/friends?fields=first_name,last_name,name,id,picture" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [self hideLoadView];
        
        if (!error) {
            success([result objectForKey:@"data"]);
        } else {
            NSLog(@"facebokSearchFriends: %@", [error description]);
        }
    }];
}

- (void)displayPopupMessage:(id)responseObject
{
    NSString *title;
    NSString *content;
    if([responseObject respondsToSelector:@selector(objectForKey:)]){
        NSDictionary *error = [responseObject objectForKey:@"popup"];
        
        if(!error){
            error = [responseObject objectForKey:@"item"];
        }
        
        if(error && [error respondsToSelector:@selector(objectForKey:)] && [error objectForKey:@"visible"] && [[error objectForKey:@"visible"] boolValue] && [[error objectForKey:@"text"] respondsToSelector:@selector(length)]){
            title = [error objectForKey:@"title"];
            content = [error objectForKey:@"text"];
        }
    }
    
    if(content && ![content isBlank]){
        [appDelegate displayMessage:title content:content style:FLAlertViewStyleSuccess];
    }
}

#pragma mark - WebSocket

- (void)startSocket
{
    if(!_currentUser){
        return;
    }
    
    _socket = [[SocketIO alloc] initWithDelegate:self];
    _socket.useSecure = YES;
    [_socket connectToHost:@"api.flooz.me" onPort:443];
}

- (void)closeSocket
{
    _socket = nil;
}

- (void)socketIODidConnect:(SocketIO *)socket
{
    [socket sendEvent:@"subscribe" withData:@{ @"room": [_currentUser username] }];
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    if(packet.name && [packet.name respondsToSelector:@selector(isEqualToString:)]){
        if([packet.name isEqualToString:@"popup"]){
            [self displayPopupMessage:packet.dataAsJSON[@"args"][0]];
        }
        else if([packet.name isEqualToString:@"newNotification"]){
            NSNumber *count = packet.dataAsJSON[@"args"][0][@"total"];
            
            [[[Flooz sharedInstance] currentUser] setNotificationsCount:count];
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"newNotifications" object:nil]];
        }
    }
}

- (void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"WebSocket error: %@", error);
}

@end
