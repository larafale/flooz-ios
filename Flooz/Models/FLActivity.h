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

- (id)initWithJSON:(NSDictionary *)json;

@end
