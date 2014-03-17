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
        _canParticipate = NO;
        
        if([[json objectForKey:@"actions"] objectForKey:@"1"]){
            _canParticipate = YES;
        }
    }
    
    {
        _canInvite = NO;
        
        if([[json objectForKey:@"actions"] objectForKey:@"2"]){
            _canInvite = YES;
        }
    }
    
    {
        _canGiveOrTakeOffer = NO;
        
        if([[json objectForKey:@"actions"] objectForKey:@"3"]){
            _canGiveOrTakeOffer = YES;
        }
    }
    
    {
        _canCancelOffer = NO;
        
        if([[json objectForKey:@"actions"] objectForKey:@"5"]){
            _canCancelOffer = YES;
        }
    }
    
    {
        _canAcceptOrDeclineOffer = NO;
        
        if([[json objectForKey:@"actions"] objectForKey:@"6"]){ // 6 decliner offre et 7 accepter
            _canAcceptOrDeclineOffer = YES;
        }
    }
    
    {
        _canDeclineInvite = NO;
        
        if([[json objectForKey:@"actions"] objectForKey:@"8"]){
            _canDeclineInvite = YES;
        }
    }
    
    
//    {
//        _canInvite = NO;
//        
//        if([[json objectForKey:@"isCreator"] boolValue] && ![[json objectForKey:@"closed"] boolValue]){
//            _canInvite = YES;
//        }
//    }
    
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

+ (NSString *)eventActionToParams:(EventAction)action
{
    if(action == EventActionParticipate){
        return @"participate";
    }
    else if(action == EventActionInvite){
        return @"invite";
    }
    else if(action == EventActionTakeOffer){
        return @"take";
    }
    else if(action == EventActionGiveOffer){
        return @"give";
    }
    else if(action == EventActionCancelOffer){
        return @"cancel";
    }
    else if(action == EventActionDeclineOffer){
        return @"decline";
    }
    else if(action == EventActionAcceptOffer){
        return @"accept";
    }
    else if(action == EventActionDeclineInvite){
        return @"declineInvite";
    }
    else{
        NSLog(@"Bad event action: %d", (int)action);
        return nil;
    }
}

@end
