//
//  FLActivity.m
//  Flooz
//
//  Created by jonathan on 2/14/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLActivity.h"

@implementation FLActivity

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
    _content = json[@"text"];
    _user = [[FLUser alloc] initWithJSON:json[@"emitter"]];
    
    // Si 0 alors pas lu
    _isRead = [json[@"state"] intValue] != 0;
    
    _isFriend = NO;
    if(json[@"resource"]){
        if([json[@"resource"][@"type"] isEqualToString:@"line"]){
            _transactionId = json[@"resource"][@"resourceId"];
        }
        else if([json[@"resource"][@"type"] isEqualToString:@"event"]){
            _eventId = json[@"resource"][@"resourceId"];
        }
        else if([json[@"resource"][@"type"] isEqualToString:@"friend"]){
            _isFriend = YES;
        }
    }
    
    _isForCompleteProfil = NO;
    if([json[@"type"] isEqualToString:@"completeProfile"]){
        _isForCompleteProfil = YES;
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
        static NSDateFormatter *dateFormatter;
        if(!dateFormatter){
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [dateFormatter setDateFormat:@"dd' 'MMMM', 'HH':'mm"];
        }
        
        _dateText = [dateFormatter stringFromDate:_date];
    }
    
    _when = [FLHelper formatedDateFromNow:_date];
}

@end
