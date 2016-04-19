//
//  UIColor+custom.h
//  Flooz
//
//  Created by Olivier on 12/30/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (custom)

+ (UIColor *)customBackground;
+ (UIColor *)customBackground:(CGFloat)alpha;
+ (UIColor *)customBackgroundStatus;
+ (UIColor *)customBackgroundStatus:(CGFloat)alpha;
+ (UIColor *)customBackgroundHeader;
+ (UIColor *)customBackgroundHeader:(CGFloat)alpha;
+ (UIColor *)customGreen;
+ (UIColor *)customGreen:(CGFloat)alpha;
+ (UIColor *)customRed;
+ (UIColor *)customRed:(CGFloat)alpha;
+ (UIColor *)customRedBadge;
+ (UIColor *)customRedBadge:(CGFloat)alpha;
+ (UIColor *)customYellow;
+ (UIColor *)customYellow:(CGFloat)alpha;
+ (UIColor *)customWhite;
+ (UIColor *)customWhite:(CGFloat)alpha;
+ (UIColor *)customSeparator;
+ (UIColor *)customSeparator:(CGFloat)alpha;
+ (UIColor *)customBlue;
+ (UIColor *)customBlue:(CGFloat)alpha;
+ (UIColor *)customBlueLight;
+ (UIColor *)customBlueLight:(CGFloat)alpha;
+ (UIColor *)customBlueHover;
+ (UIColor *)customBlueHover:(CGFloat)alpha;
+ (UIColor *)customMiddleBlue;
+ (UIColor *)customMiddleBlue:(CGFloat)alpha;
+ (UIColor *)customGrey;
+ (UIColor *)customPink;
+ (UIColor *)customPink:(CGFloat)alpha;
+ (UIColor *)customTwitterBlue;
+ (UIColor *)customTwitterBlue:(CGFloat)alpha;
+ (UIColor *)customFacebookBlue;
+ (UIColor *)customFacebookBlue:(CGFloat)alpha;

+ (UIColor *)customPlaceholder;
+ (UIColor *)customPlaceholder:(CGFloat)alpha;

+ (UIColor *)customGreyPseudo;
+ (UIColor *)customGreyPseudo:(CGFloat)alpha;

+ (UIColor *)customSocialColor;
+ (UIColor *)customSocialColor:(CGFloat)alpha;

+ (UIColor *)customBackgroundSocial;
+ (UIColor *)customBackgroundSocial:(CGFloat)alpha;

+ (UIColor *)colorWithHex:(UInt32)col;
+ (UIColor *)colorWithHexString:(NSString *)str;

@end
