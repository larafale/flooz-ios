//
//  FLActivity.h
//  Flooz
//
//  Created by jonathan on 2/14/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLActivity : NSObject

@property FLUser *user;
@property NSString *content;
@property BOOL isRead;

@property NSString *eventId;
@property NSString *transactionId;
@property BOOL isFriend;

@property NSDate *date;
@property NSString *when;

- (id)initWithJSON:(NSDictionary *)json;

@end
