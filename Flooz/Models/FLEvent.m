//
//  FLEvent.m
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLEvent.h"

@implementation FLEvent

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
    _eventId = [json objectForKey:@"_id"];
    
    if([[json objectForKey:@"isInvited"] boolValue]){
        _status = EventStatusPending;
    }
    else if([[json objectForKey:@"isAttending"] boolValue]){
        _status = EventStatusAccepted;
    }
    else{
        _status = EventStatusRefused;
    }
    
    _amount = [json objectForKey:@"amount"];
    _amountCollect = [json objectForKey:@"total"];
    
    _title = [json objectForKey:@"name"];
    _content = [json objectForKey:@"why"];
    
    _attachmentURL = [json objectForKey:@"pic"];
    _attachmentThumbURL = [json objectForKey:@"picMini"];
    
    _social = [[FLSocial alloc] initWithJSON:json];
    
    {
        _isPrivate = NO;
        if([[json objectForKey:@"canParticipate"] boolValue]){
            _isPrivate = YES;
        }
    }
    
    {
        _isAcceptable = NO;
        
        if([[json objectForKey:@"actions"] objectForKey:@"1"]){
            _isAcceptable = YES;
        }
    }
    
    {
        _isCollectable = NO;
        
        if([[json objectForKey:@"actions"] objectForKey:@"3"]){
            _isCollectable = YES;
        }
    }
    
    {
        _canInvite = NO;
        
        if([[json objectForKey:@"isCreator"] boolValue] && ![[json objectForKey:@"closed"] boolValue]){
            _canInvite = YES;
        }
    }
        
    _creator = [[FLUser alloc] initWithJSON:[json objectForKey:@"creator"]];
    
    {
        NSMutableArray *participants = [NSMutableArray new];
        for(NSDictionary *participantJSON in [json objectForKey:@"participants"]){
            [participants addObject:[[FLUser alloc] initWithJSON:participantJSON]];
        }
        _participants = participants;
    }
    
    {
        static NSDateFormatter *dateFormatter;
        if(!dateFormatter){
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        }
        
        _date = [dateFormatter dateFromString:[json objectForKey:@"cAt"]];
    }
    
    {
        NSMutableArray *comments = [NSMutableArray new];
        for(NSDictionary *commentJSON in [json objectForKey:@"comments"]){
            [comments addObject:[[FLComment alloc] initWithJSON:commentJSON]];
        }
        _comments = comments;
    }
}

- (NSString *)statusText{
    if([self status] == EventStatusAccepted){
        return NSLocalizedString(@"EVENT_STATUS_ACCEPTED", nil);
    }
    else if([self status] == EventStatusPending){
        return NSLocalizedString(@"EVENT_STATUS_WAITING", nil);
    }
    else{
        return nil;
    }
}

+ (NSString *)transactionScopeToText:(TransactionScope)scope
{
    NSString *key = nil;
    
    if(scope == TransactionScopeFriend){
        key = @"FRIEND";
    }
    else{ // if(status == TransactionScopePrivate){
        key = @"PRIVATE";
    }
    
    return NSLocalizedString([@"EVENT_SCOPE_" stringByAppendingString:key], nil);
}

@end
