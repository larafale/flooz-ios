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
#import <UICKeyChainStore.h>

#import <Analytics/Analytics.h>

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

        _notificationsCount = @0;
        _notifications = @[];
        _activitiesCached = @[];
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

- (void)clearLogin
{
    _currentUser = nil;
    access_token = nil;
    _facebook_token = nil;
    _activitiesCached = @[];
    
    [UICKeyChainStore removeItemForKey:@"login-token"];
}

- (void)logout
{
    [self clearLogin];
    
    [self closeSocket];
    [appDelegate didDisconnected];
}

- (void)signup:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    id successBlock = ^(id result) {
        [self updateCurrentUserAfterConnect:result];
        
        [[SEGAnalytics sharedAnalytics] track:@"signup" properties:@{
                                                                  @"userId": [[[Flooz sharedInstance] currentUser] userId]
                                                                  }];
        
        if(success){
            success(result);
        }
    };
    
    [self requestPath:@"signup" method:@"POST" params:user success:successBlock failure:failure];
}

- (void)login:(NSDictionary *)user
{
    if(!user || ![user objectForKey:@"login"] || [[user objectForKey:@"login"] isBlank]){
        user = @{
                 @"login": @"louis.grellet@gmail.com",
                 @"password": @"bobb"
                 };
    }
    
    id successBlock = ^(id result) {
        [self updateCurrentUserAfterConnect:result];
    };
    
    [self requestPath:@"/login/basic" method:@"POST" params:user success:successBlock failure:NULL];
}

