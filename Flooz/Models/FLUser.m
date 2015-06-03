//
//  FLUser.m
//  Flooz
//
//  Created by olivier on 1/20/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLUser.h"

@implementation FLUser

- (id)init {
    self = [super init];
    if (self) {
        self.userKind = PhoneUser;
        self.selectedFrom = nil;
    }
    return self;
}

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        self.userKind = FloozUser;
        [self setJSON:json];
        self.selectedFrom = nil;
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json {
    _json = json;
    if ([json objectForKey:@"_id"]) {
        _userId = [json objectForKey:@"_id"];
    }
    
    _amount = [json objectForKey:@"balance"];
    if (!_amount) {
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
    _blockObject = [json objectForKey:@"block"];
    
    if ([json objectForKey:@"birthdate"]) {
        NSArray *arrayB = [[json objectForKey:@"birthdate"] componentsSeparatedByString:@"-"];
        if (arrayB.count == 3) {
            NSString *birthdate = [NSString stringWithFormat:@"%@ / %@ / %@", [arrayB[2] substringToIndex:2], arrayB[1], arrayB[0]];
            _birthdate = birthdate;
        }
    }
    
    if ([_avatarURL isEqualToString:@"/img/nopic.png"]) {
        _avatarURL = nil;
    }
    
    if (json[@"device"]) {
        _deviceToken = [json objectForKey:@"device"];
    }
    
    _friendsCount = [NSNumber numberWithInteger:[[json objectForKey:@"friends"] count]];
    _transactionsCount = [[[json objectForKey:@"stats"] objectForKey:@"flooz"] objectForKey:@"total"];
    
    _ux = json[@"ux"];
    _settings = json[@"settings"];
    
    {
        _address = [NSMutableDictionary new];
        
        if ([json objectForKey:@"settings"] && [[json objectForKey:@"settings"] objectForKey:@"address"]) {
            _address = [[[json objectForKey:@"settings"] objectForKey:@"address"] mutableCopy];
        }
    }
    
    {
        _sepa = [NSMutableDictionary new];
        
        if ([json objectForKey:@"settings"] && [[json objectForKey:@"settings"] objectForKey:@"sepa"]) {
            _sepa = [[[json objectForKey:@"settings"] objectForKey:@"sepa"] mutableCopy];
        }
    }
    
    {
        _notifications = [NSMutableDictionary new];
        
        if ([json objectForKey:@"notifications"]) {
            NSDictionary *notificationsJSON = [json objectForKey:@"notifications"];
            
            for (NSString *key in notificationsJSON) {
                NSDictionary *dictionary = [notificationsJSON objectForKey:key];
                [_notifications setObject:[dictionary mutableCopy] forKey:key];
            }
        }
    }
    
    {
        _notificationsText = [NSMutableDictionary new];
        
        if ([json objectForKey:@"notifications"]) {
            NSDictionary *notificationsJSON = [json objectForKey:@"notificationsText"];
            
            for (NSString *key in notificationsJSON) {
                NSString *text = [notificationsJSON objectForKey:key];
                [_notificationsText setObject:text forKey:key];
            }
        }
    }
    
    if ([json objectForKey:@"cards"] && [[json objectForKey:@"cards"] count] > 0) {
        _creditCard = [[FLCreditCard alloc] initWithJSON:[[json objectForKey:@"cards"] objectAtIndex:0]];
    }
    
    {
        NSMutableArray *friends = [NSMutableArray new];
        NSMutableArray *unique = [NSMutableArray array];
        
        if ([_json objectForKey:@"friends"]) {
            for (NSDictionary *friendJSON in[_json objectForKey:@"friends"]) {
                FLUser *friend = [[FLUser alloc] initWithJSON:friendJSON];
                if (friend && [friend userId] && ![friend.userId isEqualToString:_userId] && ![unique containsObject:[friend userId]]) {
                    [unique addObject:[friend userId]];
                    [friends addObject:friend];
                }
            }
        }
        
        _friends = friends;
    }
    
    {
        NSMutableArray *friendsRecent = [NSMutableArray new];
        NSMutableArray *unique = [NSMutableArray array];
        
        if ([json objectForKey:@"recentFriends"]) {
            for (NSDictionary *friendJSON in[json objectForKey:@"recentFriends"]) {
                FLUser *friend = [[FLUser alloc] initWithJSON:friendJSON];
                if (friend && [friend userId] && ![friend.userId isEqualToString:_userId] && ![unique containsObject:[friend userId]]) {
                    [unique addObject:[friend userId]];
                    [friendsRecent addObject:friend];
                }
            }
        }
        
        _friendsRecent = friendsRecent;
    }
    
    {
        NSMutableArray *friendsRequest = [NSMutableArray new];
        NSMutableArray *unique = [NSMutableArray array];
        
        if ([json objectForKey:@"friendsRequest"]) {
            for (NSDictionary *friendRequestJSON in[json objectForKey:@"friendsRequest"]) {
                FLFriendRequest *friendRequest = [[FLFriendRequest alloc] initWithJSON:friendRequestJSON];
                if (friendRequest && [friendRequest requestId] && ![unique containsObject:[friendRequest requestId]]) {
                    [unique addObject:[friendRequest requestId]];
                    [friendsRequest addObject:friendRequest];
                }
            }
        }
        
        _friendsRequest = friendsRequest;
    }
    
    _checkDocuments = @{};
    if ([json objectForKey:@"check"]) {
        _checkDocuments = [json objectForKey:@"check"];
    }
    
    _isFriendWaiting = NO;
    if (json[@"state"] && ![json[@"state"] isEqualToNumber:@1]) {
        _isFriendWaiting = YES;
    }
    
    _record = json[@"record"];
    
    if (json[@"settings"]) {
        _device = json[@"settings"][@"device"];
    }
    
    if (json[@"cactus"] || (json[@"isCactus"] && [json[@"isCactus"] boolValue])) {
        _userKind = CactusUser;
        _username = nil;
    }
    
    if ([[json objectForKey:@"invitation"] objectForKey:@"code"]) {
        _invitCode = [[json objectForKey:@"invitation"] objectForKey:@"code"];
    }
}

- (NSArray *)removeDuplicatesUserInArray:(NSArray *)array {
    NSMutableArray *unique = [NSMutableArray array];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
    for (FLUser *obj in array) {
        if ([obj userId] && ![obj.userId isEqualToString:_userId] && ![unique containsObject:[obj userId]]) {
            [unique addObject:[obj userId]];
            [indexSet addIndex:[array indexOfObject:obj]];
        }
    }
    return [array objectsAtIndexes:indexSet];
}

- (NSArray *)removeDuplicatesRequestInArray:(NSArray *)array {
    NSMutableArray *unique = [NSMutableArray array];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
    for (FLFriendRequest *obj in array) {
        if ([obj requestId] && ![unique containsObject:[obj requestId]]) {
            [unique addObject:[obj requestId]];
            [indexSet addIndex:[array indexOfObject:obj]];
        }
    }
    return [array objectsAtIndexes:indexSet];
}

- (NSString *)avatarURL:(CGSize)size {
    if (_avatarURL) {
        return _avatarURL;
        //        return [_avatarURL stringByAppendingFormat:@"?width=%d&height=%d", 2 * (int)floorf(size.width), 2 * (int)floorf(size.height)];
    }
    else {
        return nil;
    }
}

- (void)setSelectedCanal:(FLUserSelectedCanal)canal {
    switch (canal) {
        case RecentCanal:
            self.selectedFrom = @"recent";
            break;
        case SuggestionCanal:
            self.selectedFrom = @"suggestion";
            break;
        case FriendsCanal:
            self.selectedFrom = @"friends";
            break;
        case SearchCanal:
            self.selectedFrom = @"search";
            break;
        case TimelineCanal:
            self.selectedFrom = @"timeline";
            break;
        case ContactCanal:
            self.selectedFrom = @"contact";
            break;
        default:
            break;
    }
}

@end
