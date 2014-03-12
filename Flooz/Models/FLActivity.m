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
    _content = [json objectForKey:@"text"];
    _user = [[FLUser alloc] initWithJSON:[json objectForKey:@"emitter"]];
    
    if([[json objectForKey:@"type"] isEqualToString:@"commentsLine"]){
        _type = ActivityTypeCommentTransaction;
    }
    else if([[json objectForKey:@"type"] isEqualToString:@"commentsEvent"]){
        _type = ActivityTypeCommentEvent;
    }
    else if([[json objectForKey:@"type"] isEqualToString:@"likesLine"]){
        _type = ActivityTypeLikeTransaction;
    }
    else if([[json objectForKey:@"type"] isEqualToString:@"likesEvent"]){
        _type = ActivityTypeLikeEvent;
    }
    else if([[json objectForKey:@"type"] isEqualToString:@"friendRequest"]){
        _type = ActivityTypeFriendRequest;
    }
    else if([[json objectForKey:@"type"] isEqualToString:@"friendRequestAnswer"]){
        _type = ActivityTypeFriendRequestAccepted;
    }
    else if([[json objectForKey:@"type"] isEqualToString:@"friendJoined"]){
        _type = ActivityTypeFriendJoined;
    }
    else{
        NSLog(@"activity type unknown: %@", [json objectForKey:@"type"] );
    }
    
    if([json objectForKey:@"data"]){
        if([[json objectForKey:@"data"] objectForKey:@"line"]){
            _transactionId = [[json objectForKey:@"data"] objectForKey:@"line"];
        }
        else if([[json objectForKey:@"data"] objectForKey:@"event"]){
            _eventId = [[json objectForKey:@"data"] objectForKey:@"event"];
        }
    }
}

@end
