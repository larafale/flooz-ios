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
    if(json[@"_id"]){
        _userId = json[@"_id"];
    }
    
    _amount = json[@"balance"];
    if(!_amount){
        // Argent mis dans une cagnotte
        _amount = json[@"amount"];
    }
    
    _firstname = json[@"firstName"];
    _lastname = json[@"lastName"];
    _fullname = json[@"name"];
    _username = json[@"nick"];
    _email = json[@"email"];
    _phone = json[@"phone"];
    _avatarURL = json[@"pic"];
    _profileCompletion = json[@"profileCompletion"];
    _hasSecureCode = json[@"secureCode"];
    
    if([_avatarURL isEqualToString:@"/img/nopic.png"]){
        _avatarURL = nil;
    }
    
    if(json[@"settings"]){
        _deviceToken = json[@"settings"][@"device"];
    }
    
    _friendsCount = [NSNumber numberWithInteger:[json[@"friends"] count]];
    _eventsCount = json[@"stats"][@"event"][@"created"];
    _transactionsCount = json[@"stats"][@"flooz"][@"total"];
    
    _haveStatsPending = NO;
    
    NSNumber *statsPending = json[@"stats"][@"flooz"][@"pending"];
    if([statsPending intValue] > 0){
        _haveStatsPending = YES;
    }
    
    _settings = json[@"settings"];
    
    {
        _address = [NSMutableDictionary new];
        
        if(json[@"settings"] && json[@"settings"][@"address"]){
            _address = [json[@"settings"][@"address"] mutableCopy];
        }
    }
    
    {
        _sepa = [NSMutableDictionary new];
        
        if(json[@"settings"] && json[@"settings"][@"sepa"]){
            _sepa = [json[@"settings"][@"sepa"] mutableCopy];
        }
    }
    
    {
        _notifications = [NSMutableDictionary new];
                
        if(json[@"notifications"]){
            NSDictionary *notificationsJSON = json[@"notifications"];
            
            for(NSString *key in notificationsJSON){
                NSDictionary *dictionary = notificationsJSON[key];
                [_notifications setObject:[dictionary mutableCopy] forKey:key];
            }
        }
    }
    
    {
        _notificationsText = [NSMutableDictionary new];
        
        if(json[@"notifications"]){
            NSDictionary *notificationsJSON = json[@"notificationsText"];
            
            for(NSString *key in notificationsJSON){
                NSString *text = notificationsJSON[key];
                [_notificationsText setObject:text forKey:key];
            }
        }
    }
    
    if(json[@"cards"] && [json[@"cards"] count] > 0){
        _creditCard = [[FLCreditCard alloc] initWithJSON:json[@"cards"][0]];
    }
    
    {
        NSMutableArray *friends = [NSMutableArray new];
        
        if(json[@"friends"]){
            for(NSDictionary *friendJSON in json[@"friends"]){                
                FLUser *friend = [[FLUser alloc] initWithJSON:friendJSON];
                [friends addObject:friend];
            }
        }
        
        _friends = friends;
    }
    
    {
        NSMutableArray *friendsRecent = [NSMutableArray new];
        
        if(json[@"recentFriends"]){
            for(NSDictionary *friendJSON in json[@"recentFriends"]){
                FLUser *friend = [[FLUser alloc] initWithJSON:friendJSON];
                [friendsRecent addObject:friend];
            }
        }
        
        _friendsRecent = friendsRecent;
    }
    
    {
        NSMutableArray *friendsRequest = [NSMutableArray new];
        
        if(json[@"friendsRequest"]){
            for(NSDictionary *friendRequestJSON in json[@"friendsRequest"]){
                FLFriendRequest *friendRequest = [[FLFriendRequest alloc] initWithJSON:friendRequestJSON];
                [friendsRequest addObject:friendRequest];
            }
        }
        
        _friendsRequest = friendsRequest;
    }
    
    _checkDocuments = @{};
    if(json[@"check"]){
        _checkDocuments = json[@"check"];
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
    
    if(json[@"invitation"][@"code"]){
        _invitCode = json[@"invitation"][@"code"];
    }
}

- (void)updateStatsPending:(NSDictionary *)json
{
    NSNumber *statsPending = json[@"stats"][@"flooz"][@"pending"];
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
