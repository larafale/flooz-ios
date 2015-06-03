//
//  FLHelper.h
//  Flooz
//
//  Created by olivier on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
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
+ (NSString *)formatedPhone2:(NSString *)phone;
+ (NSString *)formatedPhoneForDisplay:(NSString *)phone;
+ (NSString *)hourInDate:(NSDate *)date;
+ (NSString *)momentWithDate:(NSDate *)date;

+ (void)addMotionEffect:(UIView *)view;

+ (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale;
+ (CIImage *)createQRForString:(NSString *)qrString;


@end
