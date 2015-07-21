//
//  UIFont+custom.m
//  Flooz
//
//  Created by olivier on 12/30/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "UIFont+custom.h"

@implementation UIFont (custom)

+ (UIFont *)customTitleBook:(NSInteger)size {
	return [UIFont fontWithName:@"Gentona-Book" size:size];
}

+ (UIFont *)customTitleNav {
    return [UIFont fontWithName:@"Gentona-ExtraLight" size:20];
}

+ (UIFont *)customTitleLight:(NSInteger)size {
	return [UIFont fontWithName:@"Gentona-Light" size:size];
}

+ (UIFont *)customTitleExtraLight:(NSInteger)size {
	return [UIFont fontWithName:@"Gentona-ExtraLight" size:size];
}

+ (UIFont *)customTitleThin:(NSInteger)size {
	return [UIFont fontWithName:@"Gentona-Thin" size:size];
}

+ (UIFont *)customContentRegular:(NSInteger)size {
	return [UIFont fontWithName:@"ProximaNova-Regular" size:size];
}

+ (UIFont *)customContentLight:(NSInteger)size {
	return [UIFont fontWithName:@"ProximaNova-Light" size:size];
}

+ (UIFont *)customContentBold:(NSInteger)size {
	return [UIFont fontWithName:@"ProximaNova-Semibold" size:size];
}

@end
