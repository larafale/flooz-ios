//
//  FLCreditCard.h
//  Flooz
//
//  Created by Olivier on 2/20/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLCreditCard : NSObject

@property (strong, nonatomic) NSString *cardId;
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSString *expires;

- (id)initWithJSON:(NSDictionary *)json;

@end
