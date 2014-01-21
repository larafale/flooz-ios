//
//  FLUser.h
//  Flooz
//
//  Created by jonathan on 1/20/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLUser : NSObject

@property NSNumber *amount;
@property NSString *firstname;
@property NSString *lastname;
@property NSString *username;
@property NSString *email;
@property NSString *phone;

- (id)initWithJSON:(NSDictionary *)json;

@end
