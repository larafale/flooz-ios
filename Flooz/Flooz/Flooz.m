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

#pragma mark -

- (void)signup:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    id successBlock = ^(id result) {
        _currentUser = [[FLUser alloc] initWithJSON:[[result objectForKey:@"items"] objectAtIndex:1]];
        access_token = [[[result objectForKey:@"items"] objectAtIndex:0] objectForKey:@"token"];
        [appDelegate didConnected];
        
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
        _currentUser = [[FLUser alloc] initWithJSON:[[result objectForKey:@"items"] objectAtIndex:1]];
        access_token = [[[result objectForKey:@"items"] objectAtIndex:0] objectForKey:@"token"];
        [appDelegate didConnected];
        
        if(success){
            success(result);
        }
    };
    
    [self requestPath:@"login/basic" method:@"POST" params:user success:successBlock failure:failure];
}

- (void)timeline:(NSString *)scope success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    id successBlock = ^(id result) {
        NSMutableArray *transactions = [NSMutableArray new];
        NSArray *transactionsJSON = [result objectForKey:@"items"];
        
        for(NSDictionary *json in transactionsJSON){
            FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:json];
            [transactions addObject:transaction];
        }
        
        if(success){
            success(transactions);
        }
    };
    
    [self requestPath:@"flooz" method:@"GET" params:@{@"scope": scope} success:successBlock failure:failure];
}

#pragma mark -

-(void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [loadView show];
    
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
        
        if(failure){
            failure(error);
        }
    };
    
    if([method isEqualToString:@"GET"]){
        [manager GET:path parameters:params success:successBlock failure:failureBlock];
    }
    else if([method isEqualToString:@"POST"]){
        [manager POST:path parameters:params success:successBlock failure:failureBlock];
    }else{
        NSLog(@"no method");
    }
}

@end
