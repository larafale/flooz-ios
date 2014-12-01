//
//  FLFriendRequest.m
//  Flooz
//
//  Created by jonathan on 2/23/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLFriendRequest.h"

@implementation FLFriendRequest

- (id)initWithJSON:(NSDictionary *)json {
	self = [super init];
	if (self) {
		[self setJSON:json];
	}
	return self;
}

- (void)setJSON:(NSDictionary *)json {
	_user = [[FLUser alloc] initWithJSON:json];
	if ([json objectForKey:@"_id"])
		_requestId = [json objectForKey:@"_id"];
	else if ([json objectForKey:@"id"])
		_requestId = [json objectForKey:@"id"];
}

@end
