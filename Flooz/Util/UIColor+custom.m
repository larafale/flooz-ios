//
//  UIColor+custom.m
//  Flooz
//
//  Created by jonathan on 12/30/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "UIColor+custom.h"

@implementation UIColor (custom)

+ (UIColor *)customBackground{
    return [self customBackground:1.0];
}

+ (UIColor *)customBackground:(CGFloat)alpha{
    return [UIColor colorWithRed:36./256. green:47./256. blue:58./256. alpha:alpha];
}

+ (UIColor *)customBackgroundStatus{
    return [self customBackgroundStatus:1.0];
}

+ (UIColor *)customBackgroundStatus:(CGFloat)alpha{
    return [UIColor colorWithRed:45./256. green:58./256. blue:70./256. alpha:alpha];
}

+ (UIColor *)customBackgroundHeader{
    return [self customBackgroundHeader:1.0];
}

+ (UIColor *)customBackgroundHeader:(CGFloat)alpha{
    return [UIColor colorWithRed:28./256. green:38./256. blue:47./256. alpha:alpha];
}

+ (UIColor *)customGreen{
    return [self customGreen:1.0];
}

+ (UIColor *)customGreen:(CGFloat)alpha{
    return [UIColor colorWithRed:122./256. green:194./256. blue:131./256. alpha:alpha];
}

+ (UIColor *)customRed{
    return [self customRed:1.0];
}

+ (UIColor *)customRed:(CGFloat)alpha{
    return [UIColor colorWithRed:225./256. green:114./256. blue:114./256. alpha:alpha];
}

+ (UIColor *)customYellow{
    return [self customYellow:1.0];
}

+ (UIColor *)customYellow:(CGFloat)alpha{
    return [UIColor colorWithRed:213./256. green:209./256. blue:122./256. alpha:alpha];
}

+ (UIColor *)customWhite{
    return [self customWhite:1.0];
}

+ (UIColor *)customWhite:(CGFloat)alpha{
    return [UIColor colorWithRed:84./256. green:99./256. blue:109./256. alpha:alpha];
}

+ (UIColor *)customSeparator{
    return [self customSeparator:1.0];
}

+ (UIColor *)customSeparator:(CGFloat)alpha{
    return [UIColor colorWithRed:51./256. green:62./256. blue:74./256. alpha:alpha];
}

+ (UIColor *)customBlue{
    return [self customBlue:1.0];
}

+ (UIColor *)customBlue:(CGFloat)alpha{
    return [UIColor colorWithRed:58./256. green:169./256. blue:227./256. alpha:alpha];
}

+ (UIColor *)customBlueLight{
    return [self customBlueLight:1.0];
}

+ (UIColor *)customBlueLight:(CGFloat)alpha{
    return [UIColor colorWithRed:96./256. green:146./256. blue:172./256. alpha:alpha];
}

@end
