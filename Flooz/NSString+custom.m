//
//  NSString.m
//  Flooz
//
//  Created by Flooz on 7/17/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "NSString+custom.h"

@implementation NSString (custom)

- (Boolean)isBlank {
    if ([self length] == 0)
        return YES;
    
    if(![[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
        return YES;
    
    return NO;
}

- (CGFloat)widthOfString:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:self attributes:attributes] size].width;
}

+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

- (CGFloat)fontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    CGFloat fontSize = [font pointSize];
    CGFloat height = [self sizeWithFont:font constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
    UIFont *newFont = font;
    
    //Reduce font size while too large, break if no height (empty string)
    while (height > size.height && height != 0) {
        fontSize--;
        newFont = [UIFont fontWithName:font.fontName size:fontSize];
        height = [self sizeWithFont:newFont constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
    };
    
    // Loop through words in string and resize to fit
    for (NSString *word in [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]) {
        CGFloat width = [word sizeWithFont:newFont].width;
        while (width > size.width && width != 0) {
            fontSize--;
            newFont = [UIFont fontWithName:font.fontName size:fontSize];
            width = [word sizeWithFont:newFont].width;
        }
    }
    return fontSize;
}

@end
