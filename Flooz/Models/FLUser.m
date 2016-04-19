//
//  FLUser.m
//  Flooz
//
//  Created by Olivier on 1/20/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLUser.h"

@implementation FLUser

- (id)init {
    self = [super init];
    if (self) {
        self.userKind = PhoneUser;
        self.selectedFrom = nil;
        
        self.isIdentified = NO;
        self.isFloozer = NO;
    }
    return self;
}

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        self.userKind = FloozUser;
        [self setJSON:json];
        self.selectedFrom = nil;
        
        self.isIdentified = YES;
        self.isFloozer = YES;
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json {
    _json = json;
    if (json) {
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
        _bio = [json objectForKey:@"bio"];
        _location = [json objectForKey:@"location"];
        _website = [json objectForKey:@"website"];
        _coverURL = [json objectForKey:@"cover"];
        _coverLargeURL = [json objectForKey:@"coverFull"];
        _avatarURL = [json objectForKey:@"pic"];
        _avatarLargeURL = [json objectForKey:@"picFull"];
        _profileCompletion = [json objectForKey:@"profileCompletion"];
        _hasSecureCode = [json objectForKey:@"secureCode"];
        _blockObject = [json objectForKey:@"block"];
        _isCertified = [[json objectForKey:@"isCertified"] boolValue];
        _isCactus = [[json objectForKey:@"isCactus"] boolValue];
        _isFriend = [[json objectForKey:@"isFriend"] boolValue];
        _isAmbassador = [[json objectForKey:@"isAmbassador"] boolValue];
        _isPot = [[json objectForKey:@"isPot"] boolValue];

        if ([json objectForKey:@"participations"]) {
            _totalParticipations = [[json objectForKey:@"participations"] objectForKey:@"amount"];
            _countParticipations = [[json objectForKey:@"participations"] objectForKey:@"count"];
            _participations = [[json objectForKey:@"participations"] objectForKey:@"list"];
        }
        
        if (_isAmbassador) {
            _currentAmbassadorStep = [[json objectForKey:@"ambassador"] objectForKey:@"nextStep"];
        } else {
            _currentAmbassadorStep = [NSDictionary new];
        }
        
        _badges = [json objectForKey:@"badges"];
        
        if ([json objectForKey:@"isFriendable"])
            _isFriendable = [[json objectForKey:@"isFriendable"] boolValue];
        else
            _isFriendable = YES;
        
        _isComplete = [[json objectForKey:@"isComplete"] boolValue];
        
        _actions = [[json objectForKey:@"actions"] mutableCopy];
        _metrics = [json objectForKey:@"metrics"];
        
        if ([json objectForKey:@"birthdate"]) {
            NSArray *arrayB = [[json objectForKey:@"birthdate"] componentsSeparatedByString:@"-"];
            if (arrayB.count == 3) {
                NSString *birthdate = [NSString stringWithFormat:@"%@ / %@ / %@", [arrayB[2] substringToIndex:2], arrayB[1], arrayB[0]];
                _birthdate = birthdate;
            }
        }
        
        if ([_coverURL isEqualToString:@"/img/nocover.png"] || [_coverURL isBlank] || [_coverURL isEqualToString:@"/img/nopic.png"]) {
            _coverURL = nil;
        }
        
        if ([_coverLargeURL isEqualToString:@"/img/nocover.png"] || [_coverLargeURL isBlank] || [_coverLargeURL isEqualToString:@"/img/nopic.png"]) {
            _coverLargeURL = nil;
        }
        
        if ([_avatarURL isEqualToString:@"/img/nopic.png"] || [_avatarURL isBlank]) {
            _avatarURL = nil;
        }
        
        if ([_avatarLargeURL isEqualToString:@"/img/nopic.png"] || [_avatarLargeURL isBlank]) {
            _avatarLargeURL = nil;
        }
        
        if (_avatarURL && !_avatarLargeURL)
            _avatarLargeURL = [_avatarURL copy];
        
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
        
        if ([json objectForKey:@"card"]) {
            _creditCard = [[FLCreditCard alloc] initWithJSON:[json objectForKey:@"card"]];
        }
        
        {
            NSMutableArray *followings = [NSMutableArray new];
            NSMutableArray *unique = [NSMutableArray array];
            
            if ([_json objectForKey:@"followings"]) {
                for (NSDictionary *followingJSON in[_json objectForKey:@"followings"]) {
                    FLUser *following = [[FLUser alloc] initWithJSON:followingJSON];
                    if (following && [following userId] && ![following.userId isEqualToString:_userId] && ![unique containsObject:[following userId]]) {
                        [unique addObject:[following userId]];
                        [followings addObject:following];
                    }
                }
            }
            
            _followings = followings;
        }
        
        {
            NSMutableArray *followers = [NSMutableArray new];
            NSMutableArray *unique = [NSMutableArray array];
            
            if ([_json objectForKey:@"followers"]) {
                for (NSDictionary *followerJSON in[_json objectForKey:@"followers"]) {
                    FLUser *follower = [[FLUser alloc] initWithJSON:followerJSON];
                    if (follower && [follower userId] && ![follower.userId isEqualToString:_userId] && ![unique containsObject:[follower userId]]) {
                        [unique addObject:[follower userId]];
                        [followers addObject:follower];
                    }
                }
            }
            
            _followers = followers;
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
        
        if ([json objectForKey:@"publicMetrics"]) {
            _publicStats.nbFlooz = [[[json objectForKey:@"publicMetrics"] objectForKey:@"flooz"] integerValue];
            _publicStats.nbFriends = [[[json objectForKey:@"publicMetrics"] objectForKey:@"friends"] integerValue];
            _publicStats.nbFollowers = [[[json objectForKey:@"publicMetrics"] objectForKey:@"followers"] integerValue];
            _publicStats.nbFollowings = [[[json objectForKey:@"publicMetrics"] objectForKey:@"followings"] integerValue];
        } else {
            _publicStats.nbFlooz = [[[[json objectForKey:@"metrics"] objectForKey:@"emitted"] objectForKey:@"count"] integerValue];
            _publicStats.nbFriends = [_friends count];
            _publicStats.nbFollowers = [_followers count];
            _publicStats.nbFollowings = [_followings count];
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
            _country = [FLCountry countryFromIndicatif:json[@"settings"][@"indicatif"]];
        }
        
        if (json[@"isCactus"] && [json[@"isCactus"] boolValue]) {
            _userKind = CactusUser;
            _username = nil;
        }
        
        if ([[json objectForKey:@"invitation"] objectForKey:@"code"]) {
            _invitCode = [[json objectForKey:@"invitation"] objectForKey:@"code"];
        }
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