- (void)loginWithPhone:(NSString *)phone
{
    // Remove useless characters
    NSString *formatedPhone = [[[[phone stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]
                                stringByReplacingOccurrencesOfString:@"." withString:@""]
                               stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    // Replace +33 with 0
    if([formatedPhone hasPrefix:@"+33"]){
        formatedPhone = [formatedPhone stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@"0"];
    }
    
    [self requestPath:@"/login/quick" method:@"GET" params:@{ @"q": formatedPhone } success:^(id result) {
        [self updateCurrentUserAfterConnect:result];
    } failure:NULL];
}

- (void)loginForSecureCode:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [self requestPath:@"/login/basic" method:@"POST" params:user success:success failure:failure];
}

- (void)passwordLost:(NSString *)email success:(void (^)(id result))success
{
    [self requestPath:@"password/lost" method:@"POST" params:@{@"q": email} success:success failure:NULL];
}

- (void)updateCurrentUser
{
    [self updateCurrentUserWithSuccess:nil];
}

- (void)updateCurrentUserWithSuccess:(void (^)())success
{
    [self updateCurrentUserWithSuccess:success failure:nil];
}

- (void)updateCurrentUserWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure
{
    id successBlock = ^(id result) {
        _currentUser = [[FLUser alloc] initWithJSON:[result objectForKey:@"item"]];
        _facebook_token = result[@"item"][@"fb"][@"token"];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"reloadCurrentUser" object:nil]];
        
        if(success){
            success();
        }
    };
    
    [self requestPath:@"profile" method:@"GET" params:nil success:successBlock failure:failure];
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
    id failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error){
        if(failure){
            failure(error);
        }
    };
    
    [self requestPath:@"/profile/upload" method:@"POST" params:@{@"field": field} success:success failure:failureBlock constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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
            _activitiesCached = activities;
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

- (NSArray *)activitiesCached
{
    return _activitiesCached;
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

- (void)createTransactionValidate:(NSDictionary *)transaction success:(void (^)(id result))success noCreditCard:(void (^)())noCreditCard;
{
    NSMutableDictionary *tempTransaction = [transaction mutableCopy];
    [tempTransaction removeObjectForKey:@"image"];
    [tempTransaction removeObjectForKey:@"toImage"];
    tempTransaction[@"validate"] = @"true";
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error){
        if(operation && operation.responseObject && [[[operation.responseObject objectForKey:@"item"] objectForKey:@"code"] intValue] == 107){
            noCreditCard();
        }
    };
        
    [self requestPath:@"flooz?validate=true" method:@"POST" params:tempTransaction success:success fullFailure:failure];
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

- (void)updateTransactionValidate:(NSDictionary *)transaction success:(void (^)(id result))success noCreditCard:(void (^)())noCreditCard;
{
    id successBlock = ^(id result) {
        [self updateCurrentUser];
        
        if(success){
            success(result);
        }
    };
    
    NSMutableDictionary *tempTransaction = [transaction mutableCopy];
    tempTransaction[@"validate"] = @"true";
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error){
        if(operation && operation.responseObject && [[[operation.responseObject objectForKey:@"item"] objectForKey:@"code"] intValue] == 107){
            noCreditCard();
        }
    };
 
    NSString *path = [NSString stringWithFormat:@"flooz/%@?validate=true", [transaction objectForKey:@"id"]];
    [self requestPath:path method:@"POST" params:tempTransaction success:successBlock fullFailure:failure];
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

- (void)cashoutValidate:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
        [self requestPath:@"cashout?validate=true" method:@"POST" params:@{ @"validate": @"true" } success:success failure:failure];
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

- (void)eventParticipateValidate:(NSDictionary *)dictionary success:(void (^)(id result))success noCreditCard:(void (^)())noCreditCard;
{
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error){
        if(operation && operation.responseObject && [[[operation.responseObject objectForKey:@"item"] objectForKey:@"code"] intValue] == 107){
            noCreditCard();
        }
    };

    NSString *path = [NSString stringWithFormat:@"pots/%@/participate?validate=true", [dictionary objectForKey:@"id"]];
    [self requestPath:path method:@"POST" params:dictionary success:success fullFailure:failure];
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


- (void)sendSMSValidation
{
    [self requestPath:@"verify/phone" method:@"POST" params:nil success:nil failure:nil];
}

- (void)sendEmailValidation
{
    [self requestPath:@"verify/email" method:@"POST" params:nil success:nil failure:nil];
}

#pragma mark -

-(void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    id failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error){
        if(failure){
            failure(error);
        }
    };
    [self requestPath:path method:method params:params success:success failure:failureBlock constructingBodyWithBlock:NULL];
}

-(void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success fullFailure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))fullFailure
{
    [self requestPath:path method:method params:params success:success failure:fullFailure constructingBodyWithBlock:NULL];
}

