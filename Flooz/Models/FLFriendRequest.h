//
//  FLFriendRequest.h
//  Flooz
//
//  Created by jonathan on 2/23/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLUser.h"

@interface FLFriendRequest : NSObject

@property FLUser *user;
@property NSString *requestId;

- (id)initWithJSON:(NSDictionary *)json;

@end
