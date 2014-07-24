//
//  FLHelper.h
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLHelper : NSObject

+ (NSString *)generateRandomString;

+ (NSString *)formatedAmount:(NSNumber *)amount;
+ (NSString *)formatedAmount:(NSNumber *)amount withSymbol:(BOOL)withSymbol;
+ (NSString *)formatedAmount:(NSNumber *)amount withCurrency:(BOOL)withCurrency;
+ (NSString *)formatedAmount:(NSNumber *)amount withCurrency:(BOOL)withCurrency withSymbol:(BOOL)withSymbol;

+ (NSString *)formatedDate:(NSDate *)date;
+ (NSString *)formatedDateFromNow:(NSDate *)date;
+ (NSString *)formatedPhone:(NSString *)phone;
+ (NSString *)formatedPhoneForDisplay:(NSString *)phone;

+ (void)addMotionEffect:(UIView *)view;

@end
