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
    _userId = [json objectForKey:@"_id"]; // ou userId 
    _amount = [json objectForKey:@"balance"];
    _firstname = [json objectForKey:@"firstName"];
    _lastname = [json objectForKey:@"lastName"];
    _fullname = [json objectForKey:@"name"];
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
    
    _haveStatsPending = NO;
        
    NSNumber *statsPending = [[[json objectForKey:@"stats"] objectForKey:@"flooz"] objectForKey:@"pending"];
    if([statsPending intValue] > 0){
        _haveStatsPending = YES;
    }
    
    {
        _address = [NSMutableDictionary new];
        
        if([json objectForKey:@"settings"] && [[json objectForKey:@"settings"] objectForKey:@"address"]){
            _address = [[[json objectForKey:@"settings"] objectForKey:@"address"] mutableCopy];
        }
    }
    
    {
        _sepa = [NSMutableDictionary new];
        
        if([json objectForKey:@"settings"] && [[json objectForKey:@"settings"] objectForKey:@"sepa"]){
            _sepa = [[[json objectForKey:@"settings"] objectForKey:@"sepa"] mutableCopy];
        }
    }
}

- (void)updateStatsPending:(NSDictionary *)json
{
    NSNumber *statsPending = [[[json objectForKey:@"stats"] objectForKey:@"flooz"] objectForKey:@"pending"];
    if([statsPending intValue] > 0){
        _haveStatsPending = YES;
    }
}

- (NSString *)avatarURL:(CGSize)size
{
    if(_avatarURL){
        return [_avatarURL stringByAppendingFormat:@"?width=%d&height=%d", 2 * (int)floorf(size.width), 2 * (int)floorf(size.height)];
    }
    else{
        return nil;
    }
}

@end
