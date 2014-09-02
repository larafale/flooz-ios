//
//  FLCreditCard.h
//  Flooz
//
//  Created by jonathan on 2/20/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLCreditCard : NSObject

@property (strong, nonatomic) NSString *cardId;
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSString *number;

- (id)initWithJSON:(NSDictionary *)json;

@end
