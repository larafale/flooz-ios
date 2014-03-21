//
//  FLSocial.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLSocial.h"
#import "Flooz.h"

@implementation FLSocial

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
    _commentsCount = [[json objectForKey:@"comments"] count];
    _likesCount = [[json objectForKey:@"likes"] count];
    _likeText = [json objectForKey:@"likesString"];
    
    _isCommented = NO;
    _isLiked = NO;
    
    for(NSDictionary *comment in [json objectForKey:@"comments"]){
        if([[comment objectForKey:@"userId"] isEqualToString:[[[Flooz sharedInstance] currentUser] userId]]){
            _isCommented = YES;
            break;
        }
    }
    
    for(NSDictionary *like in [json objectForKey:@"likes"]){
        if([[like objectForKey:@"userId"] isEqualToString:[[[Flooz sharedInstance] currentUser] userId]]){
            _isLiked = YES;
            break;
        }
    }
    
    if([[json objectForKey:@"scope"] intValue] == 0){
        _scope = SocialScopePublic;
    } else if([[json objectForKey:@"scope"] intValue] == 1){
        _scope = SocialScopeFriend;
    } else if([[json objectForKey:@"scope"] intValue] == 2){
        _scope = SocialScopePrivate;
    } else{
        _scope = SocialScopeNone;
    }
}

@end
