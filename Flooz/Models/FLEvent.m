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
    _eventId = json[@"_id"];
    
    if([json[@"isInvited"] boolValue]){
        _status = EventStatusPending;
    }
    else if([json[@"isAttending"] boolValue]){
        _status = EventStatusAccepted;
    }
    else{
        _status = EventStatusRefused;
    }
    
    _isNew = [json[@"isAttending"] boolValue];
    
    _amount = json[@"amount"];
    _amountCollected = json[@"total"];
    _amountExpected = json[@"goal"];
    
    if([_amountExpected isEqualToNumber:@0]){
        _amountExpected = nil;
    }
        
    _dayLeft = json[@"endWhen"];
    _pourcentage = json[@"fulfilled"];
    _isClosed = [json[@"closed"] boolValue];
    
    _isInvited = NO;
    if(json[@"isInvited"] && [json[@"isInvited"] boolValue]){
        _isInvited = YES;
    }
        
    _title = json[@"name"];
    _content = json[@"why"];
    
    _attachmentURL = json[@"pic"];
    _attachmentThumbURL = json[@"picMini"];
    
    _social = [[FLSocial alloc] initWithJSON:json];
//    _social.scope = SocialScopeNone;
    
    _isCreator = [json[@"isCreator"] boolValue];
    
    if([json[@"scope"] intValue] == 1){
        _scope = TransactionScopeFriend;
        _social.scope = SocialScopeFriend;
    }
    else{
        _scope = TransactionScopePrivate;
        _social.scope = SocialScopePrivate;
    }
    
    {
        _isPrivate = NO;
        if([json[@"canParticipate"] boolValue]){
            _isPrivate = YES;
        }
    }
    
    {
        _canParticipate = NO;
        
        if(json[@"actions"][@"1"]){
            _canParticipate = YES;
        }
    }
    
    {
        _canInvite = NO;
        
        if(json[@"actions"][@"2"]){
            _canInvite = YES;
        }
    }
    
    {
        _canGiveOrTakeOffer = NO;
        
        if(json[@"actions"][@"3"]){
            _canGiveOrTakeOffer = YES;
        }
    }
    
    {
        _canCancelOffer = NO;
        
        if(json[@"actions"][@"5"]){
            _canCancelOffer = YES;
        }
    }
    
    {
        _canAcceptOrDeclineOffer = NO;
        
        if(json[@"actions"][@"6"]){ // 6 decliner offre et 7 accepter
            _canAcceptOrDeclineOffer = YES;
        }
    }
    
    {
        _canDeclineInvite = NO;
        
        if(json[@"actions"][@"8"]){
            _canDeclineInvite = YES;
        }
    }
    
    
//    {
//        _canInvite = NO;
//        
//        if([json[@"isCreator"] boolValue] && ![json[@"closed"] boolValue]){
//            _canInvite = YES;
//        }
//    }
    
    _creator = [[FLUser alloc] initWithJSON:json[@"creator"]];
    
    {
        NSMutableArray *participants = [NSMutableArray new];
        for(NSDictionary *participantJSON in json[@"participants"]){
            [participants addObject:[[FLUser alloc] initWithJSON:participantJSON]];
        }
        _participants = participants;
    }
    
    {
        static NSDateFormatter *dateFormatter;
        if(!dateFormatter){
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        }
        
        _date = [dateFormatter dateFromString:json[@"cAt"]];
    }
    
    {
        NSMutableArray *comments = [NSMutableArray new];
        for(NSDictionary *commentJSON in json[@"comments"]){
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

+ (NSString *)eventScopeToText:(TransactionScope)scope
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

+ (UIImage *)eventScopeToImage:(TransactionScope)scope
{
    NSString *key = nil;
    
    if(scope == TransactionScopeFriend){
        key = @"scope-friend-large-selected";
    }
    else{ // if(status == TransactionScopePrivate){
        key = @"scope-invite-large-selected";
    }
    
    return [UIImage imageNamed:key];
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
