//
//  UIFont+custom.h
//  Flooz
//
//  Created by olivier on 12/30/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (custom)

+ (UIFont *)customTitleNav;
+ (UIFont *)customTitleBook:(NSInteger)size;
+ (UIFont *)customTitleLight:(NSInteger)size;
+ (UIFont *)customTitleExtraLight:(NSInteger)size;
+ (UIFont *)customTitleThin:(NSInteger)size;

+ (UIFont *)customContentRegular:(NSInteger)size;
+ (UIFont *)customContentLight:(NSInteger)size;
+ (UIFont *)customContentBold:(NSInteger)size;
+ (UIFont *)customCreditCard:(NSInteger)size;

@end
