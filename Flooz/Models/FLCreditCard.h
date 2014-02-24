//
//  FLCreditCard.h
//  Flooz
//
//  Created by jonathan on 2/20/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLCreditCard : NSObject

@property NSString *cardId;
@property NSString *owner;
@property NSString *number;

- (id)initWithJSON:(NSDictionary *)json;

@end
