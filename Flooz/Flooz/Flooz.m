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
        
        loadView = [JTLoadView new];
    }
    return self;
}

- (void)signup:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    user = @{
             @"email": @"jojo2@yopmail.com",
             @"phone": @"0123456783",
             @"lastName": @"jojo",
             @"firstName": @"jojo",
             @"nick": @"jojo2",
             @"password": @"jojo"
             };
    
    [self requestPath:@"signup" method:@"POST" params:user success:success failure:failure];
}

- (void)login:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{

    
    user = @{
             @"login": @"louis.grellet@gmail.com",
             @"password": @"bob"
             };
    
    [self requestPath:@"login/basic" method:@"POST" params:user success:success failure:failure];
}

-(void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure
{
    [loadView show];
    
    if(access_token){
        path = [path stringByAppendingFormat:@"?token=%@", access_token];
    }

    id successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [loadView hide];
        success(responseObject);
    };
    
    id failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseString);
        [loadView hide];
        failure(error);
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
