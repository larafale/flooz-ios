//
//  FLHelper.h
//  Flooz
//
//  Created by Olivier on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

BOOL isBorderlessDisplay(void);

@interface FLHelper : NSObject

+ (NSString *)generateRandomString;

+ (NSString *)formatedAmount:(NSNumber *)amount;
+ (NSString *)formatedAmount:(NSNumber *)amount withSymbol:(BOOL)withSymbol;
+ (NSString *)formatedAmount:(NSNumber *)amount withCurrency:(BOOL)withCurrency;
+ (NSString *)formatedAmount:(NSNumber *)amount withCurrency:(BOOL)withCurrency withSymbol:(BOOL)withSymbol;

+ (BOOL)isValidPhoneNumber:(NSString *)phone;
+ (NSString *)formatedDate:(NSDate *)date;
+ (NSString *)formatedDateFromNow:(NSDate *)date;
+ (NSString *)formatedPhone:(NSString *)phone;
+ (NSString *)hourInDate:(NSDate *)date;
+ (NSString *)momentWithDate:(NSDate *)date;
+ (BOOL)phoneMatch:(NSString *)phone1 withPhone:(NSString *)phone2;
+ (NSString *)fullPhone:(NSString *)phone withCountry:(NSString *)country;

+ (void)addMotionEffect:(UIView *)view;

+ (UIImage *)colorImage:(UIImage *)image color:(UIColor *)color;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale;
+ (CIImage *)createQRForString:(NSString *)qrString;
+ (NSString *)castNumber:(NSUInteger)number;

+ (CGFloat)cardScaleHeightFromWidth:(CGFloat)width;

+ (UIImage *)imageWithView:(UIView *)view;

@end
