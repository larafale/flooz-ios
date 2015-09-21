//
//  NSString.m
//  Flooz
//
//  Created by Flooz on 7/17/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "NSString+custom.h"

@implementation NSString (custom)

- (CGFloat)widthOfString:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:self attributes:attributes] size].width;
}

+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

@end
