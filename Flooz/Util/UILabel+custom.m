//
//  UILabel+custom.m
//  Flooz
//
//  Created by jonathan on 1/2/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "UILabel+custom.h"

@implementation UILabel (custom)

// ios6
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if(self){
//        if(!IS_IOS7){
//            self.backgroundColor = [UIColor clearColor];
//        }
//    }
//    return self;
//}

- (void)setWidth{
    if(!self.text){
        self.frame = CGRectMakeSetWidth(self.frame, 0);
        return;
    }

    CGSize size = CGSizeZero;
    
    if(IS_IOS7){
        size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    }
    else{
//        size = [self.text sizeWithFont:self.font];
    }
    
    self.frame = CGRectMakeSetWidth(self.frame, size.width);
}

- (void)setHeight{
    if(!self.text || [self.text isBlank]){
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
