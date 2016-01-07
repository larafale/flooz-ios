//
//  NSString.h
//  Flooz
//
//  Created by Flooz on 7/17/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (custom)

- (Boolean)isBlank;

- (CGFloat)widthOfString:(UIFont *)font;
+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font;

@end
