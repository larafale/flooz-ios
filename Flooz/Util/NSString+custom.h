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

- (NSString *)urlencode;

- (CGFloat)widthOfString:(UIFont *)font;
+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font;
- (CGFloat)fontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

@end
