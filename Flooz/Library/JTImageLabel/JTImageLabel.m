//
//  JTImageLabel.m
//
//  Created by jonathan on 2013-03-15.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "JTImageLabel.h"

@implementation JTImageLabel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self commonInit];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self){
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_imageView];
    
    _imageHidden = NO;
    _imageOffset = CGPointZero;
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;
    
    [self setNeedsDisplay];
}

- (void)setImageOffset:(CGPoint)offset
{
    _imageOffset = offset;
    
    [self setNeedsDisplay];
}

- (void)setImageHidden:(BOOL)imageHidden
{
    _imageHidden = imageHidden;
    _imageView.hidden = _imageHidden;
    
    [self setNeedsDisplay];
}

- (void)drawTextInRect:(CGRect)rect
{
    if(!_imageHidden && _imageView.image){
        if(self.textAlignment == NSTextAlignmentLeft){
            rect = CGRectMake(rect.origin.x + _imageView.image.size.width - _imageOffset.x, rect.origin.y, rect.size.width - _imageView.image.size.width + _imageOffset.x, rect.size.height);
        }
    }

    [super drawTextInRect:rect];
    [self reloadImageView];
}

- (void)reloadImageView
{
    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    CGFloat x = 0;
    CGFloat y = (self.frame.size.height - _imageView.image.size.height) / 2.0 + _imageOffset.y;
    
    if(self.textAlignment == NSTextAlignmentRight){
        x = self.frame.size.width - textSize.width - _imageView.image.size.width + _imageOffset.x;
    }else if(self.textAlignment == NSTextAlignmentCenter){
        self.clipsToBounds = NO; // WARNING HACK
        x = ((self.frame.size.width - MIN(textSize.width, self.frame.size.width)) / 2.0) - _imageView.image.size.width + _imageOffset.x;
    }

    _imageView.frame = CGRectMake(x, y, _imageView.image.size.width, _imageView.image.size.height);
}

@end
