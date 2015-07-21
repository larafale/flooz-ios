//
//  NSString.h
//  Flooz
//
//  Created by Epitech on 7/17/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (custom)

- (CGFloat)widthOfString:(UIFont *)font;
+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font;

@end
