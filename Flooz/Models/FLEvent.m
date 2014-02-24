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
//    NSLog(@"%@", json);
    
    _eventId = [json objectForKey:@"_id"];
    
//    NSNumber *state = [json objectForKey:@"state"];
//    if([state integerValue] == 0){
//        _status = TransactionStatusPending;
//    }
//    else if([state integerValue] == 1){
//        _status = TransactionStatusAccepted;
//    }
//    else if([state integerValue] == 2){
//        _status = TransactionStatusRefused;
//    }
//    else if([state integerValue] == 3){
//        _status = TransactionStatusCanceled;
//    }
//    else if([state integerValue] == 4){
//        _status = TransactionStatusExpired;
//    }
//    
    _amount = [json objectForKey:@"amount"];

    _title = [json objectForKey:@"name"];
    _content = [json objectForKey:@"why"];
    
    _attachmentURL = [json objectForKey:@"pic"];
    _attachmentThumbURL = [json objectForKey:@"picMini"];
    
    _social = [[FLSocial alloc] initWithJSON:json];
    
    _isPrivate = YES;
    
    _creator = [[FLUser alloc] initWithJSON:[json objectForKey:@"creator"]];
    
    {
        NSMutableArray *participants = [NSMutableArray new];
        for(NSDictionary *paricipantJSON in [json objectForKey:@"participants"]){
            [participants addObject:[[FLUser alloc] initWithJSON:paricipantJSON]];
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
    }else if([self status] == EventStatusRefused){
        return NSLocalizedString(@"EVENT_STATUS_REFUSED", nil);
    }else{
        return NSLocalizedString(@"EVENT_STATUS_WAITING", nil);
    }
}

@end
