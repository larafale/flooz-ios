//
//  FLEvent.m
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLEvent.h"

@implementation FLEvent

- (NSString *)statusText{
    if([self status] == EventStatusAccepted){
        return NSLocalizedString(@"EVENT_STATUS_ACCEPTED", nil);
    }else if([self status] == EventStatusRefused){
        return NSLocalizedString(@"EVENT_STATUS_REFUSED", nil);
    }else{
        return NSLocalizedString(@"EVENT_STATUS_WAITING", nil);
    }
}

+ (NSArray *)testData{
    NSMutableArray *events = [NSMutableArray new];
    
    FLEvent *event = nil;
    
    int i = 0;
    
    for(NSInteger status = EventStatusAccepted; status <= EventStatusWaiting; ++status){
        
        event = [FLEvent new];
        event.status = status;
        event.title = @"KDO pour lolo";
        event.content = [NSString stringWithFormat:@"%d Merci pour le café ;)", ++i];
        [events addObject:event];
        
        event = [FLEvent new];
        event.status = status;
        event.title = @"La fete a toto";
        event.content = [NSString stringWithFormat:@"%d Ca roxe", ++i];
        [events addObject:event];
        
        event = [FLEvent new];
        event.status = status;
        event.title = @"Diner entre amis";
        event.content = [NSString stringWithFormat:@"%d Plop plop plop", ++i];
        [events addObject:event];
        
    }
    
    return events;
}

@end
