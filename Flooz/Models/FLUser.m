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
    if([json objectForKey:@"_id"]){
        _userId = [json objectForKey:@"_id"];
    }
    
    _amount = [json objectForKey:@"balance"];
    if(!_amount){
        // Argent mis dans une cagnotte
        _amount = [json objectForKey:@"amount"];
    }
    
    _firstname = [json objectForKey:@"firstName"];
    _lastname = [json objectForKey:@"lastName"];
    _fullname = [json objectForKey:@"name"];
    _username = [json objectForKey:@"nick"];
    _email = [json objectForKey:@"email"];
    _phone = [json objectForKey:@"phone"];
    _avatarURL = [json objectForKey:@"pic"];
    _profileCompletion = [json objectForKey:@"profileCompletion"];
    _hasSecureCode = [json objectForKey:@"secureCode"];
    
    if([_avatarURL isEqualToString:@"/img/nopic.png"]){
        _avatarURL = nil;
    }
    
    if(json[@"settings"]){
        _deviceToken = json[@"settings"][@"device"];
    }
    
    _friendsCount = [NSNumber numberWithInteger:[[json objectForKey:@"friends"] count]];
    _eventsCount = [[[json objectForKey:@"stats"] objectForKey:@"event"] objectForKey:@"created"];
    _transactionsCount = [[[json objectForKey:@"stats"] objectForKey:@"flooz"] objectForKey:@"total"];
    
    _haveStatsPending = NO;
    
    NSNumber *statsPending = [[[json objectForKey:@"stats"] objectForKey:@"flooz"] objectForKey:@"pending"];
    if([statsPending intValue] > 0){
        _haveStatsPending = YES;
    }
    
    _settings = json[@"settings"];
    
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
    
    {
        _notifications = [NSMutableDictionary new];
                
        if([json objectForKey:@"notifications"]){
            NSDictionary *notificationsJSON = [json objectForKey:@"notifications"];
            
            for(NSString *key in notificationsJSON){
                NSDictionary *dictionary = [notificationsJSON objectForKey:key];
                [_notifications setObject:[dictionary mutableCopy] forKey:key];
            }
        }
    }
    
    {
        _notificationsText = [NSMutableDictionary new];
        
        if([json objectForKey:@"notifications"]){
            NSDictionary *notificationsJSON = [json objectForKey:@"notificationsText"];
            
            for(NSString *key in notificationsJSON){
                NSString *text = [notificationsJSON objectForKey:key];
                [_notificationsText setObject:text forKey:key];
            }
        }
    }
    
    if([json objectForKey:@"cards"] && [[json objectForKey:@"cards"] count] > 0){
        _creditCard = [[FLCreditCard alloc] initWithJSON:[[json objectForKey:@"cards"] objectAtIndex:0]];
    }
    
    {
        NSMutableArray *friends = [NSMutableArray new];
        
        if([json objectForKey:@"friends"]){
            for(NSDictionary *friendJSON in [json objectForKey:@"friends"]){                
                FLUser *friend = [[FLUser alloc] initWithJSON:friendJSON];
                [friends addObject:friend];
            }
        }
        
        _friends = friends;
    }
    
    {
        NSMutableArray *friendsRecent = [NSMutableArray new];
        
        if([json objectForKey:@"recentFriends"]){
            for(NSDictionary *friendJSON in [json objectForKey:@"recentFriends"]){
                FLUser *friend = [[FLUser alloc] initWithJSON:friendJSON];
                [friendsRecent addObject:friend];
            }
        }
        
        _friendsRecent = friendsRecent;
    }
    
    {
        NSMutableArray *friendsRequest = [NSMutableArray new];
        
        if([json objectForKey:@"friendsRequest"]){
            for(NSDictionary *friendRequestJSON in [json objectForKey:@"friendsRequest"]){
                FLFriendRequest *friendRequest = [[FLFriendRequest alloc] initWithJSON:friendRequestJSON];
                [friendsRequest addObject:friendRequest];
            }
        }
        
        _friendsRequest = friendsRequest;
    }
    
    _checkDocuments = @{};
    if([json objectForKey:@"check"]){
        _checkDocuments = [json objectForKey:@"check"];
    }
    
    _isFriendWaiting = NO;
    if(json[@"state"] && ![json[@"state"] isEqualToNumber:@1]){
        _isFriendWaiting = YES;
    }
    
    _record = json[@"record"];
    
    if(json[@"settings"]){
        _device = json[@"settings"][@"device"];
    }
    
    if(json[@"cactus"]){
        _username = nil;
    }
    
    if([[json objectForKey:@"invitation"] objectForKey:@"code"]){
        _invitCode = [[json objectForKey:@"invitation"] objectForKey:@"code"];
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
        return _avatarURL;
//        return [_avatarURL stringByAppendingFormat:@"?width=%d&height=%d", 2 * (int)floorf(size.width), 2 * (int)floorf(size.height)];
    }
    else{
        return nil;
    }
}

@end
