//
//  UIColor+custom.h
//  Flooz
//
//  Created by jonathan on 12/30/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
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

+ (UIColor *)customPlaceholder;

@end
