//
//  FLUser.m
//  Flooz
//
//  Created by jonathan on 1/20/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLUser.h"

@implementation FLUser

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
    _userId = [json objectForKey:@"_id"];
    _amount = [json objectForKey:@"balance"];
    _firstname = [json objectForKey:@"fisrtName"];
    _lastname = [json objectForKey:@"lastName"];
    _username = [json objectForKey:@"nick"];
    _email = [json objectForKey:@"email"];
    _phone = [json objectForKey:@"phone"];
    _avatarURL = [json objectForKey:@"pic"];
    _profileCompletion = [json objectForKey:@"profileCompletion"];
    
    if([_avatarURL isEqualToString:@"/img/nopic.png"]){
        _avatarURL = nil;
    }
    
    _friendsCount = [NSNumber numberWithInteger:[[json objectForKey:@"friends"] count]];
    _transactionsCount = [[[json objectForKey:@"stats"] objectForKey:@"flooz"] objectForKey:@"total"];
}

@end