// WARNING si passe constructingBodyWithBlock, alors les donnees ne sont pas en JSON
-(void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))constructingBodyWithBlock
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
    
    if([path rangeOfString:@"?"].location == NSNotFound){
        path = [path stringByAppendingString:@"?via=ios"];
    }
    else{
        path = [path stringByAppendingString:@"&via=ios"];
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
        
        id statusCode = [operation.responseObject objectForKey:@"statusCode"];
        
        if([path isEqualToString:@"/login/facebook"]){
            
        }
        else if(error.code == kCFURLErrorTimedOut ||
           error.code == kCFURLErrorCannotConnectToHost ||
           error.code == kCFURLErrorNotConnectedToInternet ||
           error.code == kCFURLErrorNetworkConnectionLost
           ){
//            DISPLAY_ERROR(FLNetworkError);
        }
        else if([statusCode intValue] == 306){ // Code arbitraire
            [self clearLogin];
            if([operation.responseObject[@"item"] isEqualToString:@"login"]){
                NSMutableDictionary *user = [NSMutableDictionary new];
                
                if(operation.responseObject[@"nick"]){
                    user[@"login"] = operation.responseObject[@"nick"];
                }
                
                [appDelegate showLoginWithUser:user];
            }
            else{ // Signup
                NSMutableDictionary *user = [NSMutableDictionary new];
                
                if(operation.responseObject[@"invitationCode"]){
                    user[@"invitationCode"] = operation.responseObject[@"invitationCode"];
                }
                if(operation.responseObject[@"phone"]){
                    user[@"phone"] = operation.responseObject[@"phone"];
                }
                
                [appDelegate showSignupWithUser:user];
            }
        }
        else if(([statusCode intValue] == 401 || error.code == kCFURLErrorUserCancelledAuthentication) && access_token && ![path isEqualToString:@"/login/basic"]){
            
            // [path isEqualToString:@"/login/basic"] utilisé pour le code oublié
            
            // Token expire
//            DISPLAY_ERROR(FLBadLoginError);
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
            failure(operation, error);
        }
    };
    
    if([method isEqualToString:@"GET"]){
        [manager GET:path parameters:params success:successBlock failure:failureBlock];
    }
    else if([method isEqualToString:@"POST"] && constructingBodyWithBlock != NULL){
        [manager POST:path parameters:params constructingBodyWithBlock:constructingBodyWithBlock success:successBlock failure:failureBlock];
    }
    else if([method isEqualToString:@"POST"]){
        [manager POST:path parameters:params success:successBlock failure:failureBlock];
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
    [UICKeyChainStore setString:access_token forKey:@"login-token"];
    
    _currentUser = [[FLUser alloc] initWithJSON:[[result objectForKey:@"items"] objectAtIndex:1]];
    _facebook_token = result[@"items"][1][@"fb"][@"token"];
        
    [appDelegate didConnected];
    
    [self startSocket];
    [self checkDeviceToken];
}

- (BOOL)autologin
{
    NSString *token = [UICKeyChainStore stringForKey:@"login-token"];
    
    if(!token || [token isBlank]){
        return NO;
    }
 
    access_token = token;
    [self updateCurrentUserWithSuccess:^{
        [appDelegate didConnected];
        [self startSocket];
        [self checkDeviceToken];
    } failure:^(NSError *error) {
        [self logout];
    }];
    
    return YES;
}


#pragma mark - Facebook

- (void)connectFacebook
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile,email,user_friends,publish_actions"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         [appDelegate facebookSessionStateChanged:session state:state error:error];
     }];
}

- (void)disconnectFacebook
{
    _facebook_token = nil;
    [self updateUser:@{@"fb": @{}} success:nil failure:nil];
}

