//
//  UILabel+custom.m
//  Flooz
//
//  Created by jonathan on 1/2/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "UILabel+custom.h"

@implementation UILabel (custom)

- (void)setWidth{
    if(self.text == nil){
        self.frame = CGRectMakeSetWidth(self.frame, 0);
        return;
    }
    
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    self.frame = CGRectMakeSetWidth(self.frame, size.width);
}

- (void)setHeight{
    if(self.text == nil){
        self.frame = CGRectMakeSetHeight(self.frame, 0);
        return;
    }
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:self.text
                                          attributes:@{NSFontAttributeName: self.font}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){self.frame.size.width, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];

    self.frame = CGRectMakeSetHeight(self.frame, rect.size.height);
}

@end
