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
    
    NSString *state = [json objectForKey:@"statusString"];
    if([[json objectForKey:@"closed"] boolValue]){
        _status = EventStatusRefused;
    }
    else if([state isEqualToString:@"invited"]){
        _status = EventStatusPending;
    }
    else if([state isEqualToString:@"participating"]){
        _status = EventStatusAccepted;
    }
    else{
        NSLog(@"FLEevent status: %@", state);
//        _status = EventStatusRefused;
        
        // Tester si encore possible
        
        _status = -1;
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
        _isRefusable = NO;
        if([[json objectForKey:@"actions"] objectForKey:@"2"]){
            _isRefusable = YES;
        }
    }
    
    {
        _isCollectable = NO;
        
        if([[json objectForKey:@"actions"] objectForKey:@"3"]){
            _isCollectable = YES;
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
    else if([self status] == EventStatusRefused){
        return NSLocalizedString(@"EVENT_STATUS_REFUSED", nil);
    }
    else if([self status] == EventStatusPending){
        return NSLocalizedString(@"EVENT_STATUS_WAITING", nil);
    }
    else{
        return nil;
    }
}

@end
