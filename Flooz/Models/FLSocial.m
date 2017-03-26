//
//  FLSocial.m
//  Flooz
//
//  Created by Olivier on 1/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLSocial.h"
#import "Flooz.h"

@implementation FLSocial

- (id)initWithJSON:(NSDictionary *)json {
	self = [super init];
	if (self) {
		[self setJSON:json];
	}
	return self;
}

- (void)setJSON:(NSDictionary *)json {
	_commentsCount = [[json objectForKey:@"comments"] count];
	_likesCount = [[json objectForKey:@"likes"] count];
        
	_likeText = [json objectForKey:@"likesString"];
    _commentText = [json objectForKey:@"commentsString"];

	_isCommented = NO;
	_isLiked = NO;

    _likes = [json objectForKey:@"likes"];
    
    NSMutableArray *mutableLikes = [NSMutableArray new];
    
    for (NSDictionary* like in _likes) {
        FLUser *liker = [[FLUser alloc] initWithJSON:like];
        liker.userId = like[@"userId"];
        
        [mutableLikes addObject:liker];
    }
    
    _likes = mutableLikes;
    
    _comments = [json objectForKey:@"comments"];
    
	for (NSDictionary *comment in [json objectForKey:@"comments"]) {
		if ([[comment objectForKey:@"userId"] isEqualToString:[[[Flooz sharedInstance] currentUser] userId]]) {
			_isCommented = YES;
			break;
		}
	}

	for (NSDictionary *like in [json objectForKey:@"likes"]) {
		if ([[like objectForKey:@"userId"] isEqualToString:[[[Flooz sharedInstance] currentUser] userId]]) {
			_isLiked = YES;
			break;
		}
	}

    _scope = [FLScope scopeFromObject:[json objectForKey:@"scope"]];
}

@end
