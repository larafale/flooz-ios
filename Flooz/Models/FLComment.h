//
//  FLComment.h
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLComment : NSObject

@property FLUser *user;
@property NSString *content;
@property NSDate *date;
@property NSString *when;

- (id)initWithJSON:(NSDictionary *)json;

@end
