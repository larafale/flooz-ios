//
//  FLFriendRequest.m
//  Flooz
//
//  Created by jonathan on 2/23/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLFriendRequest.h"

@implementation FLFriendRequest

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if(self){
        [self setJSON:json];
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json
{
    _user = [[FLUser alloc] initWithJSON:json];
    _requestId = json[@"id"];
}

@end