- (void)didConnectFacebook
{
    NSLog(@"didConnectFacebook");
    
    _facebook_token = [[[FBSession activeSession] accessTokenData] accessToken];
    
    if(_currentUser){
        
        [FBRequestConnection startWithGraphPath:@"/me?fields=id,email,first_name,last_name,name,devices" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            [self hideLoadView];
            
            if (!error) {
                NSDictionary *user = @{
                                       @"fb": @{
                                                 @"devices": [result objectForKey:@"devices"],
                                                 @"email": [result objectForKey:@"email"],
                                                 @"id": [result objectForKey:@"id"],
                                                 @"name": [result objectForKey:@"name"],
                                                 @"token": _facebook_token
                                                 }
                                       };
                
                [self updateUser:user success:nil failure:nil];
            } else {
                NSLog(@"didConnectFacebook error");
                // An error occurred, we need to handle the error
                // See: https://developers.facebook.com/docs/ios/errors
            }
        }];
    }
    else{
        [self requestPath:@"/login/facebook" method:@"POST" params:@{@"token": _facebook_token} success:^(id result) {
            [self updateCurrentUserAfterConnect:result];
        } failure:^(NSError *error) {
            
            [FBRequestConnection startWithGraphPath:@"/me?fields=id,email,first_name,last_name,name,devices" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
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
                                                     @"token": _facebook_token
                                                     } mutableCopy]
                                           };
                    
                    [appDelegate showSignupWithUser:user];
                } else {
                    NSLog(@"didConnectFacebook error: %@", error);
                    // An error occurred, we need to handle the error
                    // See: https://developers.facebook.com/docs/ios/errors
                }
            }];
        }];
    }
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
    FLAlertViewStyle alertStyle;
    NSString *title;
    NSString *content;
    NSNumber *time;
    NSNumber *delay;
    
    if([responseObject respondsToSelector:@selector(objectForKey:)]){
        NSDictionary *error = [responseObject objectForKey:@"popup"];
        
        if(!error){
            error = [responseObject objectForKey:@"item"];
        }
        
        if(error && [error respondsToSelector:@selector(objectForKey:)] && [error objectForKey:@"visible"] && [[error objectForKey:@"visible"] boolValue] && [[error objectForKey:@"text"] respondsToSelector:@selector(length)]){

            title = [error objectForKey:@"title"];
            content = [error objectForKey:@"text"];
            time = [error objectForKey:@"time"];
            delay = [error objectForKey:@"delay"];
            
            content = [content stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            
            NSString *alertStyleText = [error objectForKey:@"type"];
            if([alertStyleText isEqualToString:@"green"]){
                alertStyle = FLAlertViewStyleSuccess;
            }
            else if([alertStyleText isEqualToString:@"red"]){
                alertStyle = FLAlertViewStyleError;
            }
            else{
                alertStyle = FLAlertViewStyleInfo;
            }
            
            if([error[@"resource"][@"type"] respondsToSelector:@selector(objectAtIndex:)]){
                for(NSString *key in error[@"resource"][@"type"]){
                    if([key isEqualToString:@"line"]){
                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"reloadTimeline" object:nil]];
                    }
                    else if([key isEqualToString:@"event"]){
                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"reloadEvents" object:nil]];
                    }
                    else if([key isEqualToString:@"profile"]){
                        [self updateCurrentUser];
                    }
                }
            }
        }
        
    }
    
    if(content && ![content isBlank]){
        [appDelegate displayMessage:title content:content style:alertStyle time:time delay:delay];
    }
}

- (void)checkDeviceToken
{
    if(!_currentUser || !appDelegate.currentDeviceToken || [[_currentUser deviceToken] isEqualToString:appDelegate.currentDeviceToken]){
        return;
    }
    
    [self updateUser:@{ @"settings": @{@"device": appDelegate.currentDeviceToken }} success:^(id result) {
        _currentUser.deviceToken = appDelegate.currentDeviceToken;
    } failure:nil];
}

#pragma mark - WebSocket

- (void)startSocket
{
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
    if(_socket && access_token && _currentUser){
        [socket sendEvent:@"subscribe" withData:@{ @"room": [_currentUser username], @"token": access_token }];
        [_socket sendEvent:@"session start" withData:@{ @"token": access_token, @"nick": [_currentUser username] }];
    }
}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    [self startSocket];
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(packet.name && [packet.name respondsToSelector:@selector(isEqualToString:)]){
            if([packet.name isEqualToString:@"popup"]){
                [self displayPopupMessage:packet.dataAsJSON[@"args"][0]];
            }
            else if([packet.name isEqualToString:@"feed"]){
                NSNumber *count = packet.dataAsJSON[@"args"][0][@"total"];
                
                [UIApplication sharedApplication].applicationIconBadgeNumber = [count intValue];
                [self setNotificationsCount:count];
                
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"newNotifications" object:nil]];
            }
            else{
                NSLog(@"-------------------");
                NSLog(@"Socket unknown event: %@", packet.name);
                NSLog(@"-------------------");
            }
        }
    });
}

- (void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"WebSocket error: %@", error);
}

- (void)socketSendSignupFocusUsername
{
    [_socket sendEvent:@"focus nick" withData:nil];
}

- (void)socketSendCloseActivities
{
    [_socket sendEvent:@"feed close" withData:@{ @"token": access_token }];
}

- (void)socketSendSessionEnd
{
    if(_socket && access_token){
        [_socket sendEvent:@"session end" withData:@{ @"token": access_token, @"nick": [_currentUser username] }];
    }
}

@end
