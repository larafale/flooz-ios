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
    return [UIColor colorWithIntegerRed:36 green:47 blue:58 alpha:alpha];
}

+ (UIColor *)customBackgroundStatus{
    return [self customBackgroundStatus:1.0];
}

+ (UIColor *)customBackgroundStatus:(CGFloat)alpha{
    return [UIColor colorWithIntegerRed:45 green:58 blue:70 alpha:alpha];
}

+ (UIColor *)customBackgroundHeader{
    return [self customBackgroundHeader:1.0];
}

+ (UIColor *)customBackgroundHeader:(CGFloat)alpha{
    return [UIColor colorWithIntegerRed:24 green:33 blue:43 alpha:alpha];
}

+ (UIColor *)customGreen{
    return [self customGreen:1.0];
}

+ (UIColor *)customGreen:(CGFloat)alpha{
    return [UIColor colorWithIntegerRed:122 green:194 blue:131 alpha:alpha];
}

+ (UIColor *)customRed{
    return [self customRed:1.0];
}

+ (UIColor *)customRed:(CGFloat)alpha{
    return [UIColor colorWithIntegerRed:225 green:114 blue:114 alpha:alpha];
}

+ (UIColor *)customYellow{
    return [self customYellow:1.0];
}

+ (UIColor *)customYellow:(CGFloat)alpha{
    return [UIColor colorWithIntegerRed:213 green:209 blue:122 alpha:alpha];
}

+ (UIColor *)customWhite{
    return [self customWhite:1.0];
}

+ (UIColor *)customWhite:(CGFloat)alpha{
    return [UIColor colorWithIntegerRed:84 green:99 blue:109 alpha:alpha];
}

+ (UIColor *)customSeparator{
    return [self customSeparator:1.0];
}

+ (UIColor *)customSeparator:(CGFloat)alpha{
    return [UIColor colorWithIntegerRed:51 green:62 blue:74 alpha:alpha];
}

+ (UIColor *)customBlue{
    return [self customBlue:1.0];
}

+ (UIColor *)customBlue:(CGFloat)alpha{
    return [UIColor colorWithIntegerRed:58 green:169 blue:227 alpha:alpha];
}

+ (UIColor *)customBlueLight{
    return [self customBlueLight:1.0];
}

+ (UIColor *)customBlueLight:(CGFloat)alpha{
    return [UIColor colorWithIntegerRed:96 green:146 blue:172 alpha:alpha];
}

+ (UIColor *)customBlueHover{
    return [self customBlueHover:1.0];
}

+ (UIColor *)customBlueHover:(CGFloat)alpha{
    return [UIColor colorWithIntegerRed:38 green:59 blue:75 alpha:alpha];
}

+ (UIColor *)customPlaceholder{
    return [UIColor customPlaceholder:1.];
}

+ (UIColor *)customPlaceholder:(CGFloat)alpha{
    return [UIColor colorWithIntegerRed:135 green:147 blue:157 alpha:alpha];
}

@end
