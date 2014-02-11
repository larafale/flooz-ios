//
//  FLHelper.h
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLHelper : NSObject

+ (NSString *)formatedAmount:(NSNumber *)amount;
+ (NSString *)formatedAmount:(NSNumber *)amount withCurrency:(BOOL)withCurrency;

+ (NSString *)formatedDate:(NSDate *)date;

@end
